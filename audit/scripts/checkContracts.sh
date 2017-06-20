#!/bin/sh

geth attach << EOF | grep "RESULT: " | sed "s/RESULT: //"
loadScript("abi.js");

// MinimeTokenFactory for SGT
var sgtMinimeTokenFactoryAddress="0x1308a7ec3e82bcd3b63ada5f5dc27586ad8605ba";
// SGT address
var sgtAddress="0xd248b0d48e44aaf9c49aea0312be7e13a6dc1468";
// Max SGT Supply
var sgtMaxSupply=500000000;
// MinimeTokenFactory for SNT
var sntMinimeTokenFactoryAddress="0xa1c957c0210397d2d0296341627b74411756d476";
// SNT address
var sntAddress="0x744d70fdbe2ba4cf95131626614a1763df805b9e";
// StatusContribution Address
var statusContributionAddress="0x55d34b686aa8C04921397c5807DB9ECEdba00a4c";
// DynamicCeiling Address
var dynamicCeilingAddress="0xc636e73Ff29fAEbCABA9E0C3f6833EaD179FFd5c";
// Contribution Wallet Address
var contributionWalletAddress="0x2fdfdc48b4ca0021e4c629f137d151b5910e6cd0";
// DevTokensHolder Address
var devTokensHolderAddress="0xf348717cfff01edc759a4e0cb198f6360975ee39";
// SGTExchanger Address
var sgtExchangerAddress="0x20a7b20b9c213e6705c72a4216fdbc628a29d06c";
// SNTPlaceHolder Address
var sntPlaceHolderAddress="0x52ae2b53c847327f95a5084a7c38c0adb12fd302";


// -----------------------------------------------------------------------------
// SGT token contract details
// -----------------------------------------------------------------------------
var sgtDetailsFromBlock = 3727421;
function printSgtContractDetails() {
  if (sgtAddress != null && sgtAbi != null) {
    var contract = eth.contract(sgtAbi).at(sgtAddress);
    var decimals = contract.decimals();
    console.log("RESULT: sgt.address=" + sgtAddress);
    console.log("RESULT: sgt.symbol=" + contract.symbol());
    console.log("RESULT: sgt.name=" + contract.name());
    console.log("RESULT: sgt.decimals=" + contract.decimals());
    console.log("RESULT: sgt.totalSupply=" + contract.totalSupply().shift(-decimals));

    var latestBlock = eth.blockNumber;
    var i;

    var approvalEvents = contract.Approval({}, { fromBlock: sgtDetailsFromBlock, toBlock: latestBlock });
    i = 0;
    approvalEvents.watch(function (error, result) {
      console.log("RESULT: " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    approvalEvents.stopWatching();

    var transferEvents = contract.Transfer({}, { fromBlock: sgtDetailsFromBlock, toBlock: latestBlock });
    i = 0;
    transferEvents.watch(function (error, result) {
      console.log("RESULT: " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    transferEvents.stopWatching();

    sgtDetailsFromBlock = latestBlock + 1;
  }
}


//-----------------------------------------------------------------------------
// SNT token contract details
//-----------------------------------------------------------------------------
var sntDetailsFromBlock = 3898960;
function printSntContractDetails() {
  if (sntAddress != null && sntAbi != null) {
    var contract = eth.contract(sntAbi).at(sntAddress);
    var decimals = contract.decimals();
    console.log("RESULT: snt.address=" + sntAddress);
    console.log("RESULT: snt.symbol=" + contract.symbol());
    console.log("RESULT: snt.name=" + contract.name());
    console.log("RESULT: snt.decimals=" + contract.decimals());
    console.log("RESULT: snt.totalSupply=" + contract.totalSupply().shift(-decimals));
    console.log("RESULT: snt.controller=" + contract.controller());

    var latestBlock = eth.blockNumber;
    var i;

    var approvalEvents = contract.Approval({}, { fromBlock: sntDetailsFromBlock, toBlock: latestBlock });
    i = 0;
    approvalEvents.watch(function (error, result) {
      console.log("RESULT: " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    approvalEvents.stopWatching();

    var transferEvents = contract.Transfer({}, { fromBlock: sntDetailsFromBlock, toBlock: latestBlock });
    i = 0;
    transferEvents.watch(function (error, result) {
      console.log("RESULT: " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    transferEvents.stopWatching();

    sntDetailsFromBlock = latestBlock + 1;
  }
}


//-----------------------------------------------------------------------------
// StatusContribution contract details
//-----------------------------------------------------------------------------
var statusContributionDetailsFromBlock = 3899042;
function printStatusContributionContractDetails() {
  if (statusContributionAddress != null && statusContributionAbi != null) {
    var contract = eth.contract(statusContributionAbi).at(statusContributionAddress);
    var decimals = 18;
    console.log("RESULT: statusContribution.address=" + statusContributionAddress);
    console.log("RESULT: statusContribution.failSafeLimit=" + contract.failSafeLimit().shift(-18) + " ETH");
    console.log("RESULT: statusContribution.maxGuaranteedLimit=" + contract.maxGuaranteedLimit().shift(-18) + " ETH");
    console.log("RESULT: statusContribution.exchangeRate=" + contract.exchangeRate());
    console.log("RESULT: statusContribution.maxGasPrice=" + contract.maxGasPrice().shift(-18).toFixed(18) + " ETH");
    console.log("RESULT: statusContribution.maxCallFrequency=" + contract.maxCallFrequency());
    console.log("RESULT: statusContribution.SGT=" + contract.SGT());
    console.log("RESULT: statusContribution.SNT=" + contract.SNT());
    console.log("RESULT: statusContribution.startBlock=" + contract.startBlock());
    console.log("RESULT: statusContribution.endBlock=" + contract.endBlock());
    console.log("RESULT: statusContribution.destEthDevs=" + contract.destEthDevs());
    console.log("RESULT: statusContribution.destTokensDevs=" + contract.destTokensDevs());
    console.log("RESULT: statusContribution.destTokensReserve=" + contract.destTokensReserve());
    console.log("RESULT: statusContribution.maxSGTSupply=" + contract.maxSGTSupply());
    console.log("RESULT: statusContribution.destTokensSgt=" + contract.destTokensSgt());
    console.log("RESULT: statusContribution.dynamicCeiling=" + contract.dynamicCeiling());
    console.log("RESULT: statusContribution.sntController=" + contract.sntController());
    console.log("RESULT: statusContribution.totalGuaranteedCollected=" + contract.totalGuaranteedCollected());
    console.log("RESULT: statusContribution.totalNormalCollected=" + contract.totalNormalCollected());
    console.log("RESULT: statusContribution.finalizedBlock=" + contract.finalizedBlock());
    console.log("RESULT: statusContribution.finalizedTime=" + contract.finalizedTime() + " " + new Date(contract.finalizedTime() * 1000).toUTCString());

    var latestBlock = eth.blockNumber;
    var i;

    var claimedTokensEvents = contract.ClaimedTokens({}, { fromBlock: statusContributionDetailsFromBlock, toBlock: latestBlock });
    i = 0;
    claimedTokensEvents.watch(function (error, result) {
      console.log("RESULT: " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    claimedTokensEvents.stopWatching();

    var newSaleEvents = contract.NewSale({}, { fromBlock: statusContributionDetailsFromBlock, toBlock: latestBlock });
    i = 0;
    newSaleEvents.watch(function (error, result) {
      console.log("RESULT: " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    newSaleEvents.stopWatching();

    var guaranteedAddressEvents = contract.GuaranteedAddress({}, { fromBlock: statusContributionDetailsFromBlock, toBlock: latestBlock });
    i = 0;
    guaranteedAddressEvents.watch(function (error, result) {
      console.log("RESULT: " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    guaranteedAddressEvents.stopWatching();

    var finalizedEvents = contract.Finalized({}, { fromBlock: statusContributionDetailsFromBlock, toBlock: latestBlock });
    i = 0;
    finalizedEvents.watch(function (error, result) {
      console.log("RESULT: " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    finalizedEvents.stopWatching();

    statusContributionDetailsFromBlock = latestBlock + 1;
  }
}


//-----------------------------------------------------------------------------
// ContributionWallet contract details
//-----------------------------------------------------------------------------
function printContributionWalletContractDetails() {
  if (contributionWalletAddress != null && contributionWalletAbi != null) {
    var contract = eth.contract(contributionWalletAbi).at(contributionWalletAddress);
    console.log("RESULT: contributionWallet.address=" + contributionWalletAddress);
    console.log("RESULT: contributionWallet.multisig=" + contract.multisig());
    console.log("RESULT: contributionWallet.endBlock=" + contract.endBlock());
    console.log("RESULT: contributionWallet.contribution=" + contract.contribution());
  }
}


//-----------------------------------------------------------------------------
// DevTokensHolder contract details
//-----------------------------------------------------------------------------
var devTokensHolderDetailsFromBlock = 3899557;
function printDevTokensHolderContractDetails() {
  if (devTokensHolderAddress != null && devTokensHolderAbi != null) {
    var contract = eth.contract(devTokensHolderAbi).at(devTokensHolderAddress);
    console.log("RESULT: devTokensHolder.address=" + devTokensHolderAddress);
    // Not public console.log("RESULT: devTokensHolder.collectedTokens=" + contract.collectedTokens().shift(-18));
    // Not public console.log("RESULT: devTokensHolder.contribution=" + contract.contribution());
    // Not public console.log("RESULT: devTokensHolder.snt=" + contract.snt());

    var latestBlock = eth.blockNumber;
    var i;

    var claimedTokensEvents = contract.ClaimedTokens({}, { fromBlock: devTokensHolderDetailsFromBlock, toBlock: latestBlock });
    i = 0;
    claimedTokensEvents.watch(function (error, result) {
      console.log("RESULT: " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    claimedTokensEvents.stopWatching();

    var tokensWithdrawnEvents = contract.TokensWithdrawn({}, { fromBlock: devTokensHolderDetailsFromBlock, toBlock: latestBlock });
    i = 0;
    tokensWithdrawnEvents.watch(function (error, result) {
      console.log("RESULT: " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    tokensWithdrawnEvents.stopWatching();

    devTokensHolderDetailsFromBlock = latestBlock + 1;
  }
}


//-----------------------------------------------------------------------------
// SGTExchanger contract details
//-----------------------------------------------------------------------------
var sgtExchangerDetailsFromBlock = 3899499;
function printSgtExchangerContractDetails() {
  if (sgtExchangerAddress != null && sgtExchangerAbi != null) {
    var contract = eth.contract(sgtExchangerAbi).at(sgtExchangerAddress);
    console.log("RESULT: sgtExchanger.address=" + sgtExchangerAddress);
    console.log("RESULT: sgtExchanger.totalCollected=" + contract.totalCollected().shift(-18));
    console.log("RESULT: sgtExchanger.sgt=" + contract.sgt());
    console.log("RESULT: sgtExchanger.snt=" + contract.snt());
    console.log("RESULT: sgtExchanger.statusContribution=" + contract.statusContribution());

    var latestBlock = eth.blockNumber;
    var i;

    var claimedTokensEvents = contract.ClaimedTokens({}, { fromBlock: sgtExchangerDetailsFromBlock, toBlock: latestBlock });
    i = 0;
    claimedTokensEvents.watch(function (error, result) {
      console.log("RESULT: " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    claimedTokensEvents.stopWatching();

    var tokensCollectedEvents = contract.TokensCollected({}, { fromBlock: sgtExchangerDetailsFromBlock, toBlock: latestBlock });
    i = 0;
    tokensCollectedEvents.watch(function (error, result) {
      console.log("RESULT: " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    tokensCollectedEvents.stopWatching();

    sgtExchangerDetailsFromBlock = latestBlock + 1;
  }
}


//-----------------------------------------------------------------------------
// SNTPlaceHolder contract details
//-----------------------------------------------------------------------------
var sntPlaceHolderDetailsFromBlock = 3899582;
function printSntPlaceHolderContractDetails() {
  if (sntPlaceHolderAddress != null && sntPlaceHolderAbi != null) {
    var contract = eth.contract(sntPlaceHolderAbi).at(sntPlaceHolderAddress);
    console.log("RESULT: sntPlaceHolder.address=" + sntPlaceHolderAddress);
    console.log("RESULT: sntPlaceHolder.snt=" + contract.snt());
    console.log("RESULT: sntPlaceHolder.contribution=" + contract.contribution());
    console.log("RESULT: sntPlaceHolder.activationTime=" + contract.activationTime() + " " + 
        new Date(contract.activationTime() * 1000).toUTCString());
    console.log("RESULT: sntPlaceHolder.sgtExchanger=" + contract.sgtExchanger());

    var latestBlock = eth.blockNumber;
    var i;

    var claimedTokensEvents = contract.ClaimedTokens({}, { fromBlock: sntPlaceHolderDetailsFromBlock, toBlock: latestBlock });
    i = 0;
    claimedTokensEvents.watch(function (error, result) {
      console.log("RESULT: " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    claimedTokensEvents.stopWatching();

    var controllerChangedEvents = contract.ControllerChanged({}, { fromBlock: sntPlaceHolderDetailsFromBlock, toBlock: latestBlock });
    i = 0;
    controllerChangedEvents.watch(function (error, result) {
      console.log("RESULT: " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    controllerChangedEvents.stopWatching();

    sntPlaceHolderDetailsFromBlock = latestBlock + 1;
  }
}


//-----------------------------------------------------------------------------
// DynamicCeiling contract details
//-----------------------------------------------------------------------------
var dynamicCeilingFromBlock = 3899105;
function printDynamicCeilingDetails() {
  if (dynamicCeilingAddress != null && dynamicCeilingAbi != null) {
    var contract = eth.contract(dynamicCeilingAbi).at(dynamicCeilingAddress);
    console.log("RESULT: dynamicCeiling.address=" + dynamicCeilingAddress);
    console.log("RESULT: dynamicCeiling.owner=" + contract.owner());
    console.log("RESULT: dynamicCeiling.contribution=" + contract.contribution());
    console.log("RESULT: dynamicCeiling.currentIndex=" + contract.currentIndex());
    console.log("RESULT: dynamicCeiling.revealedCurves=" + contract.revealedCurves());
    console.log("RESULT: dynamicCeiling.allRevealed=" + contract.allRevealed());
    console.log("RESULT: dynamicCeiling.nCurves=" + contract.nCurves());

    var latestBlock = eth.blockNumber;
    var i;
    for (i = 0; i < contract.nCurves(); i++) {
      console.log("RESULT: dynamicCeiling.curves(" + i + ")=" + JSON.stringify(contract.curves(i)));
    }
    dynamicCeilingFromBlock = latestBlock + 1;
  }
}

printSgtContractDetails();
printSntContractDetails();
printStatusContributionContractDetails();
printContributionWalletContractDetails();
printDevTokensHolderContractDetails();
printSgtExchangerContractDetails();
printSntPlaceHolderContractDetails();
printDynamicCeilingDetails();

EOF
