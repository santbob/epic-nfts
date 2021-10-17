const main = async () => {
  const nftContractFactory = await hre.ethers.getContractFactory("MyEpicNFT");
  const nftContract = await nftContractFactory.deploy();
  await nftContract.deployed();


  const nftContractAddress = nftContract.address;
  console.log(`NFT contract deployed to address: ${nftContractAddress}`);

  console.log(`Maximum ${nftContract.getMaxNFTsMintable()} that can be minted`)

  //lets mint an NFT
  let txn = await nftContract.makeMiganNFT();
  // wait for the transaction to be mined
  txn.wait();

  let totalNFTsMinted = await nftContract.getTotalNFTsMinted();
  
  console.log(`Total NFT's minted ${totalNFTsMinted}`)

  //lets done one more mint
  txn = await nftContract.makeMiganNFT();
  // wait for the transaction to be mined
  txn.wait();

  totalNFTsMinted = await nftContract.getTotalNFTsMinted();
  console.log(`Total NFT's minted ${totalNFTsMinted}`)

  //lets done one more mint
  txn = await nftContract.makeMiganNFT();
  // wait for the transaction to be mined
  txn.wait();

  totalNFTsMinted = await nftContract.getTotalNFTsMinted();
  console.log(`Final Total NFT's minted ${totalNFTsMinted}`)
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