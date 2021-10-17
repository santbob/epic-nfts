const main = async () => {
  const nftContractFactory = await hre.ethers.getContractFactory("MyEpicNFT");
  const nftContract = await nftContractFactory.deploy();
  await nftContract.deployed();

  const nftContractAddress = nftContract.address;
  console.log(`NFT contract deployed to address: ${nftContractAddress}`);

  //lets mint an NFT
  let txn = await nftContract.makeMiganNFT();
  // wait for the transaction to be mined
  txn.wait();
  console.log("Minted MiganNFT #1")

  //lets done one more mint
  txn = await nftContract.makeMiganNFT();
  // wait for the transaction to be mined
  txn.wait();
  console.log("Minted MiganNFT #2")
}

const runOnMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.error(error);
    process.exit(1);
  }
}

runOnMain();