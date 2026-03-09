// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

event Deposit(address indexed user, uint256 amount);
event Withdrawal(address indexed user, uint256 amount);

event Submission(uint256 indexed txId);
event Confirmation(uint256 indexed txId, address indexed owner);
event Execution(uint256 indexed txId);

event MerkleRootSet(bytes32 indexed root);
event Claim(address indexed user, uint256 amount);
event RootUpdated(bytes32 root);

event Paused(address indexed owner);
event Unpaused(address indexed owner);
