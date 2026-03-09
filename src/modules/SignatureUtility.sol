// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract SignatureUtils {
    using ECDSA for bytes32;

    mapping(address => uint256) public nonces;

    function recoverSigner(bytes32 digest, bytes calldata sig) external pure returns (address) {
        return digest.recover(sig);
    }
}
