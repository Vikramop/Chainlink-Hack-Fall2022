const hre = require('hardhat');

async function sleep(ms) {
  return new Promise((resolve) => {
    setTimeout(() => resolve(), ms);
  });
}

async function main() {
  const initialAmount = hre.ethers.utils.parseEther('0.1');

  const dicegame = await hre.ethers.getContractFactory('dicegame');
  const contract = await dicegame.deploy({ value: initialAmount });

  // Wait for it to finish deploying
  await contract.deployed();

  // print the address of the deployed contract
  console.log(`dicegame Contract Address: ${contract.address}`);

  await sleep(40 * 1000);

  await hre.run('verify:verify', {
    address: contract.address,
    constructorArguments: [],
  });
}

// Call the main function and catch if there is any error
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
