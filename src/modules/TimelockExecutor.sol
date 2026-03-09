// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {VaultErrors} from "../utils/VaultErrors.sol";

abstract contract TimelockExecutor {
    uint256 public constant TIMELOCK = 1 hours;

    function _safeTransfer(address to, uint256 value) internal {
        (bool success,) = to.call{value: value}("");

        if (!success) revert VaultErrors.EthTransferFailed();
    }
}
