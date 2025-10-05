// SPDX-License-Identifier: MIT
pragma solidity 0.8.20; //Do not change the solidity version as it negatively impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {
    ExampleExternalContract public exampleExternalContract;

    mapping(address => uint256) public balances;
    uint256 public constant threshold= 1 ether;
    uint256 public deadline = block.timestamp + 72 hours;
    bool public openForWithdraw = false;

    constructor(address exampleExternalContractAddress) {
        exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
    }

    event Stake(address indexed sender, uint256 amount);
    function stake() public payable {
        // To be implemented
        balances[msg.sender] += msg.value;
        emit Stake(msg.sender, msg.value);
    }

    function execute() public {
        require(block.timestamp >= deadline, "Deadline not yet passed");
        if(address(this).balance >= threshold){
            exampleExternalContract.complete{value:address(this).balance}();
        }
        else{
            openForWithdraw = true;
        }
    }

    function timeLeft() public view returns (uint256){
        if(block.timestamp >= deadline){
            return 0;
        }
        else{
            return deadline - block.timestamp;
        }
    }

    receive() external payable{
        stake();
    }

    function withdraw() public {
        require(openForWithdraw, "Withdrawals are not allowed");
        uint256 userBalance = balances[msg.sender];
        require(userBalance > 0, "No balance to withdraw");
        balances[msg.sender] = 0;
        (bool success, ) = msg.sender.call{value: userBalance}("");
        require(success, "Transfer failed.");
    }
    // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
    // (Make sure to add a `Stake(address,uint256)` event and emit it for the frontend `All Stakings` tab to display)

    // After some `deadline` allow anyone to call an `execute()` function
    // If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`

    // If the `threshold` was not met, allow everyone to call a `withdraw()` function to withdraw their balance

    // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend

    // Add the `receive()` special function that receives eth and calls stake()
}
