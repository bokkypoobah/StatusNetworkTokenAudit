// Jun 15 2017
var ethPriceUSD = 343.0400;

// -----------------------------------------------------------------------------
// Accounts
// -----------------------------------------------------------------------------
var accounts = [];
var accountNames = {};

addAccount(eth.accounts[0], "Account #0 - Miner");
addAccount(eth.accounts[1], "Account #1 - Status");
addAccount(eth.accounts[2], "Account #2 - Community");
addAccount(eth.accounts[3], "Account #3 - Reserve");
addAccount(eth.accounts[4], "Account #4 - Devs");
addAccount(eth.accounts[5], "Account #5 - SGTHolder");
addAccount(eth.accounts[6], "Account #6 - Guaranteed");
addAccount(eth.accounts[7], "Account #7 - Contribution Wallet");
addAccount(eth.accounts[8], "Account #8");
addAccount(eth.accounts[9], "Account #9");
// addAccount(eth.accounts[10], "Account #10");
// addAccount(eth.accounts[11], "Account #11");
// addAccount(eth.accounts[12], "Account #12");
// addAccount(eth.accounts[13], "Account #13");
// addAccount(eth.accounts[14], "Account #14");
// addAccount(eth.accounts[15], "Account #15");

var minerAccount = eth.accounts[0];
var statusAccount = eth.accounts[1];
var communityAccount = eth.accounts[2];
var reserveAccount = eth.accounts[3];
var devAccount = eth.accounts[4];
var sgtHolderAccount = eth.accounts[5];
var guaranteedAccount = eth.accounts[6];
var contributionWallet = eth.accounts[7];
var account8 = eth.accounts[8];
var account9 = eth.accounts[9];

var baseBlock = eth.blockNumber;

function unlockAccounts(password) {
  for (var i = 0; i < accounts.length; i++) {
    personal.unlockAccount(eth.accounts[i], password, 100000);
  }
}

function addAccount(account, accountName) {
  accounts.push(account);
  accountNames[account] = accountName;
}

// -----------------------------------------------------------------------------
// Token contracts
// -----------------------------------------------------------------------------
var sgtContractAddress = null;
var sgtContractAbi = null;
var sntContractAddress = null;
var sntContractAbi = null;

function addSgtContractAddressAndAbi(address, tokenAbi) {
  sgtContractAddress = address;
  sgtContractAbi = tokenAbi;
}

function addSntContractAddressAndAbi(address, tokenAbi) {
  sntContractAddress = address;
  sntContractAbi = tokenAbi;
}


// -----------------------------------------------------------------------------
// Account ETH and token balances
// -----------------------------------------------------------------------------
function printBalances() {
  var sgt = sgtContractAddress == null || sgtContractAbi == null ? null : web3.eth.contract(sgtContractAbi).at(sgtContractAddress);
  var snt = sntContractAddress == null || sntContractAbi == null ? null : web3.eth.contract(sntContractAbi).at(sntContractAddress);
  var sgtDecimals = sgt == null ? 1 : sgt.decimals();
  var sntDecimals = snt == null ? 18 : snt.decimals();
  var i = 0;
  var totalSgtBalance = new BigNumber(0);
  var totalSntBalance = new BigNumber(0);
  console.log("RESULT:  # Account                                             EtherBalanceChange           SGT                            SNT Name");
  console.log("RESULT: -- ------------------------------------------ --------------------------- ------------- ------------------------------ ---------------------------");
  accounts.forEach(function(e) {
    var etherBalanceBaseBlock = eth.getBalance(e, baseBlock);
    var etherBalance = web3.fromWei(eth.getBalance(e).minus(etherBalanceBaseBlock), "ether");
    var sgtBalance = sgt == null ? new BigNumber(0) : sgt.balanceOf(e).shift(-sgtDecimals);
    var sntBalance = snt == null ? new BigNumber(0) : snt.balanceOf(e).shift(-sntDecimals);
    totalSgtBalance = totalSgtBalance.add(sgtBalance);
    totalSntBalance = totalSntBalance.add(sntBalance);
    console.log("RESULT: " + pad2(i) + " " + e  + " " + pad(etherBalance) + " " + padToken(sgtBalance, sgtDecimals) + " " + padToken(sntBalance, sntDecimals) + " " + accountNames[e]);
    i++;
  });
  console.log("RESULT: -- ------------------------------------------ --------------------------- ------------- ------------------------------ ---------------------------");
  console.log("RESULT:                                                                           " + 
      padToken(totalSgtBalance, sgtDecimals) + " " + padToken(totalSntBalance, sntDecimals) + " " + "Total Token Balances");
  console.log("RESULT: -- ------------------------------------------ --------------------------- ------------- ------------------------------ ---------------------------");
  console.log("RESULT: ");
}

function pad2(s) {
  var o = s.toFixed(0);
  while (o.length < 2) {
    o = " " + o;
  }
  return o;
}

function pad(s) {
  var o = s.toFixed(18);
  while (o.length < 27) {
    o = " " + o;
  }
  return o;
}

function padToken(s, decimals) {
  var o = s.toFixed(decimals);
  var l = parseInt(decimals)+12;
  while (o.length < l) {
    o = " " + o;
  }
  return o;
}


// -----------------------------------------------------------------------------
// Transaction status
// -----------------------------------------------------------------------------
function printTxData(name, txId) {
  var tx = eth.getTransaction(txId);
  var txReceipt = eth.getTransactionReceipt(txId);
  var gasPrice = tx.gasPrice;
  var gasCostETH = tx.gasPrice.mul(txReceipt.gasUsed).div(1e18);
  var gasCostUSD = gasCostETH.mul(ethPriceUSD);
  console.log("RESULT: " + name + " gas=" + tx.gas + " gasUsed=" + txReceipt.gasUsed + " costETH=" + gasCostETH +
    " costUSD=" + gasCostUSD + " @ ETH/USD=" + ethPriceUSD + " gasPrice=" + gasPrice + " block=" + 
    txReceipt.blockNumber + " txId=" + txId);
}

function assertEtherBalance(account, expectedBalance) {
  var etherBalance = web3.fromWei(eth.getBalance(account), "ether");
  if (etherBalance == expectedBalance) {
    console.log("RESULT: OK " + account + " has expected balance " + expectedBalance);
  } else {
    console.log("RESULT: FAILURE " + account + " has balance " + etherBalance + " <> expected " + expectedBalance);
  }
}

function gasEqualsGasUsed(tx) {
  var gas = eth.getTransaction(tx).gas;
  var gasUsed = eth.getTransactionReceipt(tx).gasUsed;
  return (gas == gasUsed);
}

function failIfGasEqualsGasUsed(tx, msg) {
  var gas = eth.getTransaction(tx).gas;
  var gasUsed = eth.getTransactionReceipt(tx).gasUsed;
  if (gas == gasUsed) {
    console.log("RESULT: FAIL " + msg);
    return 0;
  } else {
    console.log("RESULT: PASS " + msg);
    return 1;
  }
}

function passIfGasEqualsGasUsed(tx, msg) {
  var gas = eth.getTransaction(tx).gas;
  var gasUsed = eth.getTransactionReceipt(tx).gasUsed;
  if (gas == gasUsed) {
    console.log("RESULT: PASS " + msg);
    return 1;
  } else {
    console.log("RESULT: FAIL " + msg);
    return 0;
  }
}

function failIfGasEqualsGasUsedOrContractAddressNull(contractAddress, tx, msg) {
  if (contractAddress == null) {
    console.log("RESULT: FAIL " + msg);
    return 0;
  } else {
    var gas = eth.getTransaction(tx).gas;
    var gasUsed = eth.getTransactionReceipt(tx).gasUsed;
    if (gas == gasUsed) {
      console.log("RESULT: FAIL " + msg);
      return 0;
    } else {
      console.log("RESULT: PASS " + msg);
      return 1;
    }
  }
}


// -----------------------------------------------------------------------------
// SGT token contract details
// -----------------------------------------------------------------------------
var sgtDetailsFromBlock = 0;
function printSgtContractDetails() {
  if (sgtContractAddress != null && sgtContractAbi != null) {
    var contract = eth.contract(sgtContractAbi).at(sgtContractAddress);
    var decimals = contract.decimals();
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
var sntDetailsFromBlock = 0;
function printSntContractDetails() {
  if (sntContractAddress != null && sntContractAbi != null) {
    var contract = eth.contract(sntContractAbi).at(sntContractAddress);
    var decimals = contract.decimals();
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
var statusContributionContractAddress = null;
var statusContributionContractAbi = null;

function addStatusContributionContractAddressAndAbi(address, tokenAbi) {
  statusContributionContractAddress = address;
  statusContributionContractAbi = tokenAbi;
}

var statusContributionDetailsFromBlock = 0;
function printStatusContributionContractDetails() {
  if (statusContributionContractAddress != null && statusContributionContractAbi != null) {
    var contract = eth.contract(statusContributionContractAbi).at(statusContributionContractAddress);
    var decimals = 18;
    console.log("RESULT: statusContribution.failSafeLimit=" + contract.failSafeLimit().shift(-18) + " ETH");
    console.log("RESULT: statusContribution.maxGuaranteedLimit=" + contract.maxGuaranteedLimit().shift(-18) + " ETH");
    console.log("RESULT: statusContribution.exchangeRate=" + contract.exchangeRate());
    console.log("RESULT: statusContribution.maxGasPrice=" + contract.maxGasPrice().shift(-18).toFixed(18) + " ETH");
    console.log("RESULT: statusContribution.maxCallFrequency=" + contract.maxCallFrequency());

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
var contributionWalletContractAddress = null;
var contributionWalletContractAbi = null;

function addContributionWalletContractAddressAndAbi(address, tokenAbi) {
  contributionWalletContractAddress = address;
  contributionWalletContractAbi = tokenAbi;
}

function printContributionWalletContractDetails() {
  if (contributionWalletContractAddress != null && contributionWalletContractAbi != null) {
    var contract = eth.contract(contributionWalletContractAbi).at(contributionWalletContractAddress);
    console.log("RESULT: contributionWallet.multisig=" + contract.multisig());
    console.log("RESULT: contributionWallet.endBlock=" + contract.endBlock());
    console.log("RESULT: contributionWallet.contribution=" + contract.contribution());
  }
}


//-----------------------------------------------------------------------------
// DevTokensHolder contract details
//-----------------------------------------------------------------------------
var devTokensHolderContractAddress = null;
var devTokensHolderContractAbi = null;

function addDevTokensHolderContractAddressAndAbi(address, tokenAbi) {
  devTokensHolderContractAddress = address;
  devTokensHolderContractAbi = tokenAbi;
}

var devTokensHolderDetailsFromBlock = 0;
function printDevTokensHolderContractDetails() {
  if (devTokensHolderContractAddress != null && devTokensHolderContractAbi != null) {
    var contract = eth.contract(devTokensHolderContractAbi).at(devTokensHolderContractAddress);
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
var sgtExchangerContractAddress = null;
var sgtExchangerContractAbi = null;

function addSgtExchangerContractAddressAndAbi(address, tokenAbi) {
  sgtExchangerContractAddress = address;
  sgtExchangerContractAbi = tokenAbi;
}

var sgtExchangerDetailsFromBlock = 0;
function printSgtExchangerContractDetails() {
  if (sgtExchangerContractAddress != null && sgtExchangerContractAbi != null) {
    var contract = eth.contract(sgtExchangerContractAbi).at(sgtExchangerContractAddress);
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
var sntPlaceHolderContractAddress = null;
var sntPlaceHolderContractAbi = null;

function addSntPlaceHolderContractAddressAndAbi(address, tokenAbi) {
  sntPlaceHolderContractAddress = address;
  sntPlaceHolderContractAbi = tokenAbi;
}

var sntPlaceHolderDetailsFromBlock = 0;
function printSntPlaceHolderContractDetails() {
  if (sntPlaceHolderContractAddress != null && sntPlaceHolderContractAbi != null) {
    var contract = eth.contract(sntPlaceHolderContractAbi).at(sntPlaceHolderContractAddress);
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
// DynamicCeiling
//-----------------------------------------------------------------------------
var dynamicCeilingAddress = null;
var dynamicCeilingAbi = null;

function addDynamicCeilingAddressAndAbi(address, tokenAbi) {
  dynamicCeilingAddress = address;
  dynamicCeilingAbi = tokenAbi;
}

var dynamicCeilingFromBlock = 0;
function printDynamicCeilingDetails() {
  if (dynamicCeilingAddress != null && dynamicCeilingAbi != null) {
    var contract = eth.contract(dynamicCeilingAbi).at(dynamicCeilingAddress);
    console.log("RESULT: dynamicCeiling.owner=" + contract.owner());
    console.log("RESULT: dynamicCeiling.contribution=" + contract.contribution());
    console.log("RESULT: dynamicCeiling.currentIndex=" + contract.currentIndex());
    console.log("RESULT: dynamicCeiling.revealedCurves=" + contract.revealedCurves());
    console.log("RESULT: dynamicCeiling.allRevealed=" + contract.allRevealed());
    console.log("RESULT: dynamicCeiling.nCurves=" + contract.nCurves());

    var latestBlock = eth.blockNumber;
    var i;

    var hashSetEvents = contract.HashSet({}, { fromBlock: dynamicCeilingFromBlock, toBlock: latestBlock });
    i = 0;
    hashSetEvents.watch(function (error, result) {
      console.log("RESULT: HashSet Event " + i++ + ": " + JSON.stringify(result.args) + " block=" + result.blockNumber);
    });
    hashSetEvents.stopWatching();

    var curvePointRevealedEvents = contract.CurvePointRevealed({}, { fromBlock: dynamicCeilingFromBlock, toBlock: latestBlock });
    i = 0;
    curvePointRevealedEvents.watch(function (error, result) {
      console.log("RESULT: CurvePointRevealed Event " + i++ + ": " + JSON.stringify(result.args) + " block=" + result.blockNumber);
    });
    curvePointRevealedEvents.stopWatching();

    for (i = 0; i < contract.nCurves(); i++) {
      console.log("RESULT: dynamicCeiling.curves(" + i + ")=" + JSON.stringify(contract.curves(i)));
    }
    dynamicCeilingFromBlock = latestBlock + 1;
  }
}
