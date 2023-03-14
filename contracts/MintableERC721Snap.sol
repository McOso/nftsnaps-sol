//SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { Base64 } from "./utils/Base64.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { ISnapCore } from "./interfaces/ISnapCore.sol";

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract MintableERC721Snap is ERC721, Ownable, ReentrancyGuard {
  uint256 public constant MINT_LENGTH = 1 days;

  uint256 public constant VISIBLE_LENGTH = 2 days;

  uint256 public immutable MINT_ENDS;

  uint256 public immutable VISIBLE_ENDS;

  string private TOKEN_IMAGE_URL;

  string private SNAP_IMAGE_URL;

  /// @notice Mint Fee
  uint256 private immutable MINT_FEE;

  /// @notice Mint Fee Recipient
  address payable private immutable MINT_FEE_RECIPIENT;

  /// @notice Creator address
  address payable private immutable CREATOR_ADDRESS;

  /// @notice Sale price
  uint256 private salePrice;

  ISnapCore.ContractURI private contractURIData;

  /// @notice ID counter for ERC721 tokens
  uint256 private idCounter;

  constructor(
    string memory _name_,
    string memory _symbol_,
    ISnapCore.ContractURI memory _contractURI_,
    string memory _tokenImageURL_,
    string memory _snapImageURL_,
    uint256 _mintFee_,
    address payable _mintFeeRecipient_,
    address payable _creator_,
    uint256 _salePrice_
  ) ERC721(_name_, _symbol_) {
    contractURIData = _contractURI_;
    TOKEN_IMAGE_URL = _tokenImageURL_;
    SNAP_IMAGE_URL = _snapImageURL_;

    MINT_ENDS = block.timestamp + MINT_LENGTH;
    VISIBLE_ENDS = block.timestamp + VISIBLE_LENGTH;

    MINT_FEE = _mintFee_;
    MINT_FEE_RECIPIENT = _mintFeeRecipient_;

    CREATOR_ADDRESS = _creator_;

    transferOwnership(_creator_);

    salePrice = _salePrice_;
  }

  /* ===================================================================================== */
  /* EIP Functions                                                                         */
  /* ===================================================================================== */
  function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override(ERC721)
    returns (bool)
  {
    return super.supportsInterface(interfaceId);
  }

  /* ===================================================================================== */
  /* External Functions                                                                    */
  /* ===================================================================================== */

  function contractURI() external view virtual returns (string memory uri) {
    if (_isVisible()) {
      return _constructContractMeta();
    } else {
      return _constructSnapContractMeta();
    }
  }

  function totalSupply() external view returns (uint256) {
    return idCounter;
  }

  function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
    if (_isVisible()) {
      return _constructTokenMeta(_tokenId);
    } else {
      return _constructSNAPTokenMeta(_tokenId);
    }
  }

  function isMintActive() external view returns (bool active) {
    return _isMintActive();
  }

  function isVisible() external view returns (bool visible) {
    return _isVisible();
  }

  function getSalePrice() external view returns (uint256 price) {
    return salePrice;
  }

  function getMintFee() external view returns (uint256 fee) {
    return MINT_FEE;
  }

  // ========================
  // WRITES
  // ========================

  /**
   * @notice Mints a new token to the given address
   * @param _to address - Address to mint to`
   */
  function mint(address _to) external payable nonReentrant returns (uint256) {
    require(_isMintActive(), "NFTSnap:minting-ended");
    require(msg.value >= (salePrice + MINT_FEE), "NFTSnap:insufficient-amount");

    uint256 nextId_ = ++idCounter;
    _mint(_to, nextId_);

    _payoutMintFee();

    return nextId_;
  }

  /**
   * @notice Burns a token
   * @param _tokenId uint256 - Token ID to burn
   */
  function burn(uint256 _tokenId) external {
    require(_isApprovedOrOwner(_msgSender(), _tokenId), "NFTSnap:unauthorized-burn");
    _burn(_tokenId);
    --idCounter;
  }

  /**
   * @notice Sets a new Sale Price
   * @param _salePrice uint256 - Sale Price
   */
  function setSalePrice(uint256 _salePrice) external onlyOwner {
    salePrice = _salePrice;
  }

  /**
   * @notice Withdraws funds to creator
   */
  function withdraw() external onlyOwner {
    uint256 funds_ = address(this).balance;
    (bool _success, ) = CREATOR_ADDRESS.call{ value: funds_ }("");
    require(_success, "NFTSnap:funds-release-failed");
  }

  /* ===================================================================================== */
  /* Internal Functions                                                                    */
  /* ===================================================================================== */
  function _payoutMintFee() internal {
    (bool _success, ) = MINT_FEE_RECIPIENT.call{ value: MINT_FEE }("");
    require(_success, "NFTSnap:mint-fee-release-failed");
  }

  function _isMintActive() internal view returns (bool) {
    return block.timestamp < MINT_ENDS;
  }

  function _isVisible() internal view returns (bool) {
    return block.timestamp < VISIBLE_ENDS;
  }

  function _constructTokenMeta(uint256 _tokenId) internal view returns (string memory) {
    return
      string(
        abi.encodePacked(
          "data:application/json;base64,",
          Base64.encode(
            bytes(
              string.concat(
                '{"name":',
                '"',
                string.concat(contractURIData.name, " ", Strings.toString(_tokenId)),
                '",',
                '"description":',
                '"',
                contractURIData.description,
                '",',
                '"image":',
                '"',
                TOKEN_IMAGE_URL,
                '"',
                "}"
              )
            )
          )
        )
      );
  }

  function _constructSNAPTokenMeta(uint256 _tokenId) internal view returns (string memory) {
    return
      string(
        abi.encodePacked(
          "data:application/json;base64,",
          Base64.encode(
            bytes(
              string.concat(
                '{"name":',
                '"',
                Strings.toString(_tokenId),
                '",',
                '"description":',
                '"',
                "???",
                '",',
                '"image":',
                '"',
                SNAP_IMAGE_URL,
                '"',
                "}"
              )
            )
          )
        )
      );
  }

  function _constructContractMeta() internal view returns (string memory) {
    return
      string(
        abi.encodePacked(
          "data:application/json;base64,",
          Base64.encode(
            bytes(
              string.concat(
                '{"name":',
                '"',
                contractURIData.name,
                '",',
                '"description":',
                '"',
                contractURIData.description,
                '",',
                '"image":',
                '"',
                contractURIData.image,
                '",',
                '"externalLink":',
                '"',
                contractURIData.externalLink,
                '",',
                '"sellerFeeBasisPoints":',
                '"',
                contractURIData.sellerFeeBasisPoints,
                '",',
                '"feeRecipient":',
                '"',
                contractURIData.feeRecipient,
                '"',
                "}"
              )
            )
          )
        )
      );
  }

  function _constructSnapContractMeta() internal view returns (string memory) {
    return
      string(
        abi.encodePacked(
          "data:application/json;base64,",
          Base64.encode(
            bytes(
              string.concat(
                '{"name":',
                '"',
                'Expired NFT Snap",',
                '"description":',
                '"',
                '???",',
                '"image":',
                '"',
                SNAP_IMAGE_URL,
                '",',
                '"externalLink":',
                '"',
                'https://nftsnaps.xyz/",',
                '"sellerFeeBasisPoints":',
                '"',
                contractURIData.sellerFeeBasisPoints,
                '",',
                '"feeRecipient":',
                '"',
                contractURIData.feeRecipient,
                '"',
                "}"
              )
            )
          )
        )
      );
  }
}
