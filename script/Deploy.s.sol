// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.13;

import {CREATE3Script} from "./base/CREATE3Script.sol";
import {TimelessToken} from "../src/TimelessToken.sol";

contract DeployScript is CREATE3Script {
    constructor() CREATE3Script(vm.envString("VERSION")) {}

    function run() external returns (TimelessToken timelessToken) {
        uint256 deployerPrivateKey = uint256(vm.envBytes32("PRIVATE_KEY"));

        string memory name = vm.envString("NAME");
        string memory symbol = vm.envString("SYMBOL");
        address owner = vm.envAddress("OWNER");

        // assumes the options token was deployed with the same deployer account
        address optionsToken = getCreate3Contract("OptionsToken");

        vm.startBroadcast(deployerPrivateKey);

        timelessToken = TimelessToken(
            create3.deploy(
                getCreate3ContractSalt("TimelessToken"),
                bytes.concat(type(TimelessToken).creationCode, abi.encode(name, symbol, owner, optionsToken))
            )
        );

        vm.stopBroadcast();
    }
}
