// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { ISnapCore } from "./ISnapCore.sol";

interface ISnapFactory {
  event SnapMade(address indexed _snapAddress, address _creator);

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
}