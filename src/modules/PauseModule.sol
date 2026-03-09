// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

abstract contract PauseModule {
    bool public paused;

    event Paused();
    event Unpaused();

    modifier whenNotPaused() {
        require(!paused, "paused");
        _;
    }

    function _pause() internal {
        paused = true;
        emit Paused();
    }

    function _unpause() internal {
        paused = false;
        emit Unpaused();
    }
}
