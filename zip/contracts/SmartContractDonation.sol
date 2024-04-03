// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract DonationTracker {
    // State variables
    address public owner;
    uint256 public donationGoal;
    uint256 public totalDonations;
    bool public goalReached;
    mapping(address => uint256) public donations;

    // Events
    event DonationReceived(address indexed donor, uint256 amount);
    event Withdrawal(address indexed recipient, uint256 amount);
    event GoalReached(uint256 totalDonations);

    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    // Constructor
    constructor(uint256 _donationGoal) {
        owner = msg.sender;
        donationGoal = _donationGoal;
    }

    // Function to accept donations
    function donate() external payable {
        require(msg.value > 0, "Donation amount must be greater than 0");
        
        donations[msg.sender] += msg.value;
        totalDonations += msg.value;

        emit DonationReceived(msg.sender, msg.value);

        // Check if the donation goal is reached
        if (!goalReached && totalDonations >= donationGoal) {
            goalReached = true;
            emit GoalReached(totalDonations);
        }
    }

    // Function to withdraw accumulated donations
    function withdrawDonations() external onlyOwner {
        require(address(this).balance > 0, "Contract balance is zero");
        
        uint256 balanceToSend = address(this).balance;
        payable(owner).transfer(balanceToSend);
        
        emit Withdrawal(owner, balanceToSend);
    }

    // Function to get total donations received
    function getTotalDonations() external view returns (uint256) {
        return totalDonations;
    }

    // Function to get donation amount of a specific address
    function getDonationOf(address _donor) external view returns (uint256) {
        return donations[_donor];
    }

    // Function to change the donation goal
    function changeDonationGoal(uint256 _newGoal) external onlyOwner {
        require(_newGoal > 0, "New donation goal must be greater than 0");
        donationGoal = _newGoal;
    }
}
