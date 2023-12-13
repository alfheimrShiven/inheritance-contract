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

    modifier zeroAddressCheck(address heir) {
        require(heir != address(0), "Cannot be a zero address");
        _;
    }

    constructor(
        address _heir
    ) payable zeroAddressCheck(msg.sender) zeroAddressCheck(_heir) {
        require(msg.value > 0);
        owner = payable(msg.sender);
        heir = payable(_heir);
        heirAllowanceTime = block.timestamp + 4 weeks;
    }

    function withdraw(uint256 amount) external payable onlyOwnerOrHeir {
        if (msg.sender == owner) {
            heirAllowanceTime = block.timestamp + 4 weeks;
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

    function allotNewHeir(
        address newHeir
    ) external onlyOwnerOrHeir zeroAddressCheck(newHeir) {
        /// @dev Current heir will become the owner to take control of the assets and allot a new heir for himself
        if (msg.sender == heir) {
            owner = payable(msg.sender);
            emit InheritanceTransferredTo(msg.sender);
        }

        heir = payable(newHeir);
        heirAllowanceTime = block.timestamp + 4 weeks;
        emit NewHeirChosen(heir);
    }
}
