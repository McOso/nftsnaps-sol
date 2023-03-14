import { HardhatRuntimeEnvironment } from "hardhat/types";
import { utils } from "ethers";

export default async function deploy(hardhat: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts, ethers } = hardhat;

  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  const SnapFactory = await deploy("SnapFactory", {
    contract: "SnapFactory",
    from: deployer,
    args: [],
    skipIfAlreadyDeployed: true,
    log: true,
  });

  // EXAMPLE DEPLOYING A SNAP
  const snapFactoryContract = await ethers.getContractAt("SnapFactory", SnapFactory.address);

  const contractInformation = {
    name: "Test Snap",
    description: "This is a test snap",
    image: "ipfs://QmXxZWr5AQf25yu1UswNm2cfGbaUbR5U3ejH1WfFEP8f1e",
    externalLink: "https://testing.snap",
    sellerFeeBasisPoints: "100",
    feeRecipient: "0x0000000000000000000000000000000000000000",
  };

  const MINT_FEE = utils.parseEther("0.0000092");

  const txSnap = await snapFactoryContract.createSnap(
    "Test Snap",
    "NFTSNAP",
    contractInformation,
    "ipfs://QmXxZWr5AQf25yu1UswNm2cfGbaUbR5U3ejH1WfFEP8f1e",
    "ipfs://QmTkCP5u95yQRr9kM513QNr5pT6DYe3sD3yn8qRi2osTPg",
    MINT_FEE,
    deployer,
    deployer,
    0
  );
  const receiptSnap = await txSnap.wait();

  console.log("test snap contract address: ", receiptSnap.events[2].args[0]);
}
