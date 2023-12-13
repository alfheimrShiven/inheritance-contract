// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IInheritance {
    // Events //
    event InheritanceTransferredTo(address indexed newOwner);
    event Inherited(address indexed, uint256 amount);
    event NewHeirChosen(address indexed newHeir);

    // Errors //
    error NotOwnerNorHeir(address sender);
    error HeirCannotTransactYet();

    // Functions //

    /**
     * @notice The contract owner or his heir can withdraw ETH. It will have the following conditions:
     * 1. Withdrawal should reset the 1 month heir allowance time.
     * 2. Only owner can withdraw before the heir allowance time.
     * 3. Heir can withdraw only after the heir allowance time.
     * @param amount The amount to be withdrawn
     */
    function withdraw(uint256 amount) external payable;

    /**
     * @notice Used to allot a new heir.
     * If the owner calls it, the existing heir is replaced by the new heir.
     * The existing heir can only call this function post the heir
     * allowance time has crossed. If so, they become the new owner
     * and allot a new heir.
     * @dev The ownership transfer can also be automated using Chainlink's Upkeeps for a more mature implementation
     * @param newHeir Address of the new heir
     * */
    function allotNewHeir(address newHeir) external;
}
