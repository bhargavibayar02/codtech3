// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Lending {
    struct Loan {
        uint amount;
        uint interestRate; // Annual interest rate in %
        uint startTime;
        address borrower;
        bool repaid;
    }

    address public owner;
    mapping(address => uint) public deposits;
    mapping(address => Loan) public loans;

    constructor() {
        owner = msg.sender;
    }

    // Deposit ETH into the lending pool
    function deposit() external payable {
        require(msg.value > 0, "Deposit must be greater than 0");
        deposits[msg.sender] += msg.value;
    }

    // Borrow ETH from the pool
    function borrow(uint amount) external {
        require(amount > 0, "Amount must be greater than 0");
        require(loans[msg.sender].amount == 0, "Already borrowed");

        uint dynamicInterest = getDynamicInterest();
        loans[msg.sender] = Loan({
            amount: amount,
            interestRate: dynamicInterest,
            startTime: block.timestamp,
            borrower: msg.sender,
            repaid: false
        });

        payable(msg.sender).transfer(amount);
    }

    // Repay the loan with interest
    function repay() external payable {
        Loan storage loan = loans[msg.sender];
        require(loan.amount > 0, "No active loan");
        require(!loan.repaid, "Already repaid");

        uint interest = calculateInterest(loan);
        uint totalDue = loan.amount + interest;

        require(msg.value >= totalDue, "Insufficient repayment");

        loan.repaid = true;
        deposits[owner] += msg.value;
    }

    // Calculate interest owed on a loan
    function calculateInterest(Loan memory loan) public view returns (uint) {
        uint timeElapsed = block.timestamp - loan.startTime;
        uint interest = (loan.amount * loan.interestRate * timeElapsed) / (365 days * 100);
        return interest;
    }

    // View-only function to get total due (principal + interest)
    function getTotalDue(address borrower) external view returns (uint principal, uint interest, uint total) {
        Loan memory loan = loans[borrower];
        if (loan.amount == 0 || loan.repaid) {
            return (0, 0, 0);
        }
        interest = calculateInterest(loan);
        return (loan.amount, interest, loan.amount + interest);
    }

    // Dynamic interest rate based on contract liquidity
    function getDynamicInterest() public view returns (uint) {
        uint balance = address(this).balance;
        if (balance > 10 ether) return 5;  // 5% annually
        if (balance > 5 ether) return 10;
        return 15;
    }

    // View contract balance
    function getContractBalance() public view returns (uint) {
        return address(this).balance;
    }
}