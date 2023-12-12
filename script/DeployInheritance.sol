// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import {Script} from "forge-std/Script.sol";
import {Inheritance} from "src/Inheritance.sol";

contract DeployInheritance is Script {
    function run(
        uint256 depositAmount,
        address heir
    ) external payable returns (Inheritance) {
        Inheritance inheritance = new Inheritance{value: depositAmount}(heir);
        return inheritance;
    }
}
