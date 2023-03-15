import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import { expect } from 'chai';
import { Contract, ContractFactory } from 'ethers';
import { ethers } from 'hardhat';
import { time } from "@nomicfoundation/hardhat-network-helpers";

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

const DAY_SECONDS = 86400;
const TWO_DAYS_SECONDS = 2 * DAY_SECONDS;

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
      'ipfs://QmTkCP5u95yQRr9kM513QNr5pT6DYe3sD3yn8qRi2osTPg',
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

    it('should FAIL to mint NFT #1 - minting expired', async () => {
      await time.increase(DAY_SECONDS + 1);
      await expect(
        MintableERC721Snap.mint(wallet0.address, { value: MINT_FEE }),
      ).to.be.revertedWith('NFTSnap:minting-ended');
      expect(await MintableERC721Snap.totalSupply()).to.equal(0);
    });
  });

  describe('burn()', () => {
    it('should FAIL to burn NFT - still visible', async () => {
      await MintableERC721Snap.mint(wallet0.address, { value: MINT_FEE });
      expect(await MintableERC721Snap.ownerOf(1)).to.be.equal(wallet0.address);
      expect(await MintableERC721Snap.totalSupply()).to.equal(1);

      await expect(
        MintableERC721Snap.burn(1),
      ).to.be.revertedWith('NFTSnap:unauthorized-burn');
      expect(await MintableERC721Snap.totalSupply()).to.equal(1);
    });
    it('should SUCCEED to burn NFT', async () => {
      await MintableERC721Snap.mint(wallet0.address, { value: MINT_FEE });
      expect(await MintableERC721Snap.ownerOf(1)).to.be.equal(wallet0.address);
      expect(await MintableERC721Snap.totalSupply()).to.equal(1);

      await time.increase(TWO_DAYS_SECONDS + 1);

      await MintableERC721Snap.burn(1);
      expect(await MintableERC721Snap.totalSupply()).to.equal(0);
    });

    it('should SUCCEED to burn NFT permissionlessly', async () => {
      await MintableERC721Snap.mint(wallet0.address, { value: MINT_FEE });
      expect(await MintableERC721Snap.ownerOf(1)).to.be.equal(wallet0.address);
      expect(await MintableERC721Snap.totalSupply()).to.equal(1);

      await time.increase(TWO_DAYS_SECONDS + 1);

      await MintableERC721Snap.connect(wallet1).burn(1);
      expect(await MintableERC721Snap.totalSupply()).to.equal(0);
    });
  });

  describe('metadata', () => {
    it('should get correct name', async () => {
      await MintableERC721Snap.mint(wallet0.address, { value: MINT_FEE });
      expect(await MintableERC721Snap.name()).to.be.equal('Test Snap');
    });
    it('should get correct name - expired', async () => {
      await MintableERC721Snap.mint(wallet0.address, { value: MINT_FEE });
      await time.increase(TWO_DAYS_SECONDS + 1);
      expect(await MintableERC721Snap.name()).to.be.equal('Expired NFT Snap');
    });
    it('should get correct symbol', async () => {
      await MintableERC721Snap.mint(wallet0.address, { value: MINT_FEE });
      expect(await MintableERC721Snap.symbol()).to.be.equal('NFTSNAP');
    });
    it('should get correct symbol - expired', async () => {
      await MintableERC721Snap.mint(wallet0.address, { value: MINT_FEE });
      await time.increase(TWO_DAYS_SECONDS + 1);
      expect(await MintableERC721Snap.symbol()).to.be.equal('NFTSNAP');
    });

    it('should get correct contract uri', async () => {
      await MintableERC721Snap.mint(wallet0.address, { value: MINT_FEE });
      const result = await MintableERC721Snap.contractURI();
      console.log(result)
    });
    it('should get correct contract uri - expired', async () => {
      await MintableERC721Snap.mint(wallet0.address, { value: MINT_FEE });
      await time.increase(TWO_DAYS_SECONDS + 1);
      const result = await MintableERC721Snap.contractURI();
      console.log(result)
    });

    it('should get correct token uri', async () => {
      await MintableERC721Snap.mint(wallet0.address, { value: MINT_FEE });
      const result = await MintableERC721Snap.tokenURI(1);
      console.log(result)
    });
    it('should get correct token uri - expired', async () => {
      await MintableERC721Snap.mint(wallet0.address, { value: MINT_FEE });
      await time.increase(TWO_DAYS_SECONDS + 1);
      const result = await MintableERC721Snap.tokenURI(1);
      console.log(result)
    });
  });
});
