// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Script, console2} from "forge-std/Script.sol";
import "../src/BuyOnchainIPFSACupcake.sol";

contract BuyOnchainIPFSACupcakeScript is Script {
    function setUp() public {}

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateKey);
        BuyOnchainIPFSACupcake buyOnchainIpfsACupcake = new BuyOnchainIPFSACupcake();
        vm.stopBroadcast();
        console2.log("BuyOnchainIPFSACupcake address: ", address(buyOnchainIpfsACupcake));
    }
}
