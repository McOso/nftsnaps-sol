//SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { Base64 } from "./utils/Base64.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract MintableERC721Snap is ERC721, Ownable, ReentrancyGuard {
  struct ContractURI {
    string name;
    string description;
    string image;
    string externalLink;
    string sellerFeeBasisPoints;
    string feeRecipient;
  }

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

  ContractURI private contractURI;

  /// @notice ID counter for ERC721 tokens
  uint256 private idCounter;


  constructor(
    string memory _name_, 
    string memory _symbol_,
    ContractURI memory _contractURI_,
    string memory _tokenImageURL_,
    string memory _snapImageURL_,
    uint256 _mintFee_,
    address payable _mintFeeRecipient_,
    address payable _creator_,
    uint256 _salePrice_
  ) ERC721(_name_, _symbol_) {
    contractURI = _contractURI_;
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

  function constructContractURI() external view virtual returns (string memory uri) {
    return
      string(
        abi.encodePacked(
          "data:application/json;base64,",
          Base64.encode(
            bytes(
              string.concat(
                '{"name":',
                '"',
                contractURI.name,
                '",',
                '"description":',
                '"',
                contractURI.description,
                '",',
                '"image":',
                '"',
                contractURI.image,
                '",',
                '"externalLink":',
                '"',
                contractURI.externalLink,
                '",',
                '"sellerFeeBasisPoints":',
                '"',
                contractURI.sellerFeeBasisPoints,
                '",',
                '"feeRecipient":',
                '"',
                contractURI.feeRecipient,
                '"',
                "}"
              )
            )
          )
        )
      );
  }

  function totalSupply() external view returns (uint256) {
    return idCounter;
  }

  function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
    if (block.timestamp < VISIBLE_ENDS) {
      return _constructTokenURI(_tokenId);
    }else{
      return _constructSNAPURI(_tokenId);
    }
  }

  // ========================
  // WRITES
  // ========================

  /**
   * @notice Mints a new token to the given address
   * @param _to address - Address to mint to`
   */
  function mint(address _to) external payable nonReentrant returns (uint256) {

    require(block.timestamp < MINT_ENDS, "NFTSnap:minting-ended");
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
  function burn(uint256 _tokenId) external onlyOwner {
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

  function _constructTokenURI(uint256 _tokenId) internal view returns (string memory) {
    return
      string(
        abi.encodePacked(
          "data:application/json;base64,",
          Base64.encode(
            bytes(
              string.concat(
                '{"name":',
                '"',
                string.concat(contractURI.name, " ", Strings.toString(_tokenId)),
                '",',
                '"description":',
                '"',
                contractURI.description,
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

  function _constructSNAPURI(uint256 _tokenId) internal view returns (string memory) {
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
}
