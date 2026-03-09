// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {MultisigCore} from "./modules/MultisigCore.sol";
import {MerkleAirdrop} from "./modules/MerkleAirdrop.sol";
import {TimelockExecutor} from "./modules/TimelockExecutor.sol";
import {PauseModule} from "./modules/PauseModule.sol";

import {VaultErrors} from "./utils/VaultErrors.sol";
import "./utils/VaultEvent.sol";

contract HardenedEvictionVault is MultisigCore, MerkleAirdrop, TimelockExecutor, PauseModule {
    mapping(address => uint256) public balances;

    uint256 public totalVaultValue;

    uint256 public constant MAX_WITHDRAW = 10;

    constructor(address[] memory owners, uint256 threshold) MultisigCore(owners, threshold) {}

    receive() external payable {
        balances[msg.sender] += msg.value;
        totalVaultValue += msg.value;

        emit Deposit(msg.sender, msg.value);
    }

    function deposit() external payable {
        balances[msg.sender] += msg.value;
        totalVaultValue += msg.value;

        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) external whenNotPaused {
        if (balances[msg.sender] < amount) revert VaultErrors.InsufficientBalance();

        uint256 cap = balances[msg.sender] / MAX_WITHDRAW;

        if (amount > cap) revert VaultErrors.WithdrawLimitExceeded();

        balances[msg.sender] -= amount;
        totalVaultValue -= amount;

        _safeTransfer(msg.sender, amount);

        emit Withdrawal(msg.sender, amount);
    }

    function claim(bytes32[] calldata proof, uint256 amount) external whenNotPaused {
        if (claimed[msg.sender]) revert VaultErrors.AlreadyClaimed();

        if (!_verifyClaim(msg.sender, amount, proof)) revert VaultErrors.InvalidProof();

        claimed[msg.sender] = true;

        _safeTransfer(msg.sender, amount);

        emit Claim(msg.sender, amount);
    }
}
