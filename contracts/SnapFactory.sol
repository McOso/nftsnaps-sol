//SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { ISnapFactory } from "./interfaces/ISnapFactory.sol";
import { ISnapCore } from "./interfaces/ISnapCore.sol";
import { MintableERC721Snap } from "./MintableERC721Snap.sol";

contract SnapFactory is ISnapFactory {
  function createSnap(string memory _name, string memory _symbol, ISnapCore.ContractURI memory _contractURI, string memory _tokenImageURL, string memory _snapImageURL, uint256 _mintFee, address payable _mintFeeRecipient, address payable _creator, uint256 _salePrice) external returns (address snapAddress) {
    MintableERC721Snap snap_ = new MintableERC721Snap(_name, _symbol, _contractURI, _tokenImageURL, _snapImageURL, _mintFee, _mintFeeRecipient, _creator, _salePrice);

    emit SnapMade(address(snap_), _creator);

    return address(snap_);
  }
}
