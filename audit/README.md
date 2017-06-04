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
* [Initial Review Of Solidity Files](#initial-review-of-solidity-files)

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
* [../contracts/ContributionWallet.sol](../contracts/ContributionWallet.sol)
* [../contracts/DevTokensHolder.sol](../contracts/DevTokensHolder.sol)
* [../contracts/DynamicCeiling.sol](../contracts/DynamicCeiling.sol)
* [../contracts/MiniMeToken.sol](../contracts/MiniMeToken.sol)
* [../contracts/MultisigWallet.sol](../contracts/MultisigWallet.sol)
* [../contracts/Owned.sol](../contracts/Owned.sol)
* [../contracts/SafeMath.sol](../contracts/SafeMath.sol)
* [../contracts/SGT.sol](../contracts/SGT.sol)
* [../contracts/SGTExchanger.sol](../contracts/SGTExchanger.sol)
* [../contracts/SNT.sol](../contracts/SNT.sol)
* [../contracts/SNTPlaceHolder.sol](../contracts/SNTPlaceHolder.sol)
* [../contracts/StatusContribution.sol](../contracts/StatusContribution.sol)

<br />

<hr />

## Initial Review Of Solidity Files

* [../contracts/Owned.sol](../contracts/Owned.sol)
  * Standard Owned or Owner pattern.
  * **NOTE** Could be improved by an acceptOwnership confirmation.

* [../contracts/SafeMath.sol](../contracts/SafeMath.sol)
  * Safe maths
  * The safe*, min* and max* functions look reasonable.
  * **NOTE** `assert(...)` is included in [Solidity v0.4.10](https://github.com/ethereum/solidity/releases/tag/v0.4.10)

* [../contracts/SNT.sol](../contracts/SNT.sol)
  * SNT Status Network Token
  * An instance of the MiniMe contract
  * Audit not required

* [../contracts/ContributionWallet.sol](../contracts/ContributionWallet.sol)
* [../contracts/DevTokensHolder.sol](../contracts/DevTokensHolder.sol)
* [../contracts/DynamicCeiling.sol](../contracts/DynamicCeiling.sol)
  * Used in StatusContribution

* [../contracts/MiniMeToken.sol](../contracts/MiniMeToken.sol)
  * Audit not required

* [../contracts/MultisigWallet.sol](../contracts/MultisigWallet.sol)
* [../contracts/SGT.sol](../contracts/SGT.sol)
  * SGT Status Genesis Token
  * An instance of the MiniMe contract, with a `multiMint(...)` function

* [../contracts/SGTExchanger.sol](../contracts/SGTExchanger.sol)
  * For SGT tokens to be exchanged with the new SNT tokens

* [../contracts/SNTPlaceHolder.sol](../contracts/SNTPlaceHolder.sol)

* [../contracts/StatusContribution.sol](../contracts/StatusContribution.sol)
  * Calls MiniMe's `generateTokens(...)` to generate tokens according to ETH contribution and the rules


<br />

<br />

(c) BokkyPooBah / Bok Consulting Pty Ltd - June 04 2017