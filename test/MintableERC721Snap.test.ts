import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import { expect } from 'chai';
import { Contract, ContractFactory } from 'ethers';
import { ethers } from 'hardhat';

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

describe('MintableERC721Snap', () => {
  let wallet0: SignerWithAddress;
  let wallet1: SignerWithAddress;
  let wallet2: SignerWithAddress;
  let MintableERC721Snap: Contract;
  let MintableERC721Factory: ContractFactory;

  before(async () => {
    [wallet0, wallet1, wallet2] = await getSigners();
    MintableERC721Factory = await ethers.getContractFactory('MintableERC721Snap');
  });

  beforeEach(async () => {
    MintableERC721Snap = await MintableERC721Factory.deploy(
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
  });

  describe('constructor', () => {
    it('should set correct owner', async () => {
      expect(await MintableERC721Snap.owner()).to.be.equal(wallet1.address);
    });
    it('should set correct sale price', async () => {
      expect(await MintableERC721Snap.getSalePrice()).to.be.equal(0);
    });
    it('should set correct mint fee', async () => {
      expect(await MintableERC721Snap.getMintFee()).to.be.equal(MINT_FEE);
    });
  });

  describe('mint(address to)', () => {
    it('should SUCCEED to mint NFT #1', async () => {
      await MintableERC721Snap.mint(wallet0.address, { value: MINT_FEE });
      expect(await MintableERC721Snap.ownerOf(1)).to.be.equal(wallet0.address);
      expect(await MintableERC721Snap.totalSupply()).to.equal(1);
    });
    it('should FAIL to mint NFT #1 - no funds', async () => {
      await expect(MintableERC721Snap.mint(wallet0.address)).to.be.revertedWith(
        'NFTSnap:insufficient-amount',
      );
      expect(await MintableERC721Snap.totalSupply()).to.equal(0);
    });
    it('should FAIL to mint NFT #1 - not enough funds', async () => {
      await expect(
        MintableERC721Snap.mint(wallet0.address, { value: toWei('0.0000091') }),
      ).to.be.revertedWith('NFTSnap:insufficient-amount');
      expect(await MintableERC721Snap.totalSupply()).to.equal(0);
    });
  });
});
