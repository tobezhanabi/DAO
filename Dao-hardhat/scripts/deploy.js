const { ethers } = require("hardhat");
const { CRYPTODEV_NFT_CONTRACT_ADDRESS } = require("../constants");

async function main() {
  const FakeNFTMarketplace = await ethers.getContractFactory(
    "FakeNFTMarketplace"
  );
  const fakeNFTMarketplace = await FakeNFTMarketplace.deploy();
  await fakeNFTMarketplace.deployed();
  console.log(`Nft marketplace deployed to ${fakeNFTMarketplace.address}`);

  const CryptoDevDao = await ethers.getContractFactory("CryptoDevDAO");
  const cryptoDevDAO = await CryptoDevDao.deploy(
    fakeNFTMarketplace.address,
    CRYPTODEV_NFT_CONTRACT_ADDRESS,
    { value: ethers.utils.parseEther("0.21") }
  );
  await cryptoDevDAO.deployed();

  console.log(`cryptoDev dao deployed to ${cryptoDevDAO.address}`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.log(error);
    process.exit(1);
  });
