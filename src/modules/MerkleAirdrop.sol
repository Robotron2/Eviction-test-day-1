// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "../utils/VaultEvent.sol";

abstract contract MerkleAirdrop {
    bytes32 public merkleRoot;

    mapping(address => bool) public claimed;

    function _setMerkleRoot(bytes32 root) internal {
        merkleRoot = root;
        emit RootUpdated(root);
    }

    function _verifyClaim(address user, uint256 amount, bytes32[] calldata proof) internal view returns (bool) {
        bytes32 leaf = keccak256(abi.encodePacked(user, amount));

        return MerkleProof.verify(proof, merkleRoot, leaf);
    }
}
