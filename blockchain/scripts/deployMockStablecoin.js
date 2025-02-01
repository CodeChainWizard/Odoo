// scripts/deployMockStablecoin.js
const { ethers } = require("hardhat"); // Make sure to import ethers from hardhat

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log(
    "Deploying Mock ERC20 Stablecoin with the account:",
    deployer.address
  );

  const MockERC20 = await ethers.getContractFactory("MockERC20");
  const stablecoin = await MockERC20.deploy(
    "Mock Stablecoin",
    "MST",
    ethers.utils.parseUnits("1000000", 18)
  );

  console.log("Mock Stablecoin deployed to:", stablecoin.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
