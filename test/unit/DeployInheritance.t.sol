// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {Test} from "forge-std/Test.sol";
import {Inheritance} from "src/Inheritance.sol";
import {DeployInheritance} from "script/DeployInheritance.s.sol";

contract DeployInheritanceTest is Test {
    address heir = makeAddr("heir");
    uint256 constant ASSET_VALUE = 10 ether;
    DeployInheritance deployer;

    function setUp() external {
        deployer = new DeployInheritance();
    }

    function testRevertDeployingInheritanceWithoutSendingValue() external {
        vm.expectRevert();
        deployer.run(0, heir);
    }

    function testRevertDeployingInheritanceWithZeroAddress() external {
        vm.prank(address(0));
        vm.expectRevert();
        deployer.run(ASSET_VALUE, address(0));
    }

    function testDeployInheritance() external {
        Inheritance inheritance = deployer.run{value: ASSET_VALUE}(
            ASSET_VALUE,
            heir
        );
        assertEq(inheritance.owner(), address(this));
    }
}
