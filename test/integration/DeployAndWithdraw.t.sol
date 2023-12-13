// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import {Test} from "forge-std/Test.sol";
import {DeployInheritance} from "script/DeployInheritance.s.sol";
import {Inheritance} from "src/Inheritance.sol";

contract DeployAndWithdraw is Test {
    address owner = address(this);
    address heir = makeAddr("heir");
    uint256 constant ASSET_AMOUNT = 10 ether;
    Inheritance inheritanceContract;

    event ValueReceived(uint256 indexed);

    function setUp() external {
        DeployInheritance deployer = new DeployInheritance();
        inheritanceContract = deployer.run{value: ASSET_AMOUNT}(
            ASSET_AMOUNT,
            heir
        );
    }

    function testWithdrawByOwner() external {
        uint256 ownerBalBeforeWithdraw = owner.balance;
        uint256 inheritanceBalBeforeWithdraw = address(inheritanceContract)
            .balance;

        vm.prank(owner);
        inheritanceContract.withdraw(5 ether);

        assertEq(address(this).balance, (ownerBalBeforeWithdraw + 5 ether));
        assertEq(
            address(inheritanceContract).balance,
            (inheritanceBalBeforeWithdraw - 5 ether)
        );
    }

    function testWithdrawByHeir() external {
        // SETUP
        vm.warp(inheritanceContract.heirAllowanceTime());
        uint256 heirBalBeforeWithdraw = heir.balance;
        uint256 inheritanceBalBeforeWithdraw = address(inheritanceContract)
            .balance;

        // ACT
        vm.prank(heir);
        inheritanceContract.withdraw(5 ether);

        // ASSERT
        assertEq(heir.balance, (heirBalBeforeWithdraw + 5 ether));
        assertEq(
            address(inheritanceContract).balance,
            (inheritanceBalBeforeWithdraw - 5 ether)
        );
    }

    receive() external payable {
        emit ValueReceived(msg.value);
    }
}
