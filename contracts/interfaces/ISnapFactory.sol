// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { ISnapCore } from "./ISnapCore.sol";

interface ISnapFactory {
  event SnapMade(
    address indexed _snapAddress,
    address _creator,
    uint256 _mintEndsTimestamp,
    uint256 _visibleEndsTimestamp
  );

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
  ) external returns (address snapAddress);

  function getActiveSnaps() external view returns (address[] memory snaps);

  function getVisibleSnaps() external view returns (address[] memory snaps);

  function getActiveByCreator(address _creator) external view returns (address[] memory snaps);

  function getVisibleByCreator(address _creator) external view returns (address[] memory snaps);

  function isActive(address _snap) external view returns (bool active);

  function isVisible(address _snap) external view returns (bool visible);
}
