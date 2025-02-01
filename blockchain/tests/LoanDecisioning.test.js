const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("LoanDecisioning", function () {
  let LoanDecisioning, loanContract, owner, user;

  beforeEach(async function () {
    [owner, user] = await ethers.getSigners();
    const Stablecoin = await ethers.getContractFactory("MockStablecoin");
    const stablecoin = await Stablecoin.deploy();
    await stablecoin.deployed();

    LoanDecisioning = await ethers.getContractFactory("LoanDecisioning");
    loanContract = await LoanDecisioning.deploy(stablecoin.address);
    await loanContract.deployed();
  });

  it("Should allow a user to request a loan", async function () {
    await expect(loanContract.connect(user).requestLoan(100, 5, 3600)).to.emit(
      loanContract,
      "LoanRequested"
    );
  });

  it("Should allow a user to repay a loan", async function () {
    await loanContract.connect(user).requestLoan(100, 5, 3600);
    await expect(loanContract.connect(user).repayLoan(0)).to.emit(
      loanContract,
      "LoanRepaid"
    );
  });
});
