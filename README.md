## Task 3: DeFi App

## Requirements:
- 1.Ganache
- 2.Truffle
- 3.Node.js
- 4.MetaMask extension

  ## Deployment Steps:
- 1.Install truffle
  ``` 
   npm install -g truffle
   ```
- 2.Create project folders and initialize
 ``` 
   mkdir defi-lending-app
 cd defi-lending-app
truffle init
   ```
- 3.Install Ganache
- 4.Create a file contracts/Lending.sol:
   ``` 
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

   ```
  5.Create file migrations/2_deploy_lending.js:
   ``` 
  const Lending = artifacts.require("Lending");

    module.exports = function (deployer) {
  deployer.deploy(Lending);
    };

   ```
 - 6.Configure Metamask to Ganache
  
  7.Update truffle-config.js:
   ``` 
  module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 7545,
      network_id: "1337"
    }
  },
  compilers: {
    solc: {
      version: "0.8.0"
    }
  }
  };

   ```
8.Do create your application in index.html
- 9..Compile 
 ``` 
   truffle compile 
   ```
- 10.Make sure that Ganache is Running
- 11.Deploy
 
 ``` 
   truffle migrate
   ```
- 12.Install http-server via Node.js
- 13.Make sure to Update contract address in html file(npm install -g http-server)
- 14.Start the server and use your Dapp in browser




## Results

![Image](https://github.com/user-attachments/assets/0b9def30-bdad-40c6-b292-767e3927c4f3)
![Image](https://github.com/user-attachments/assets/1b83b823-987d-482a-a9b5-df6ea23897ad)
