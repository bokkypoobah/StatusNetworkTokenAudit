# Status Network Token Audit

Status is conducting a crowdsale on the Ethereum network and have developed a set of Ethereum smart contracts to receive ethers (ETH) from participants in exchange for Status Network Tokens (SNTs).

Status requested from Bok Consulting Pty Ltd some assistance in auditing their crowdsale smart contracts. Note that the MiniMe contract is excluded from this audit as this contract is already audited. See [../MINIME_README.md](../MINIME_README.md).

This audit is of the master branch of commit [2ec1fe9dcd3e2673690b5e0926d629064a65225b](https://github.com/status-im/status-network-token/commit/2ec1fe9dcd3e2673690b5e0926d629064a65225b) from [https://github.com/status-im/status-network-token](https://github.com/status-im/status-network-token).

See [../README.md](../README.md) and [../SPEC.md](../SPEC.md) for further details.

<br />

<hr />

**Table of contents**

* [Summary](#summary)
* [Recommendations](#recommendations)
* [General Notes](#general-notes)
* [Solidity Files In Scope](#solidity-files-in-scope)
  * [ContributionWallet](#contributionwallet)
  * [DevTokensHolder](#devtokensholder)
  * [DynamicCeiling](#dynamicceiling)
  * [SGTExchanger](#sgtexchanger)
  * [SNT](#snt)
  * [SNTPlaceHolder](#sntplaceholder)
  * [StatusContribution](#statuscontribution)
  * [ERC20Token](#erc20token)
  * [Owned](#owned)
  * [SafeMath](#safemath)
* [Solidity Files Out Of Scope](#solidity-files-out-of-scope)
  * [MiniMeToken](#minimetoken)
  * [SGT](#sgt)
  * [MultisigWallet](#multisigwallet)
* [References](#references)

<br />

<hr />

## Summary

The smart contracts are of medium complexity with the aim of raising funds from many individual participants rather than a smaller number of higher contributing participants, with some of the mechanisms employed being the use of hidden caps that are revealed as the crowdsale progresses.

The smart contracts are well written and have been compartmentalised into modules. Some of the complexity is in the interactions between these modules.

The highest risk module is the ContributionWallet as this contract receives and holds the ETH contributed by participants during the crowdsale. This contract has been written to be clear and simple, with as little attack surface as possible.

No serious issues have been found in the smart contracts.

Scripts to monitor the crowdsale contracts can be found in [scripts](scripts).

<br />

<hr />

## Recommendations

* There are many moving parts to this set of contracts. On deployment to Mainnet, scripts should be used to confirm the interactions, status and transactions flowing through these contracts
* VERY LOW IMPORTANCE **ContributionWallet** There is a hard coded block number that should be converted into a constant
* VERY LOW IMPORTANCE - There is no default `function ()` that rejects ethers sent to this DevTokensHolder, DynamicCeiling, SGTExchanger and SNTPlaceholder, but there are `claimTokens(0x0)` functions in these contracts that will enable the owner to manually retrieve any accidentally sent ethers, and send them back to the originating accounts if necessary

<br />

<hr />

## General Notes

* [x] The contracts and interactions between the contracts are of medium complexity
* [x] The functionality has been modularised to compartmentalise the complexity
* [x] The interactions between the modules are a bit complicated as there are different times when the different modules and functions operate
* Assessment of risks
  * [x] The high risk contract is the ContributionWallet contract as these hold the ethers raised by the crowdsale
  * [x] The other contracts are of lower risk as token contracts can be redeployed with corrected code and token balances in the case of failures, at the cost of inconvenience to users
  * [x] The `pauseContribution()` and `resumeContribution()` switch allows Status to pause and resume the crowdsale contributions lowers the risks in the event of some failures
    * As should be expected, the network may be saturated with transactions so it may be difficult to get the `pauseContribution()` transaction mined
* [x] The SNT token contract is based on the MiniMe contract that has been audited in the past, and is already in production use
  * [x] The MiniMe contract has been updated with some minor changes, mainly to allow the injection of the blocknumber for testing purposes
* [x] There is no refund functionality in this crowdsale, so the funds raised will be diverted to a less complex contract (ContributionWallet)
  * [x] The ContributionWallet contract has minimal functionality and complexity, reducing the attack surface and risk of errors
  * [x] The ContributionWallet does not have any [reentrancy](https://github.com/ConsenSys/smart-contract-best-practices#reentrancy) or [control flow hijacking](https://github.com/ConsenSys/smart-contract-best-practices#dont-make-control-flow-assumptions-after-external-calls) logic as external calls to transfer funds are only to the owner's own wallet, under the owner's control

<br />

<hr />

## Solidity Files In Scope

### ContributionWallet
* This contract will hold the funds from the crowdsale
* This contract receives the funds from the crowdsale when sent by `StatusContribution.doBuy(...)`
* [x] This contract's `withdraw()` function can only be executed by the controlling multisig and can only be executed after the sale is finalised
* [x] There are no areas with potential overflow, underflow, division, division by zero and type conversion errors
* There is a `transfer(...)` function to transfer the ethers to the multisig account within the `withdraw()` function
  * [x] This function can only be called by the multisig account
* Further comments on the code can be found in [ContributionWallet.md](ContributionWallet.md)
* Source [../contracts/ContributionWallet.sol](../contracts/ContributionWallet.sol) that includes the following file:
  * [../contracts/StatusContribution.sol](../contracts/StatusContribution.sol)

<br />

### DevTokensHolder
* This contract will hold the developers tokens from the crowdsale that are released after time delays
* [x] This contract uses the timestamp instead of block numbers to schedule the release of tokens, but this [timestamp dependence](https://github.com/ConsenSys/smart-contract-best-practices#timestamp-dependence) has no material consequences
* [x] This contract's `claimTokens(...)` have an explicit statement that prevents the owner from claiming the time locked tokens
* [x] There are areas with potential overflow, underflow and division errors but these are protected using the safe maths library
* [x] There are no areas with potential type conversion errors
* [x] The functions in this contract can only be called by the owner account
* [x] No ethers are handled by this contract other than `claimTokens(...)`
* LOW IMPORTANCE - There is no `function ()` that rejects ethers sent to this contract, but there is a `claimTokens(0x0)` to retrieve any accidentally sent ethers 
* Further comments on the code can be found in [DevTokensHolder.md](DevTokensHolder.md)
* Source [../contracts/DevTokensHolder.sol](../contracts/DevTokensHolder.sol) that includes the following files:
  * [../contracts/MiniMeToken.sol](../contracts/MiniMeToken.sol)
  * [../contracts/StatusContribution.sol](../contracts/StatusContribution.sol)
  * [../contracts/SafeMath.sol](../contracts/SafeMath.sol)
  * [../contracts/ERC20Token.sol](../contracts/ERC20Token.sol)

<br />

### DynamicCeiling
* This contract allows Status to deploy a set of hashes of soft caps on the crowdsale, and reveal these caps as the crowdsale progresses
* LOW IMPORTANCE - There is no `function ()` that rejects ethers sent to this contract, but there is a `claimTokens(0x0)` to retrieve any accidentally sent ethers 
* Further comments can be found in [DynamicCeiling.md](DynamicCeiling.md)
* LOW IMPORTANCE - It would be easier to read if the following are renamed, as the curve is a collection of [curve] points:
  * `struct Curve` is renamed to `struct Point`
  * `Curve[] public curves;` is renamed to `Point[] public curve`
  * `function setHiddenCurves(bytes32[] _curveHashes)` is renamed to `function setHiddenPoints(bytes32[] _curveHashes)`
* Source [../contracts/DynamicCeiling.sol](../contracts/DynamicCeiling.sol) that includes the following files:
  * [../contracts/SafeMath.sol](../contracts/SafeMath.sol)
  * [../contracts/Owned.sol](../contracts/Owned.sol)

<br />

### SGTExchanger
* This contract allows SGT tokens to be exchanged with the new SNT tokens
* The StatusContribution `finalize()` function places a limit on the % of SNTs that can be exchanged for SGTs
* Accounts call `collect()` to collect their SNTs based on their SGT balances
* LOW IMPORTANCE - There is no `function ()` that rejects ethers sent to this contract, but there is a `claimTokens(0x0)` to retrieve any accidentally sent ethers 
* Further comments on the code can be found in [SGTExchanger.md](SGTExchanger.md)
* Source [../contracts/SGTExchanger.sol](../contracts/SGTExchanger.sol) that includes the following files:
  * [../contracts/MiniMeToken.sol](../contracts/MiniMeToken.sol)
  * [../contracts/SafeMath.sol](../contracts/SafeMath.sol)
  * [../contracts/Owned.sol](../contracts/Owned.sol)
  * [../contracts/StatusContribution.sol](../contracts/StatusContribution.sol)
  * [../contracts/ERC20Token.sol](../contracts/ERC20Token.sol)

<br />

### SNT
* SNT "Status Network Token" with 18 decimal places
* An instance of the MiniMe contract
* Source [../contracts/SNT.sol](../contracts/SNT.sol) that includes the following files:
  * [../contracts/MiniMeToken.sol](../contracts/MiniMeToken.sol)

<br />

### SNTPlaceHolder
* LOW IMPORTANCE - There is no `function ()` that rejects ethers sent to this contract, but there is a `claimTokens(0x0)` to retrieve any accidentally sent ethers 
* Further commments on the code can be found in [SNTPlaceHolder.md](SNTPlaceHolder.md)
* Source [../contracts/SNTPlaceHolder.sol](../contracts/SNTPlaceHolder.sol) that includes the following files:
  * [../contracts/MiniMeToken.sol](../contracts/MiniMeToken.sol)
  * [../contracts/StatusContribution.sol](../contracts/StatusContribution.sol)
  * [../contracts/SafeMath.sol](../contracts/SafeMath.sol)
  * [../contracts/Owned.sol](../contracts/Owned.sol)
  * [../contracts/ERC20Token.sol](../contracts/ERC20Token.sol)

<br />

### StatusContribution
* Accepts ethers, calculated token amounts, forwards ethers to ContributionWallet, finalises the crowdsale
* Calls MiniMe's `generateTokens(...)` to generate tokens according to ETH contribution and the rules
* Further comments on the code can be found in [StatusContribution.md](StatusContribution.md)
* Source [../contracts/StatusContribution.sol](../contracts/StatusContribution.sol) that includes the following files:
  * [../contracts/Owned.sol](../contracts/Owned.sol)
  * [../contracts/MiniMeToken.sol](../contracts/MiniMeToken.sol)
  * [../contracts/DynamicCeiling.sol](../contracts/DynamicCeiling.sol)
  * [../contracts/SafeMath.sol](../contracts/SafeMath.sol)
  * [../contracts/ERC20Token.sol](../contracts/ERC20Token.sol)

<br />

### ERC20Token
* [x] Matches https://github.com/ethereum/EIPs/issues/20
* ERC20 interface with declaration of `totalSupply`, and `Transfer(...)` and `Approval(...)` events
* Source [../contracts/ERC20Token.sol](../contracts/ERC20Token.sol) that does not include any other files

<br />

### Owned
* [x] Implemented functionality looks correct
* Standard Owned or Owner pattern
* Was upgraded to use the `acceptOwnership()`confirmation recently which is good
* Source [../contracts/Owned.sol](../contracts/Owned.sol) that does not include any other files

<br />

### SafeMath
* Safe maths, as a library
* Source [../contracts/SafeMath.sol](../contracts/SafeMath.sol) that does not include any other files

<br />

<hr />

## Solidity Files Out Of Scope

### MiniMeToken
* Audit not required as this contract has already been audited by other parties
* Source [../contracts/MiniMeToken.sol](../contracts/MiniMeToken.sol) that includes the following files:
  * [../contracts/ERC20Token.sol](../contracts/ERC20Token.sol)

<br />

### SGT
* Audit not required as this contract is already deployed
* SGT "Status Genesis Token" with 1 decimal place
* This is an instance of the MiniMe contract, with a `multiMint(...)` function, with sample usage transaction at [0xd6bf8620](https://etherscan.io/tx/0xd6bf86202e427bf9c50f0044260e850abd828e2469f279c927201d611ddb78e7)
* Already deployed to Mainnet at [0xd248B0D48E44aaF9c49aea0312be7E13a6dc1468](https://etherscan.io/address/0xd248B0D48E44aaF9c49aea0312be7E13a6dc1468#code)
* Token transfer view at [0xd248b0d48e44aaf9c49aea0312be7e13a6dc1468](https://etherscan.io/token/0xd248b0d48e44aaf9c49aea0312be7e13a6dc1468)
* Source [../contracts/SGT.sol](../contracts/SGT.sol) that includes the following file:
  * [../contracts/MiniMeToken.sol](../contracts/MiniMeToken.sol)

<br />

### MultisigWallet
* This is a copy of a [multisig wallet](https://github.com/ConsenSys/MultiSigWallet/blob/e3240481928e9d2b57517bd192394172e31da487/contracts/solidity/MultiSigWallet.sol) by Consensys with the Solidity version updated from `0.4.4` to `^0.4.11` and the event parameter names prefixed with `_`s
* Audit not required
* Source [../contracts/MultisigWallet.sol](../contracts/MultisigWallet.sol) that does not include any other files

<br />

## References

* [Ethereum Contract Security Techniques and Tips](https://github.com/ConsenSys/smart-contract-best-practices)
* Solidity [bugs.json](https://github.com/ethereum/solidity/blob/develop/docs/bugs.json) and [bugs_by_version.json](https://github.com/ethereum/solidity/blob/develop/docs/bugs_by_version.json)

<br />

<br />

(c) BokkyPooBah / Bok Consulting Pty Ltd for Status - June 20 2017