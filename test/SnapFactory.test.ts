import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import { expect } from 'chai';
import { deployMockContract, MockContract } from 'ethereum-waffle';
import { Contract, ContractFactory } from 'ethers';
import { artifacts, ethers } from 'hardhat';
import { Artifact } from 'hardhat/types';

const { getSigners, utils } = ethers;
const { parseEther: toWei } = utils;

const contractInformation = {
  name: 'Test Snap',
  description: 'This is a test snap',
  image: 'ipfs://QmXxZWr5AQf25yu1UswNm2cfGbaUbR5U3ejH1WfFEP8f1e',
  externalLink: 'https://testing.snap',
  sellerFeeBasisPoints: '100',
  feeRecipient: '0x0000000000000000000000000000000000000000',
};

const MINT_FEE = toWei('0.0000092');

describe('SnapFactory', () => {
  let wallet0: SignerWithAddress;
  let wallet1: SignerWithAddress;
  let wallet2: SignerWithAddress;
  let SnapFactoryContract: Contract;
  let SnapFactory: ContractFactory;

  let MintableSnapMock: MockContract;
  let MintableSnapArtifact: Artifact;

  before(async () => {
    [wallet0, wallet1, wallet2] = await getSigners();
    SnapFactory = await ethers.getContractFactory('SnapFactory');

    MintableSnapArtifact = await artifacts.readArtifact('MintableERC721Snap');
    MintableSnapMock = await deployMockContract(wallet0, MintableSnapArtifact.abi);
    // await MintableERC20Mock.mock.getAmount.returns(21554685);
    // await MintableERC20Mock.mock.getAverageBalanceBetween.returns(4654875000);
    // await MintableERC20Mock.mock.getAverageBalanceBetween
    //   .withArgs(wallet1.address, 1673802000, 1675184400)
    //   .returns(0);
    // await MintableERC20Mock.mock.getSomethingBool.returns(false);
    // await MintableERC20Mock.mock.getSomethingBool
    //   .withArgs(wallet1.address, 1673802000, 1675184400)
    //   .returns(true);
  });

  beforeEach(async () => {
    SnapFactoryContract = await SnapFactory.deploy();
  });

  describe('createSnap()', () => {
    it('should SUCCEED to create a snap', async () => {
      const result = await SnapFactoryContract.createSnap(
        'Test Snap',
        'NFTSNAP',
        contractInformation,
        'ipfs://QmXxZWr5AQf25yu1UswNm2cfGbaUbR5U3ejH1WfFEP8f1e',
        'ipfs://QmRZ86jmHScFm94hoED2FmB6SjqpuACgy6VYN5nTibxwSB',
        MINT_FEE,
        wallet0.address,
        wallet1.address,
        0,
      );
      expect(result.hash).to.not.be.undefined;
      expect(result.confirmations).to.be.greaterThan(0);
      await expect(result).to.emit(SnapFactoryContract, 'SnapMade');
      const snaps = await SnapFactoryContract.getActiveSnaps();
      expect(snaps.length).to.equal(1);
      expect(await SnapFactoryContract.isActive(snaps[0])).to.be.true;
      expect(await SnapFactoryContract.isVisible(snaps[0])).to.be.true;
    });

    it('should SUCCEED to create a snap with creator fee', async () => {
      const result = await SnapFactoryContract.createSnap(
        'Test Snap',
        'NFTSNAP',
        contractInformation,
        'ipfs://QmXxZWr5AQf25yu1UswNm2cfGbaUbR5U3ejH1WfFEP8f1e',
        'ipfs://QmRZ86jmHScFm94hoED2FmB6SjqpuACgy6VYN5nTibxwSB',
        MINT_FEE,
        wallet0.address,
        wallet1.address,
        toWei('0.045'),
      );
      expect(result.hash).to.not.be.undefined;
      expect(result.confirmations).to.be.greaterThan(0);
      await expect(result).to.emit(SnapFactoryContract, 'SnapMade');
      const snaps = await SnapFactoryContract.getActiveSnaps();
      expect(snaps.length).to.equal(1);
      expect(await SnapFactoryContract.isActive(snaps[0])).to.be.true;
      expect(await SnapFactoryContract.isVisible(snaps[0])).to.be.true;
    });

    it('should FAIL to create a snap with 0 mint fee', async () => {
      await expect(SnapFactoryContract.createSnap(
        'Test Snap',
        'NFTSNAP',
        contractInformation,
        'ipfs://QmXxZWr5AQf25yu1UswNm2cfGbaUbR5U3ejH1WfFEP8f1e',
        'ipfs://QmRZ86jmHScFm94hoED2FmB6SjqpuACgy6VYN5nTibxwSB',
        toWei('0.00000001'),
        wallet0.address,
        wallet1.address,
        0,
      )).to.be.revertedWith(
        'SnapFactory:Mint-fee-too-low',
      );
    });
  });
});
