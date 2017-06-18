# Status Network Token Audit (Work in progress)

Note that the MiniMe contract is excluded from this audit as I have been informed that this contract is already audited. See [../MINIME_README.md](../MINIME_README.md).

Auditing the master branch of commit [8ee9ea0c36a89e819210464e4d546095de37ec0c](https://github.com/status-im/status-network-token/commit/8ee9ea0c36a89e819210464e4d546095de37ec0c).

See [../README.md](../README.md) and [../SPEC.md](../SPEC.md).

<br />

<hr />

**Table of contents**

* [To Check](#to-check)
* [To Test](#to-test)
* [General Notes](#general-notes)
* [Solidity Files](#solidity-files)
* [Solidity Files In Scope](#solidity-files-in-scope)
* [Solidity Files Out Of Scope](#solidity-files-out-of-scope)

<br />

<hr />

## To Check

* Where is the 1 week transfer freeze implemented?

<br />

<hr />

## To Test

* ContributionWallet.sol
  * Can receive funds during the crowdsale
  * Can release the funds at the right time
* DevTokensHolder.sol
  * Can receive tokens during the crowdsale
  * Can release tokens at the right time

<br />

<hr />

## General Notes

* The smart contracts and interactions between the smart contracts are of medium complexity. The whole interactions are not simple to understand, but can be understood with a bit of work.

<br />

<hr />

## Solidity Files In Scope

### ContributionWallet.sol
* My comments on the code can be found in [ContributionWallet.md](ContributionWallet.md)
* Source [../contracts/ContributionWallet.sol](../contracts/ContributionWallet.sol) that includes the following file:
  * [../contracts/StatusContribution.sol](../contracts/StatusContribution.sol)

<br />

### DevTokensHolder.sol
* My comments on the code can be found in [DevTokensHolder.md](DevTokensHolder.md)
* Source [../contracts/DevTokensHolder.sol](../contracts/DevTokensHolder.sol) that includes the following files:
  * [../contracts/MiniMeToken.sol](../contracts/MiniMeToken.sol)
  * [../contracts/StatusContribution.sol](../contracts/StatusContribution.sol)
  * [../contracts/SafeMath.sol](../contracts/SafeMath.sol)
  * [../contracts/ERC20Token.sol](../contracts/ERC20Token.sol)

<br />

### DynamicCeiling.sol
* TODO - My comments on the code can be found in [DynamicCeiling.md](DynamicCeiling.md)
* MEDIUM IMPORTANCE - It would be easier to read if the following are renamed, as the curve is a collection of [curve] points:
  * `struct Curve` is renamed to `struct Point`
  * `Curve[] public curves;` is renamed to `Point[] public curve`
  * `function setHiddenCurves(bytes32[] _curveHashes)` is renamed to `function setHiddenPoints(bytes32[] _curveHashes)`
* Used in StatusContribution
* Source [../contracts/DynamicCeiling.sol](../contracts/DynamicCeiling.sol) that includes the following files:
  * [../contracts/SafeMath.sol](../contracts/SafeMath.sol)
  * [../contracts/Owned.sol](../contracts/Owned.sol)

<br />

### ERC20Token.sol
* ERC20 interface with declaration of `totalSupply`, and `Transfer(...)` and `Approval(...)` events
* Source [../contracts/ERC20Token.sol](../contracts/ERC20Token.sol) that does not include any other files

<br />

### Owned.sol
* Standard Owned or Owner pattern
* Implemented functionality looks correct
* Was upgraded to use the `acceptOwnership()`confirmation recently which is good
* Source [../contracts/Owned.sol](../contracts/Owned.sol) that does not include any other files

<br />

### SafeMath.sol
* Safe maths, as a library
* Source [../contracts/SafeMath.sol](../contracts/SafeMath.sol) that does not include any other files

<br />

### SGTExchanger.sol
* TODO - My comments on the code can be found in [SGTExchanger.md](SGTExchanger.md)
* For SGT tokens to be exchanged with the new SNT tokens
* Source [../contracts/SGTExchanger.sol](../contracts/SGTExchanger.sol) that includes the following files:
  * [../contracts/MiniMeToken.sol](../contracts/MiniMeToken.sol)
  * [../contracts/SafeMath.sol](../contracts/SafeMath.sol)
  * [../contracts/Owned.sol](../contracts/Owned.sol)
  * [../contracts/StatusContribution.sol](../contracts/StatusContribution.sol)
  * [../contracts/ERC20Token.sol](../contracts/ERC20Token.sol)

<br />

### SNT.sol
* SNT "Status Network Token" with 18 decimal places
* An instance of the MiniMe contract
* Source [../contracts/SNT.sol](../contracts/SNT.sol) that includes the following files:
  * [../contracts/MiniMeToken.sol](../contracts/MiniMeToken.sol)

<br />

### SNTPlaceHolder.sol
* TODO - My comments on the code can be found in [SNTPlaceHolder.md](SNTPlaceHolder.md)
* Source [../contracts/SNTPlaceHolder.sol](../contracts/SNTPlaceHolder.sol) that includes the following files:
  * [../contracts/MiniMeToken.sol](../contracts/MiniMeToken.sol)
  * [../contracts/StatusContribution.sol](../contracts/StatusContribution.sol)
  * [../contracts/SafeMath.sol](../contracts/SafeMath.sol)
  * [../contracts/Owned.sol](../contracts/Owned.sol)
  * [../contracts/ERC20Token.sol](../contracts/ERC20Token.sol)

<br />

### StatusContribution.sol
* TODO - My comments on the code can be found in [StatusContribution.md](StatusContribution.md)
* Calls MiniMe's `generateTokens(...)` to generate tokens according to ETH contribution and the rules
* Source [../contracts/StatusContribution.sol](../contracts/StatusContribution.sol) that includes the following files:
  * [../contracts/Owned.sol](../contracts/Owned.sol)
  * [../contracts/MiniMeToken.sol](../contracts/MiniMeToken.sol)
  * [../contracts/DynamicCeiling.sol](../contracts/DynamicCeiling.sol)
  * [../contracts/SafeMath.sol](../contracts/SafeMath.sol)
  * [../contracts/ERC20Token.sol](../contracts/ERC20Token.sol)

<br />

<hr />

## Solidity Files Out Of Scope

### MiniMeToken.sol
* Audit not required as this contract has already been audited by other parties
* Source [../contracts/MiniMeToken.sol](../contracts/MiniMeToken.sol) that includes the following files:
  * [../contracts/ERC20Token.sol](../contracts/ERC20Token.sol)

<br />

### SGT.sol
* Audit not required as this contract is already deployed
* SGT "Status Genesis Token" with 1 decimal place
* This is an instance of the MiniMe contract, with a `multiMint(...)` function, with sample usage transaction at [0xd6bf8620](https://etherscan.io/tx/0xd6bf86202e427bf9c50f0044260e850abd828e2469f279c927201d611ddb78e7)
* Already deployed to Mainnet at [0xd248B0D48E44aaF9c49aea0312be7E13a6dc1468](https://etherscan.io/address/0xd248B0D48E44aaF9c49aea0312be7E13a6dc1468#code)
* Token transfer view at [0xd248b0d48e44aaf9c49aea0312be7e13a6dc1468](https://etherscan.io/token/0xd248b0d48e44aaf9c49aea0312be7e13a6dc1468)
* Source [../contracts/SGT.sol](../contracts/SGT.sol) that includes the following file:
  * [../contracts/MiniMeToken.sol](../contracts/MiniMeToken.sol)

<br />

### MultisigWallet.sol
* This is a copy of a [multisig wallet](https://github.com/ConsenSys/MultiSigWallet/blob/e3240481928e9d2b57517bd192394172e31da487/contracts/solidity/MultiSigWallet.sol) by Consensys with the Solidity version updated from `0.4.4` to `^0.4.11` and the event parameter names prefixed with `_`s
* Audit not required
* Source [../contracts/MultisigWallet.sol](../contracts/MultisigWallet.sol) that does not include any other files

<br />

<br />

(c) BokkyPooBah / Bok Consulting Pty Ltd for Status - June 13 2017