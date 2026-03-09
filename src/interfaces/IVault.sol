// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

interface IVault {
    function deposit() external payable;

    function withdraw(uint256 amount) external;
}
