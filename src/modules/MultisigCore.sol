// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "../utils/VaultEvent.sol";
import {VaultErrors} from "../utils/VaultErrors.sol";

contract MultisigCore {
    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        uint256 confirmations;
        uint256 executionTime;
        bool executed;
    }

    mapping(uint256 => Transaction) public transactions;
    mapping(uint256 => mapping(address => bool)) public confirmed;

    address[] public owners;
    mapping(address => bool) public isOwner;

    uint256 public threshold;
    uint256 public txCount;

    modifier onlyOwner() {
        if (!isOwner[msg.sender]) revert VaultErrors.NotOwner();
        _;
    }

    constructor(address[] memory _owners, uint256 _threshold) {
        threshold = _threshold;

        for (uint256 i; i < _owners.length; i++) {
            isOwner[_owners[i]] = true;
            owners.push(_owners[i]);
        }
    }

    function submitTransaction(address to, uint256 value, bytes calldata data) external onlyOwner returns (uint256 id) {
        id = txCount++;

        transactions[id] = Transaction(to, value, data, 1, 0, false);

        confirmed[id][msg.sender] = true;

        emit Submission(id);
    }

    function confirmTransaction(uint256 txId) external onlyOwner {
        Transaction storage txn = transactions[txId];

        if (txn.executed) revert VaultErrors.TxAlreadyExecuted();

        if (confirmed[txId][msg.sender]) revert VaultErrors.AlreadyConfirmed();

        confirmed[txId][msg.sender] = true;

        txn.confirmations++;

        if (txn.confirmations >= threshold) {
            txn.executionTime = block.timestamp + 1 hours;
        }

        emit Confirmation(txId, msg.sender);
    }
}
