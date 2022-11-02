const { ethers } = require("hardhat");
require("dotenv").config({ path: ".env" });

async function main() {
  const hello = await ethers.getContractFactory("HelloWorld");
  const helloContract = await hello.deploy();
  
  await helloContract.deployed();

  console.log(
    "Hello contract Address: ", 
    helloContract.address
  );

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });