
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title Crowd Funding Smart Contract
 * @author 
 * @notice This contract allows users to create and contribute to crowdfunding projects.
 */

contract Project {
    address public manager;
    string public projectName;
    string public projectDescription;
    uint public targetAmount;
    uint public deadline;
    uint public raisedAmount;

    mapping(address => uint) public contributions;

    constructor(
        string memory _name,
        string memory _description,
        uint _targetAmount,
        uint _durationInDays
    ) {
        manager = msg.sender;
        projectName = _name;
        projectDescription = _description;
        targetAmount = _targetAmount;
        deadline = block.timestamp + (_durationInDays * 1 days);
    }

    modifier onlyManager() {
        require(msg.sender == manager, "Only manager can call this");
        _;
    }

    modifier beforeDeadline() {
        require(block.timestamp < deadline, "Deadline has passed");
        _;
    }

    modifier afterDeadline() {
        require(block.timestamp >= deadline, "Deadline not reached");
        _;
    }

    // 💰 Function to contribute funds
    function contribute() public payable beforeDeadline {
        require(msg.value > 0, "Contribution must be greater than 0");
        contributions[msg.sender] += msg.value;
        raisedAmount += msg.value;
    }

    // 📤 Function to withdraw funds (only if target met)
    function withdrawFunds() public onlyManager afterDeadline {
        require(raisedAmount >= targetAmount, "Target not reached");
        payable(manager).transfer(raisedAmount);
    }

    // 💸 Function to refund contributors if target not met
    function refund() public afterDeadline {
        require(raisedAmount < targetAmount, "Target was reached");
        uint contributed = contributions[msg.sender];
        require(contributed > 0, "No contributions found");
        contributions[msg.sender] = 0;
        payable(msg.sender).transfer(contributed);
    }

    // 📊 Get contract summary
    function getSummary() public view returns (
        string memory, string memory, uint, uint, uint, address
    ) {
        return (projectName, projectDescription, targetAmount, raisedAmount, deadline, manager);
    }
}
