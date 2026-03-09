// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

interface IMultisig {
    function submitTransaction(address to, uint256 value, bytes calldata data) external returns (uint256);

    function confirmTransaction(uint256 txId) external;

    function executeTransaction(uint256 txId) external;
}
