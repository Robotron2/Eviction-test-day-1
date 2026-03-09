// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

interface IAirdrop {
    function claim(bytes32[] calldata proof, uint256 amount) external;
}
