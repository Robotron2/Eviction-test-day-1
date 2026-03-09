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
}
