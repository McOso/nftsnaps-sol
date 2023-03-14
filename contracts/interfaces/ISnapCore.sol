//SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

interface ISnapCore {
  struct ContractURI {
    string name;
    string description;
    string image;
    string externalLink;
    string sellerFeeBasisPoints;
    string feeRecipient;
  }
}
