// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import {Test} from "forge-std/Test.sol";
import {Inheritance} from "src/Inheritance.sol";
import {IInheritance} from "interfaces/IInheritance.sol";
import {DeployInheritance} from "script/DeployInheritance.sol";

contract InheritanceTest is Test {
    address owner = makeAddr("owner");
    address heir = makeAddr("heir");
    Inheritance inheritanceContract;
    uint256 public constant ASSET_VALUE = 10 ether;
    uint256 public constant WITHDRAW_AMT = 5 ether;

    function setUp() external {
        vm.deal(owner, ASSET_VALUE);
        vm.prank(owner);
        inheritanceContract = new Inheritance{value: ASSET_VALUE}(heir);
    }

    ///////////////////////////
    ///// withdraw() tests/////
    ///////////////////////////

    function testRevertIfHeirTriesToWithdrawBeforeTime() external {
        // Setup
        vm.prank(heir);
        vm.expectRevert(IInheritance.HeirCannotTransactYet.selector);
        // ACT/ASSERT
        inheritanceContract.withdraw(WITHDRAW_AMT);
    }

    function testInheritanceTimeResetWhenOwnerWithdrawsZero() external {
        // Setup
        uint256 heirAllowanceTimeOnSetup = inheritanceContract
            .heirAllowanceTime();
        vm.warp(block.timestamp + 2 weeks);
        uint256 expectedRestTime = block.timestamp + 4 weeks;

        // Interact
        vm.prank(owner);
        inheritanceContract.withdraw(0);

        // Assert
        uint256 resetHeirAllowanceTime = inheritanceContract
            .heirAllowanceTime();
        assert(heirAllowanceTimeOnSetup < resetHeirAllowanceTime);
        assertEq(expectedRestTime, resetHeirAllowanceTime);
    }

    function testInheritanceTimeResetWhenOwnerWithdraws() external {
        // Setup
        uint256 heirAllowanceTimeOnSetup = inheritanceContract
            .heirAllowanceTime();
        vm.warp(block.timestamp + 2 weeks);
        uint256 expectedRestTime = block.timestamp + 4 weeks;

        // Interact
        vm.prank(owner);
        inheritanceContract.withdraw(WITHDRAW_AMT);

        // Assert
        uint256 resetHeirAllowanceTime = inheritanceContract
            .heirAllowanceTime();
        assert(heirAllowanceTimeOnSetup < resetHeirAllowanceTime);
        assertEq(expectedRestTime, resetHeirAllowanceTime);
    }

    function testOwnerWithdraw() external {
        // Setup
        uint256 inheritanceContractBalOnSetup = address(inheritanceContract)
            .balance;

        // ACT
        vm.prank(owner);
        inheritanceContract.withdraw(WITHDRAW_AMT);

        // Assert
        assertEq(
            address(inheritanceContract).balance,
            (inheritanceContractBalOnSetup - WITHDRAW_AMT)
        );
    }

    function testHeirWithdraw() external {
        // Setup
        vm.warp(block.timestamp + 5 weeks);
        vm.prank(heir);

        // ACT
        inheritanceContract.withdraw(WITHDRAW_AMT);

        // Assert
        assertEq(
            address(inheritanceContract).balance,
            ASSET_VALUE - WITHDRAW_AMT
        );
        assertEq(heir.balance, WITHDRAW_AMT);
    }
}
