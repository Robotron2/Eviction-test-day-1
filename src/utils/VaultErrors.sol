// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

library VaultErrors {
    error NotOwner();
    error Paused();
    error InsufficientBalance();
    error AlreadyClaimed();
    error InvalidProof();
    error TxAlreadyExecuted();
    error TxNotConfirmed();
    error TimelockNotExpired();
    error NotEnoughConfirmations();
    error InvalidAddress();
    error AlreadyConfirmed();
    error EmergencyNotAuthorized();
    error WithdrawLimitExceeded();
    error EthTransferFailed();
}
