// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LoanDecisioning is Ownable {
    struct Loan {
        address borrower;
        uint256 amount;
        uint256 interestRate;
        uint256 dueDate;
        bool isRepaid;
    }

    struct User {
        uint256 reputationScore;
        uint256 totalLoansTaken;
        uint256 totalLoansRepaid;
    }

    IERC20 public stablecoin;
    uint256 public loanPoolBalance;
    uint256 public reputationThreshold = 50;
    mapping(address => Loan[]) public loans;
    mapping(address => User) public users;

    event LoanRequested(address indexed borrower, uint256 amount, uint256 interestRate, uint256 dueDate);
    event LoanRepaid(address indexed borrower, uint256 amount);
    event ReputationUpdated(address indexed user, uint256 newScore);

    constructor(address _stablecoinAddress) {
        stablecoin = IERC20(_stablecoinAddress);
    }

    function getCreditScore(address user) public view returns (uint256) {
        return users[user].reputationScore;
    }

    function requestLoan(uint256 _amount, uint256 _interestRate, uint256 _duration) external {
        require(getCreditScore(msg.sender) >= reputationThreshold, "Insufficient reputation score for loan.");
        require(stablecoin.balanceOf(address(this)) >= _amount, "Not enough funds in the loan pool.");

        uint256 dueDate = block.timestamp + _duration;
        loans[msg.sender].push(Loan(msg.sender, _amount, _interestRate, dueDate, false));
        users[msg.sender].totalLoansTaken++;

        stablecoin.transfer(msg.sender, _amount);
        emit LoanRequested(msg.sender, _amount, _interestRate, dueDate);
    }

    function repayLoan(uint256 loanIndex) external {
        Loan storage loan = loans[msg.sender][loanIndex];
        require(!loan.isRepaid, "Loan already repaid.");
        require(block.timestamp <= loan.dueDate, "Loan due date has passed!");

        uint256 repaymentAmount = loan.amount + (loan.amount * loan.interestRate / 100);
        require(stablecoin.transferFrom(msg.sender, address(this), repaymentAmount), "Repayment failed.");

        loan.isRepaid = true;
        users[msg.sender].totalLoansRepaid++;
        users[msg.sender].reputationScore += 10;

        emit LoanRepaid(msg.sender, repaymentAmount);
        emit ReputationUpdated(msg.sender, users[msg.sender].reputationScore);
    }

    function fundLoanPool(uint256 _amount) external onlyOwner {
        require(stablecoin.transferFrom(msg.sender, address(this), _amount), "Funding failed.");
        loanPoolBalance += _amount;
    }

    function setReputationThreshold(uint256 _threshold) external onlyOwner {
        reputationThreshold = _threshold;
    }

    function getLoanPoolBalance() external view returns (uint256) {
        return stablecoin.balanceOf(address(this));
    }
}
