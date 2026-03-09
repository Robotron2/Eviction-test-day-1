// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/HardenedEvictionVault.sol";

contract DeployVault is Script {
    function run() external {
        uint256 deployerPrivateKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
        address deployerAddress = vm.addr(deployerPrivateKey);

        // Owners and Threshold
        address[] memory owners = new address[](2);
        owners[0] = deployerAddress;
        owners[1] = address(0x70997970C51812dc3A010C7d01b50e0d17dc79C8);

        uint256 threshold = 2;

        vm.startBroadcast(deployerPrivateKey);

        // Deploy the Vault
        HardenedEvictionVault vault = new HardenedEvictionVault(owners, threshold);

        (bool success,) = address(vault).call{value: 10 ether}("");
        require(success, "Initial funding failed");

        vm.stopBroadcast();

        // Log results to console
        console.log("HardenedEvictionVault deployed at:", address(vault));
        console.log("Threshold set to:", threshold);
        console.log("Vault Balance:", address(vault).balance / 1e18, "ETH");
    }
}
