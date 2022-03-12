const main = async () => {
  const waveContractFactory = await hre.ethers.getContractFactory("WavePortal");
  /*
   * デプロイする際0.1ETHをコントラクトに提供する
   */
  const waveContract = await waveContractFactory.deploy({
    value: hre.ethers.utils.parseEther("0.1"),
  });
  await waveContract.deployed();
  console.log("Contract deployed to:", waveContract.address);

  /*
   * コントラクトの残高を取得（0.1ETH）であることを確認
   */
  let contractBalance = await hre.ethers.provider.getBalance(
    waveContract.address
  );
  console.log(
    "Contract balance:",
    hre.ethers.utils.formatEther(contractBalance)
  );

  /*
   * Waveを取得
   */
  let waveTxn = await waveContract.wave("A message!");
  await waveTxn.wait();

  /*
   * コントラクトの残高を取得し、Waveを取得した後の結果を出力
   */
  contractBalance = await hre.ethers.provider.getBalance(waveContract.address);
  /*
   *コントラクトの残高から0.0001ETH引かれていることを確認
   */
  console.log(
    "Contract balance:",
    hre.ethers.utils.formatEther(contractBalance)
  );

  let allWaves = await waveContract.getAllWaves();
  console.log(allWaves);
};

const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.log(error);
    process.exit(1);
  }
};

runMain();