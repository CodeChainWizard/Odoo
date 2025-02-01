// scripts/deployLoanDecisioning.js
const { ethers } = require("hardhat");

async function main() {
  // Use Hardhat to get the signers
  const [deployer] = await ethers.getSigners();

  console.log(
    "Deploying LoanDecisioning contract with the account:",
    deployer.address
  );

  const stablecoinAddress = "0x5FbDB2315678afecb367f032d93F642f64180aa3";

  const LoanDecisioning = await ethers.getContractFactory("LoanDecisioning");
  const loanDecisioning = await LoanDecisioning.deploy(stablecoinAddress);

  console.log("LoanDecisioning contract deployed to:", loanDecisioning.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

// 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512
