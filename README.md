# NFT Snaps Sol Contracts

![Test](https://github.com/turbo-eth/template-hardhat-sol/actions/workflows/test.yml/badge.svg)
![TS](https://badgen.net/badge/-/TypeScript?icon=typescript&label&labelColor=blue&color=555555)
[![MIT license](https://img.shields.io/badge/License-MIT-blue.svg)](http://perso.crans.org/besson/LICENSE.html)

# Installation

Install the repo and dependencies by running:

`yarn`

## Deployment

These contracts can be deployed to a network by running:

`yarn deploy <networkName>`

## Verification

These contracts can be verified on Etherscan, or an Etherscan clone, for example (Polygonscan) by running:

`yarn etherscan-verify <ethereum network name>`

## Testing

Run the unit tests locally with:

`yarn test`

## Coverage

Generate the test coverage report with:

`yarn coverage`

# What is this ??

A simple proof of concept for NFTs that disappear after a certain amount of time. Anyone can create a NFT Snap and share with the world. Anyone is able to collect (mint) a Snap but the image and metadata visibility will expire.

- Collecting a Snap is only open for 24 hours after creation
- A Snap is only visible for 48 hours after creation
- Allows for a mint fee
- Allows for a mint price
- Token can be burned permissionlessly after visibility expires

Inspired by John Palmer
https://twitter.com/john_c_palmer/status/1635303079880040450

## Under the Hood
It's just a Factory that creates Snaps ❤

### Share Your Story
https://www.nftsnaps.xyz/

<sub>Disclaimer: This was a quick hack, use at your own risk</sub>
