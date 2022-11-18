// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.13;

import {CREATE3Factory} from "create3-factory/CREATE3Factory.sol";

import "forge-std/Script.sol";

import {TimelessToken} from "../src/TimelessToken.sol";

contract DeployScript is Script {
    function run() external returns (TimelessToken timelessToken) {
        uint256 deployerPrivateKey = uint256(vm.envBytes32("PRIVATE_KEY"));
        address deployer = vm.addr(deployerPrivateKey);
        CREATE3Factory create3 = CREATE3Factory(0x9fBB3DF7C40Da2e5A0dE984fFE2CCB7C47cd0ABf);

        string memory name = vm.envString("NAME");
        string memory symbol = vm.envString("SYMBOL");
        address owner = vm.envAddress("OWNER");

        // assumes the options token was deployed with the same deployer account
        address optionsToken = create3.getDeployed(deployer, keccak256("OptionsToken-v1.0.0"));

        vm.startBroadcast(deployerPrivateKey);

        timelessToken = TimelessToken(
            create3.deploy(
                keccak256("TimelessToken-v1.0.0"),
                bytes.concat(type(TimelessToken).creationCode, abi.encode(name, symbol, owner, optionsToken))
            )
        );

        vm.stopBroadcast();
    }
}
