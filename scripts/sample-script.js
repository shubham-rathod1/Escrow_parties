const hre = require('hardhat');

async function main() {
  // We get the contract to deploy
  const EScrow = await hre.ethers.getContractFactory('Escrow');
  const escrow = await EScrow.deploy();

  await escrow.deployed();

  console.log('EScrow deployed to:', escrow.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
