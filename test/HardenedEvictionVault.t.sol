// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/HardenedEvictionVault.sol";
import {VaultErrors} from "../src/utils/VaultErrors.sol";

contract EvictionVaultTest is Test {
    HardenedEvictionVault vault;

    address owner1 = address(0x11);
    address owner2 = address(0x22);
    address user = address(0x33);

    address[] owners;

    function setUp() public {
        owners.push(owner1);
        owners.push(owner2);

        // Threshold of 2 --> 2 must confirm
        vault = new HardenedEvictionVault(owners, 2);

        vm.deal(user, 100 ether);
        vm.deal(address(vault), 50 ether); // Provide liquidity for claims
    }

    /* ---------------------------------------------------------- */
    /* ---------------------POSITIVE TESTS----------------------- */
    /* ---------------------------------------------------------- */

    function test_DepositUpdatesBalance() public {
        vm.prank(user);
        vault.deposit{value: 10 ether}();

        assertEq(vault.balances(user), 10 ether);
        assertEq(vault.totalVaultValue(), 10 ether);
    }

    function test_WithdrawWithinLimit() public {
        vm.startPrank(user);
        vault.deposit{value: 10 ether}();

        // 10% limit
        vault.withdraw(1 ether);

        assertEq(vault.balances(user), 9 ether);
        vm.stopPrank();
    }

    function test_MultisigFlow_SubmissionAndConfirmation() public {
        vm.prank(owner1);
        uint256 txId = vault.submitTransaction(address(0xABC), 1 ether, "");

        (address to,,, uint256 confirmations, uint256 executionTime, bool executed) = vault.transactions(txId);

        assertEq(to, address(0xABC));
        assertEq(confirmations, 1);
        assertEq(executionTime, 0);
        assertFalse(executed);

        vm.prank(owner2);
        vault.confirmTransaction(txId);

        (,,, uint256 newConfirmations, uint256 newExecutionTime,) = vault.transactions(txId);
        assertEq(newConfirmations, 2);
        assertEq(newExecutionTime, block.timestamp + 1 hours);
    }

    /* ---------------------------------------------------------- */
    /* ---------------------SECURITY TESTS----------------------- */
    /* ---------------------------------------------------------- */

    function test_Revert_WithdrawExceedsLimit() public {
        vm.startPrank(user);
        vault.deposit{value: 10 ether}();

        // 1.1 ether > 10% of 10 ether
        vm.expectRevert(VaultErrors.WithdrawLimitExceeded.selector);
        vault.withdraw(1.1 ether);
        vm.stopPrank();
    }

    function test_Revert_DoubleClaim() public {
        uint256 amount = 5 ether;

        // 1. Setup Leaf and Root
        bytes32 leaf = keccak256(abi.encodePacked(user, amount));
        bytes32 root = leaf;
        bytes32[] memory proof = new bytes32[](0);

        // 2. Set the Merkle Root in storage
        vm.store(address(vault), bytes32(uint256(6)), root);

        // 3. Perform the claims
        vm.startPrank(user);

        // First claim: Should succeed
        vault.claim(proof, amount);

        // Second claim: Should revert
        vm.expectRevert(VaultErrors.AlreadyClaimed.selector);
        vault.claim(proof, amount);

        vm.stopPrank();
    }

    function test_Revert_UnauthorizedSubmit() public {
        // If !notOwner, expect revert
        vm.prank(user);
        vm.expectRevert(VaultErrors.NotOwner.selector);
        vault.submitTransaction(address(0xBAD), 1 ether, "");
    }

    function test_Revert_ConfirmTwice() public {
        vm.prank(owner1);
        uint256 txId = vault.submitTransaction(address(0xABC), 0, "");

        vm.prank(owner1);
        vm.expectRevert(VaultErrors.AlreadyConfirmed.selector);
        vault.confirmTransaction(txId);
    }

    function test_Exploit_LimitBypassAttempt() public {
        vm.startPrank(user);
        vault.deposit{value: 1 ether}();

        vault.deposit{value: 9 ether}();

        vm.expectRevert(VaultErrors.WithdrawLimitExceeded.selector);
        vault.withdraw(1.1 ether);
        vm.stopPrank();
    }

    function test_Exploit_ZeroWithdrawal() public {
        vm.prank(user);
        vault.withdraw(0);
        assertEq(vault.balances(user), 0);
    }

    function test_Security_InvalidProofFails() public {
        vm.store(address(vault), bytes32(uint256(6)), keccak256("real_root"));

        bytes32[] memory fakeProof = new bytes32[](1);
        fakeProof[0] = keccak256("fake_node");

        vm.prank(user);
        vm.expectRevert(VaultErrors.InvalidProof.selector);
        vault.claim(fakeProof, 1 ether);
    }

    function test_Revert_UnauthorizedPause() public {
        vm.prank(user);
        vm.expectRevert(); // Should revert because user is not an owner
        vault.pause();
    }

    function test_Revert_NonOwnerSetsRoot() public {
        vm.prank(user);
        (bool success,) = address(vault).call(abi.encodeWithSignature("setMerkleRoot(bytes32)", bytes32(0)));
        assertFalse(success);
    }

    function test_Revert_DirectEmergencyWithdraw() public {
        vm.prank(user);
        (bool success,) = address(vault).call(abi.encodeWithSignature("emergencyWithdrawAll()"));
        assertFalse(success);
    }
}
