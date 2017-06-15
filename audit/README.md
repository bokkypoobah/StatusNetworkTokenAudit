# Status Network Token Audit (Work in progress)

Note that the MiniMe contract is excluded from this audit as I have been informed that this contract is already audited. See [../MINIME_README.md](../MINIME_README.md).

Auditing the master branch of commit [8ee9ea0c36a89e819210464e4d546095de37ec0c](https://github.com/status-im/status-network-token/commit/8ee9ea0c36a89e819210464e4d546095de37ec0c).

See [../README.md](../README.md) and [../SPEC.md](../SPEC.md).

<br />

<hr />

**Table of contents**

* [To Check](#to-check)
* [General Notes](#general-notes)
* [Solidity Files](#solidity-files)

<br />

<hr />

## To Check

* Where is the 1 week transfer freeze implemented?

<br />

<hr />

## General Notes

* The smart contracts and interactions between the smart contracts are of medium complexity. The whole interactions are not simple to understand, but can be understood with a bit of work.

<br />

<hr />

## Solidity Files

### ContributionWallet.sol
* [../contracts/ContributionWallet.sol](../contracts/ContributionWallet.sol)
  * This contract includes the following files:
    * [../contracts/StatusContribution.sol](../contracts/StatusContribution.sol)

<br />

### DevTokensHolder.sol
* [../contracts/DevTokensHolder.sol](../contracts/DevTokensHolder.sol)
  * This contract includes the following files:
    * [../contracts/MiniMeToken.sol](../contracts/MiniMeToken.sol)
    * [../contracts/StatusContribution.sol](../contracts/StatusContribution.sol)
    * [../contracts/SafeMath.sol](../contracts/SafeMath.sol)

<br />

### DynamicCeiling.sol
* MEDIUM IMPORTANCE - It would be easier to read if the following are renamed, as the curve is a collection of [curve] points:
  * `struct Curve` is renamed to `struct Point`
  * `Curve[] public curves;` is renamed to `Point[] public curve`
  * `function setHiddenCurves(bytes32[] _curveHashes)` is renamed to `function setHiddenPoints(bytes32[] _curveHashes)`
* [../contracts/DynamicCeiling.sol](../contracts/DynamicCeiling.sol)
  * Used in StatusContribution
  * This contract includes the following files:
    * [../contracts/SafeMath.sol](../contracts/SafeMath.sol)

<br />

### MiniMeToken.sol
* [../contracts/MiniMeToken.sol](../contracts/MiniMeToken.sol)
  * Audit not required
  * This contract does not include any other files

<br />

### MultisigWallet.sol
* [../contracts/MultisigWallet.sol](../contracts/MultisigWallet.sol)
  * This contract does not include any other files

<br />

### Owned.sol
* [x] [../contracts/Owned.sol](../contracts/Owned.sol)
  * Standard Owned or Owner pattern
  * Has just been upgraded to use the [`acceptOwnership()`](https://github.com/bokkypoobah/SikobaTokenContinuous/blob/master/contracts/SikobaContinuousSale.sol#L38-L42) confirmation.
  * This contract does not include any other files

<br />

### SafeMath.sol
* [../contracts/SafeMath.sol](../contracts/SafeMath.sol)
  * Safe maths, as a library
  * This contract does not include any other files

<br />

### SGT.sol
* [../contracts/SGT.sol](../contracts/SGT.sol)
  * SGT "Status Genesis Token"
  * 1 decimals
  * An instance of the MiniMe contract, with a `multiMint(...)` function
  * This contract includes the following files:
    * [../contracts/MiniMeToken.sol](../contracts/MiniMeToken.sol)

<br />

### SGTExchanger.sol
* [../contracts/SGTExchanger.sol](../contracts/SGTExchanger.sol)
  * For SGT tokens to be exchanged with the new SNT tokens
  * This contract includes the following files:
    * [../contracts/MiniMeToken.sol](../contracts/MiniMeToken.sol)
    * [../contracts/SafeMath.sol](../contracts/SafeMath.sol)
    * [x] [../contracts/Owned.sol](../contracts/Owned.sol)

<br />

### SNT.sol
* [../contracts/SNT.sol](../contracts/SNT.sol)
  * SNT "Status Network Token"
  * 18 decimals
  * An instance of the MiniMe contract
  * Audit not required
  * This contract includes the following files:
    * [../contracts/MiniMeToken.sol](../contracts/MiniMeToken.sol)
    * [../contracts/StatusContribution.sol](../contracts/StatusContribution.sol)
    * [../contracts/SafeMath.sol](../contracts/SafeMath.sol)
    * [x] [../contracts/Owned.sol](../contracts/Owned.sol)

<br />

### SNTPlaceHolder.sol
* [../contracts/SNTPlaceHolder.sol](../contracts/SNTPlaceHolder.sol)
  * This contract includes the following files:
    * [../contracts/MiniMeToken.sol](../contracts/MiniMeToken.sol)
    * [../contracts/StatusContribution.sol](../contracts/StatusContribution.sol)
    * [../contracts/SafeMath.sol](../contracts/SafeMath.sol)
    * [x] [../contracts/Owned.sol](../contracts/Owned.sol)

<br />

### StatusContribution.sol
* [../contracts/StatusContribution.sol](../contracts/StatusContribution.sol)
  * Calls MiniMe's `generateTokens(...)` to generate tokens according to ETH contribution and the rules
  * This contract includes the following files:
    * [x] [../contracts/Owned.sol](../contracts/Owned.sol)
    * [../contracts/MiniMeToken.sol](../contracts/MiniMeToken.sol)
    * [../contracts/DynamicCeiling.sol](../contracts/DynamicCeiling.sol)
    * [../contracts/SafeMath.sol](../contracts/SafeMath.sol)

<br />

<br />

(c) BokkyPooBah / Bok Consulting Pty Ltd for Status - June 13 2017