// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;
import {IInheritance} from "interfaces/IInheritance.sol";

contract Inheritance is IInheritance {
    // States //
    address payable public owner;
    address payable public heir;
    uint256 public heirAllowanceTime;

    modifier onlyOwnerOrHeir() {
        if (msg.sender != owner && msg.sender != heir) {
            revert NotOwnerNorHeir(msg.sender);
        }

        if (msg.sender == heir && block.timestamp <= heirAllowanceTime) {
            revert HeirCannotTransactYet();
        }
        _;
    }

    constructor(address _heir) payable {
        require(msg.value > 0);
        owner = payable(msg.sender);
        heir = payable(_heir);
        heirAllowanceTime = block.timestamp + 1 minutes;
    }

    function withdraw(uint256 amount) external payable onlyOwnerOrHeir {
        if (msg.sender == owner) {
            heirAllowanceTime += 1 minutes;
        }

        if (amount > 0) {
            require(
                amount <= address(this).balance,
                "Amount cannot be greater than the contract balance"
            );

            (bool success, ) = payable(msg.sender).call{value: amount}("");
            if (success) emit Inherited(msg.sender, amount);
        }
    }

    function allotNewHeir(address newHeir) external onlyOwnerOrHeir {
        if (msg.sender == heir) {
            owner = payable(msg.sender);
            emit InheritanceTransferredTo(msg.sender);
        }

        require(newHeir != address(0), "Cannot be a zero address");

        heir = payable(newHeir);
        heirAllowanceTime = block.timestamp + 1 minutes;
        emit NewHeirChosen(heir);
    }
}
