//SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { ISnapFactory } from "./interfaces/ISnapFactory.sol";
import { ISnapCore } from "./interfaces/ISnapCore.sol";
import { MintableERC721Snap } from "./MintableERC721Snap.sol";

contract SnapFactory is ISnapFactory {
  uint256 private constant MIN_FEE = 9200 gwei;

  /// @notice mapping of all created snaps
  mapping(address => bool) private snapsMap;

  /// @notice list of all created snaps
  address[] private snapsList;

  function createSnap(
    string memory _name,
    string memory _symbol,
    ISnapCore.ContractURI memory _contractURI,
    string memory _tokenImageURL,
    string memory _snapImageURL,
    uint256 _mintFee,
    address payable _mintFeeRecipient,
    address payable _creator,
    uint256 _salePrice
  ) external returns (address snapAddress) {
    require(_mintFee >= MIN_FEE, "SnapFactory:Mint-fee-too-low");

    MintableERC721Snap snap_ = new MintableERC721Snap(
      _name,
      _symbol,
      _contractURI,
      _tokenImageURL,
      _snapImageURL,
      _mintFee,
      _mintFeeRecipient,
      _creator,
      _salePrice
    );

    snapsMap[address(snap_)] = true;
    snapsList.push(address(snap_));

    emit SnapMade(address(snap_), _creator, snap_.MINT_ENDS(), snap_.VISIBLE_ENDS());

    return address(snap_);
  }

  function getActiveSnaps() external view returns (address[] memory snaps) {
    address[] memory tempSnaps_ = new address[](snapsList.length);

    uint256 index_ = 0;
    for (uint256 i = 0; i < snapsList.length; i++) {
      if (MintableERC721Snap(snapsList[i]).isMintActive()) {
        tempSnaps_[index_++] = snapsList[i];
      }
    }

    snaps = new address[](index_);

    for (uint16 j = 0; j < index_; j++) {
      snaps[j] = tempSnaps_[j];
    }
  }

  function getVisibleSnaps() external view returns (address[] memory snaps) {
    address[] memory tempSnaps_ = new address[](snapsList.length);

    uint256 index_ = 0;
    for (uint256 i = 0; i < snapsList.length; i++) {
      if (MintableERC721Snap(snapsList[i]).isVisible()) {
        tempSnaps_[index_++] = snapsList[i];
      }
    }

    snaps = new address[](index_);

    for (uint16 j = 0; j < index_; j++) {
      snaps[j] = tempSnaps_[j];
    }
  }

  function getActiveByCreator(address _creator) external view returns (address[] memory snaps) {
    address[] memory tempSnaps_ = new address[](snapsList.length);

    uint256 index_ = 0;
    for (uint256 i = 0; i < snapsList.length; i++) {
      if (
        MintableERC721Snap(snapsList[i]).owner() == _creator &&
        MintableERC721Snap(snapsList[i]).isMintActive()
      ) {
        tempSnaps_[index_++] = snapsList[i];
      }
    }

    snaps = new address[](index_);

    for (uint16 j = 0; j < index_; j++) {
      snaps[j] = tempSnaps_[j];
    }
  }

  function getVisibleByCreator(address _creator) external view returns (address[] memory snaps) {
    address[] memory tempSnaps_ = new address[](snapsList.length);

    uint256 index_ = 0;
    for (uint256 i = 0; i < snapsList.length; i++) {
      if (
        MintableERC721Snap(snapsList[i]).owner() == _creator &&
        MintableERC721Snap(snapsList[i]).isVisible()
      ) {
        tempSnaps_[index_++] = snapsList[i];
      }
    }

    snaps = new address[](index_);

    for (uint16 j = 0; j < index_; j++) {
      snaps[j] = tempSnaps_[j];
    }
  }

  function isActive(address _snap) external view returns (bool active) {
    return snapsMap[_snap] && MintableERC721Snap(_snap).isMintActive();
  }

  function isVisible(address _snap) external view returns (bool visible) {
    return snapsMap[_snap] && MintableERC721Snap(_snap).isVisible();
  }
}
