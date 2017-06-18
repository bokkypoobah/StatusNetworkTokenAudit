#!/bin/bash
# ----------------------------------------------------------------------------------------------
# Testing the smart contract
#
# Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2017. The MIT Licence.
# ----------------------------------------------------------------------------------------------

MODE=${1:-test}

GETHATTACHPOINT=`grep ^IPCFILE= settings.txt | sed "s/^.*=//"`
PASSWORD=`grep ^PASSWORD= settings.txt | sed "s/^.*=//"`
CONTRACTSDIR=`grep ^CONTRACTSDIR= settings.txt | sed "s/^.*=//"`
CONTRACTSTEMPDIR=`grep ^CONTRACTSTEMPDIR= settings.txt | sed "s/^.*=//"`
MINIMETOKEN=`grep ^MINIMETOKEN= settings.txt | sed "s/^.*=//"`
MINIMETOKENJS=`grep ^MINIMETOKENJS= settings.txt | sed "s/^.*=//"`
SGT=`grep ^SGT= settings.txt | sed "s/^.*=//"`
SGTJS=`grep ^SGTJS= settings.txt | sed "s/^.*=//"`
SNT=`grep ^SNT= settings.txt | sed "s/^.*=//"`
SNTJS=`grep ^SNTJS= settings.txt | sed "s/^.*=//"`
STATUSCONTRIBUTION=`grep ^STATUSCONTRIBUTION= settings.txt | sed "s/^.*=//"`
STATUSCONTRIBUTIONJS=`grep ^STATUSCONTRIBUTIONJS= settings.txt | sed "s/^.*=//"`
CONTRIBUTIONWALLET=`grep ^CONTRIBUTIONWALLET= settings.txt | sed "s/^.*=//"`
CONTRIBUTIONWALLETJS=`grep ^CONTRIBUTIONWALLETJS= settings.txt | sed "s/^.*=//"`
DEVTOKENSHOLDER=`grep ^DEVTOKENSHOLDER= settings.txt | sed "s/^.*=//"`
DEVTOKENSHOLDERJS=`grep ^DEVTOKENSHOLDERJS= settings.txt | sed "s/^.*=//"`
SGTEXCHANGER=`grep ^SGTEXCHANGER= settings.txt | sed "s/^.*=//"`
SGTEXCHANGERJS=`grep ^SGTEXCHANGERJS= settings.txt | sed "s/^.*=//"`
DYNAMICCEILING=`grep ^DYNAMICCEILING= settings.txt | sed "s/^.*=//"`
DYNAMICCEILINGJS=`grep ^DYNAMICCEILINGJS= settings.txt | sed "s/^.*=//"`
SNTPLACEHOLDER=`grep ^SNTPLACEHOLDER= settings.txt | sed "s/^.*=//"`
SNTPLACEHOLDERJS=`grep ^SNTPLACEHOLDERJS= settings.txt | sed "s/^.*=//"`
DEPLOYMENTDATA=`grep ^DEPLOYMENTDATA= settings.txt | sed "s/^.*=//"`
INCLUDEJS=`grep ^INCLUDEJS= settings.txt | sed "s/^.*=//"`
TEST2OUTPUT=`grep ^TEST2OUTPUT= settings.txt | sed "s/^.*=//"`
TEST2RESULTS=`grep ^TEST2RESULTS= settings.txt | sed "s/^.*=//"`

CURRENTTIME=`date +%s`
CURRENTTIMES=`date -r $CURRENTTIME -u`

if [ "$MODE" == "dev" ]; then
  # Start time now
  STARTTIME=`echo "$CURRENTTIME" | bc`
else
  # Start time 1 minute in the future
  STARTTIME=`echo "$CURRENTTIME+60" | bc`
fi
STARTTIME_S=`date -r $STARTTIME -u`
ENDTIME=`echo "$CURRENTTIME+60*5" | bc`
ENDTIME_S=`date -r $ENDTIME -u`

printf "MODE                  = '$MODE'\n"
printf "GETHATTACHPOINT       = '$GETHATTACHPOINT'\n"
printf "PASSWORD              = '$PASSWORD'\n"
printf "CONTRACTSDIR          = '$CONTRACTSDIR'\n"
printf "CONTRACTSTEMPDIR      = '$CONTRACTSTEMPDIR'\n"
printf "MINIMETOKEN           = '$MINIMETOKEN'\n"
printf "MINIMETOKENJS         = '$MINIMETOKENJS'\n"
printf "SGT                   = '$SGT'\n"
printf "SGTJS                 = '$SGTJS'\n"
printf "SNT                   = '$SNT'\n"
printf "SNTJS                 = '$SNTJS'\n"
printf "STATUSCONTRIBUTION    = '$STATUSCONTRIBUTION'\n"
printf "STATUSCONTRIBUTIONJS  = '$STATUSCONTRIBUTIONJS'\n"
printf "CONTRIBUTIONWALLET    = '$CONTRIBUTIONWALLET'\n"
printf "CONTRIBUTIONWALLETJS  = '$CONTRIBUTIONWALLETJS'\n"
printf "DEVTOKENSHOLDER       = '$DEVTOKENSHOLDER'\n"
printf "DEVTOKENSHOLDERJS     = '$DEVTOKENSHOLDERJS'\n"
printf "SGTEXCHANGER          = '$SGTEXCHANGER'\n"
printf "SGTEXCHANGERJS        = '$SGTEXCHANGERJS'\n"
printf "DYNAMICCEILING        = '$DYNAMICCEILING'\n"
printf "DYNAMICCEILINGJS      = '$DYNAMICCEILINGJS'\n"
printf "SNTPLACEHOLDER        = '$SNTPLACEHOLDER'\n"
printf "SNTPLACEHOLDERJS      = '$SNTPLACEHOLDERJS'\n"
printf "DEPLOYMENTDATA        = '$DEPLOYMENTDATA'\n"
printf "INCLUDEJS             = '$INCLUDEJS'\n"
printf "TEST2OUTPUT           = '$TEST2OUTPUT'\n"
printf "TEST2RESULTS          = '$TEST2RESULTS'\n"
printf "CURRENTTIME           = '$CURRENTTIME' '$CURRENTTIMES'\n"
printf "STARTTIME             = '$STARTTIME' '$STARTTIME_S'\n"
printf "ENDTIME               = '$ENDTIME' '$ENDTIME_S'\n"

# Create contracts temp dir if it does not exist
if [ ! -d "$CONTRACTSTEMPDIR" ]; then
  mkdir $CONTRACTSTEMPDIR
fi

# Remove contracts temp dir
find $CONTRACTSTEMPDIR -type f -name '*.sol' -exec rm {} \;

# Copy fresh contracts
cp -rp $CONTRACTSDIR/* $CONTRACTSTEMPDIR

# Copy modified contracts
cp -rp modifiedContracts/* $CONTRACTSTEMPDIR

# --- Modify dates ---
# PRESALE_START_DATE = +1m
#`perl -pi -e "s/multisig = 0xf64b584972fe6055a770477670208d737fff282f;/multisig = 0xa22ab8a9d641ce77e06d98b7d7065d324d3d6976;/" $CONTRACTSTEMPDIR/$BASICFORECASTING`

# --- Un-internal safeMaths ---
# `perl -pi -e "s/internal/constant/" $TOKENTEMPSOL`

DIFFS=`diff -r $CONTRACTSDIR $CONTRACTSTEMPDIR`
echo "--- Differences ---"
echo "$DIFFS"

echo "var miniMeTokenOutput=`solc = --optimize --combined-json abi,bin,interface $CONTRACTSTEMPDIR/$MINIMETOKEN`;" > $MINIMETOKENJS
echo "var sgtOutput=`solc = --optimize --combined-json abi,bin,interface $CONTRACTSTEMPDIR/$SGT`;" > $SGTJS
echo "var sntOutput=`solc = --optimize --combined-json abi,bin,interface $CONTRACTSTEMPDIR/$SNT`;" > $SNTJS
echo "var statusContributionOutput=`solc = --optimize --combined-json abi,bin,interface $CONTRACTSTEMPDIR/$STATUSCONTRIBUTION`;" > $STATUSCONTRIBUTIONJS
echo "var contributionWalletOutput=`solc = --optimize --combined-json abi,bin,interface $CONTRACTSTEMPDIR/$CONTRIBUTIONWALLET`;" > $CONTRIBUTIONWALLETJS
echo "var devTokensHolderOutput=`solc = --optimize --combined-json abi,bin,interface $CONTRACTSTEMPDIR/$DEVTOKENSHOLDER`;" > $DEVTOKENSHOLDERJS
echo "var sgtExchangerOutput=`solc = --optimize --combined-json abi,bin,interface $CONTRACTSTEMPDIR/$SGTEXCHANGER`;" > $SGTEXCHANGERJS
echo "var dynamicCeilingOutput=`solc = --optimize --combined-json abi,bin,interface $CONTRACTSTEMPDIR/$DYNAMICCEILING`;" > $DYNAMICCEILINGJS
echo "var sntPlaceHolderOutput=`solc = --optimize --combined-json abi,bin,interface $CONTRACTSTEMPDIR/$SNTPLACEHOLDER`;" > $SNTPLACEHOLDERJS

geth --verbosity 3 attach $GETHATTACHPOINT << EOF | tee $TEST2OUTPUT
loadScript("$MINIMETOKENJS");
loadScript("$SGTJS");
loadScript("$SNTJS");
loadScript("$STATUSCONTRIBUTIONJS");
loadScript("$CONTRIBUTIONWALLETJS");
loadScript("$DEVTOKENSHOLDERJS");
loadScript("$SGTEXCHANGERJS");
loadScript("$DYNAMICCEILINGJS");
loadScript("$SNTPLACEHOLDERJS");
loadScript("functions.js");

var miniMeTokenFactoryAbi = JSON.parse(miniMeTokenOutput.contracts["$CONTRACTSTEMPDIR/$MINIMETOKEN:MiniMeTokenFactory"].abi);
var miniMeTokenFactoryBin = "0x" + miniMeTokenOutput.contracts["$CONTRACTSTEMPDIR/$MINIMETOKEN:MiniMeTokenFactory"].bin;
var sgtAbi = JSON.parse(sgtOutput.contracts["$CONTRACTSTEMPDIR/$SGT:SGT"].abi);
var sgtBin = "0x" + sgtOutput.contracts["$CONTRACTSTEMPDIR/$SGT:SGT"].bin;
var sntAbi = JSON.parse(sntOutput.contracts["$CONTRACTSTEMPDIR/$SNT:SNT"].abi);
var sntBin = "0x" + sntOutput.contracts["$CONTRACTSTEMPDIR/$SNT:SNT"].bin;
var statusContributionAbi = JSON.parse(statusContributionOutput.contracts["$CONTRACTSTEMPDIR/$STATUSCONTRIBUTION:StatusContribution"].abi);
var statusContributionBin = "0x" + statusContributionOutput.contracts["$CONTRACTSTEMPDIR/$STATUSCONTRIBUTION:StatusContribution"].bin;
var contributionWalletAbi = JSON.parse(contributionWalletOutput.contracts["$CONTRACTSTEMPDIR/$CONTRIBUTIONWALLET:ContributionWallet"].abi);
var contributionWalletBin = "0x" + contributionWalletOutput.contracts["$CONTRACTSTEMPDIR/$CONTRIBUTIONWALLET:ContributionWallet"].bin;
var devTokensHolderAbi = JSON.parse(devTokensHolderOutput.contracts["$CONTRACTSTEMPDIR/$DEVTOKENSHOLDER:DevTokensHolder"].abi);
var devTokensHolderBin = "0x" + devTokensHolderOutput.contracts["$CONTRACTSTEMPDIR/$DEVTOKENSHOLDER:DevTokensHolder"].bin;
var sgtExchangerAbi = JSON.parse(sgtExchangerOutput.contracts["$CONTRACTSTEMPDIR/$SGTEXCHANGER:SGTExchanger"].abi);
var sgtExchangerBin = "0x" + sgtExchangerOutput.contracts["$CONTRACTSTEMPDIR/$SGTEXCHANGER:SGTExchanger"].bin;
var dynamicCeilingAbi = JSON.parse(dynamicCeilingOutput.contracts["$CONTRACTSTEMPDIR/$DYNAMICCEILING:DynamicCeiling"].abi);
var dynamicCeilingBin = "0x" + dynamicCeilingOutput.contracts["$CONTRACTSTEMPDIR/$DYNAMICCEILING:DynamicCeiling"].bin;
var sntPlaceHolderAbi = JSON.parse(sntPlaceHolderOutput.contracts["$CONTRACTSTEMPDIR/$SNTPLACEHOLDER:SNTPlaceHolder"].abi);
var sntPlaceHolderBin = "0x" + sntPlaceHolderOutput.contracts["$CONTRACTSTEMPDIR/$SNTPLACEHOLDER:SNTPlaceHolder"].bin;

console.log("DATA: miniMeTokenFactoryAbi=" + JSON.stringify(miniMeTokenFactoryAbi));
console.log("DATA: sgtAbi=" + JSON.stringify(sgtAbi));
console.log("DATA: sntAbi=" + JSON.stringify(sntAbi));
console.log("DATA: statusContributionAbi=" + JSON.stringify(statusContributionAbi));
console.log("DATA: contributionWalletAbi=" + JSON.stringify(contributionWalletAbi));
console.log("DATA: devTokensHolderAbi=" + JSON.stringify(devTokensHolderAbi));
console.log("DATA: sgtExchangerAbi=" + JSON.stringify(sgtExchangerAbi));
console.log("DATA: dynamicCeilingAbi=" + JSON.stringify(dynamicCeilingAbi));
console.log("DATA: sntPlaceHolderAbi=" + JSON.stringify(sntPlaceHolderAbi));

unlockAccounts("$PASSWORD");
printBalances();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
// Deploy MiniMeTokenFactory
// -----------------------------------------------------------------------------
var miniMeTokenFactoryMessage = "Deploy MiniMeTokenFactory";
console.log("RESULT: " + miniMeTokenFactoryMessage);
var miniMeTokenFactoryContract = web3.eth.contract(miniMeTokenFactoryAbi);
var miniMeTokenFactoryTx = null;
var miniMeTokenFactoryAddress = null;
var miniMeTokenFactory = miniMeTokenFactoryContract.new({from: statusAccount, data: miniMeTokenFactoryBin, gas: 4000000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        miniMeTokenFactoryTx = contract.transactionHash;
      } else {
        miniMeTokenFactoryAddress = contract.address;
        addAccount(miniMeTokenFactoryAddress, "MiniMeTokenFactory");
        printTxData("miniMeTokenFactoryAddress=" + miniMeTokenFactoryAddress, miniMeTokenFactoryTx);
      }
    }
  }
);

while (txpool.status.pending > 0) {
}

printBalances();
failIfGasEqualsGasUsed(miniMeTokenFactoryTx, miniMeTokenFactoryMessage);
console.log("RESULT: ");



// -----------------------------------------------------------------------------
// Deploy SGT, SNT, StatusContribution
// -----------------------------------------------------------------------------
var sgtMessage = "Deploy SGT";
console.log("RESULT: " + sgtMessage);
var sgtContract = web3.eth.contract(sgtAbi);
var sgtTx = null;
var sgtAddress = null;
var sgt = sgtContract.new(miniMeTokenFactoryAddress, {from: statusAccount, data: sgtBin, gas: 4000000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        sgtTx = contract.transactionHash;
      } else {
        sgtAddress = contract.address;
        addAccount(sgtAddress, "SGT");
        addSgtContractAddressAndAbi(sgtAddress, sgtAbi);
        printTxData("sgtAddress=" + sgtAddress, sgtTx);
      }
    }
  }
);

var sntMessage = "Deploy SNT";
console.log("RESULT: " + sntMessage);
var sntContract = web3.eth.contract(sntAbi);
var sntTx = null;
var sntAddress = null;
var snt = sntContract.new(miniMeTokenFactoryAddress, {from: statusAccount, data: sntBin, gas: 4000000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        sntTx = contract.transactionHash;
      } else {
        sntAddress = contract.address;
        addAccount(sntAddress, "SNT");
        addSntContractAddressAndAbi(sntAddress, sntAbi);
        printTxData("sntAddress=" + sntAddress, sntTx);
      }
    }
  }
);

var statusContributionMessage = "Deploy StatusContribution";
console.log("RESULT: " + statusContributionMessage);
var statusContributionContract = web3.eth.contract(statusContributionAbi);
var statusContributionTx = null;
var statusContributionAddress = null;
var statusContribution = statusContributionContract.new(miniMeTokenFactoryAddress,
    {from: statusAccount, data: statusContributionBin, gas: 4000000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        statusContributionTx = contract.transactionHash;
      } else {
        statusContributionAddress = contract.address;
        addAccount(statusContributionAddress, "StatusContribution");
        addStatusContributionContractAddressAndAbi(statusContributionAddress, statusContributionAbi);
        printTxData("statusContributionAddress=" + statusContributionAddress, statusContributionTx);
      }
    }
  }
);

while (txpool.status.pending > 0) {
}

printBalances();

failIfGasEqualsGasUsed(sgtTx, sgtMessage);
printSgtContractDetails();

failIfGasEqualsGasUsed(sntTx, sntMessage);
printSntContractDetails();

failIfGasEqualsGasUsed(statusContributionTx, statusContributionMessage);
printStatusContributionContractDetails();

console.log("RESULT: ");



// -----------------------------------------------------------------------------
// Start block and end block
// -----------------------------------------------------------------------------
var startBlock = parseInt(eth.blockNumber) + 10;
var endBlock = parseInt(eth.blockNumber) + 20;

// -----------------------------------------------------------------------------
// Deploy ContributionWallet, DevTokensHolder, SGTExchanger, SNTPlaceHolder and
//   DynamicCeiling
// Generate SGT Tokens
// SNT ChangeController To StatusContribution 
// -----------------------------------------------------------------------------
var contributionWalletMessage = "Deploy ContributionWallet";
console.log("RESULT: " + contributionWalletMessage);
var contributionWalletContract = web3.eth.contract(contributionWalletAbi);
var contributionWalletTx = null;
var contributionWalletAddress = null;
var contributionWallet = contributionWalletContract.new(statusAccount, endBlock, statusContributionAddress,
    {from: statusAccount, data: contributionWalletBin, gas: 4000000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        contributionWalletTx = contract.transactionHash;
      } else {
        contributionWalletAddress = contract.address;
        addAccount(contributionWalletAddress, "ContributionWallet");
        addContributionWalletContractAddressAndAbi(contributionWalletAddress, contributionWalletAbi);
        printTxData("contributionWalletAddress=" + contributionWalletAddress, contributionWalletTx);
      }
    }
  }
);

var devTokensHolderMessage = "Deploy DevTokensHolder";
console.log("RESULT: " + devTokensHolderMessage);
var devTokensHolderContract = web3.eth.contract(devTokensHolderAbi);
var devTokensHolderTx = null;
var devTokensHolderAddress = null;
var devTokensHolder = devTokensHolderContract.new(devAccount, statusContributionAddress, sntAddress, 
    {from: statusAccount, data: devTokensHolderBin, gas: 4000000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        devTokensHolderTx = contract.transactionHash;
      } else {
        devTokensHolderAddress = contract.address;
        addAccount(devTokensHolderAddress, "DevTokensHolder");
        addDevTokensHolderContractAddressAndAbi(devTokensHolderAddress, devTokensHolderAbi);
        printTxData("devTokensHolderAddress=" + devTokensHolderAddress, devTokensHolderTx);
      }
    }
  }
);


var sgtExchangerMessage = "Deploy SGTExchanger";
console.log("RESULT: " + sgtExchangerMessage);
var sgtExchangerContract = web3.eth.contract(sgtExchangerAbi);
var sgtExchangerTx = null;
var sgtExchangerAddress = null;
var sgtExchanger = sgtExchangerContract.new(devAccount, statusContributionAddress, sntAddress, 
    {from: statusAccount, data: sgtExchangerBin, gas: 4000000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        sgtExchangerTx = contract.transactionHash;
      } else {
        sgtExchangerAddress = contract.address;
        addAccount(sgtExchangerAddress, "SGTExchanger");
        addSgtExchangerContractAddressAndAbi(sgtExchangerAddress, sgtExchangerAbi);
        printTxData("sgtExchangerAddress=" + sgtExchangerAddress, sgtExchangerTx);
      }
    }
  }
);


var sntPlaceHolderMessage = "Deploy SNTPlaceHolder";
console.log("RESULT: " + sntPlaceHolderMessage);
var sntPlaceHolderContract = web3.eth.contract(sntPlaceHolderAbi);
var sntPlaceHolderTx = null;
var sntPlaceHolderAddress = null;
var sntPlaceHolder = sntPlaceHolderContract.new(communityAccount, sntAddress,
    statusContributionAddress, sgtExchangerAddress,
    {from: statusAccount, data: sntPlaceHolderBin, gas: 4000000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        sntPlaceHolderTx = contract.transactionHash;
      } else {
        sntPlaceHolderAddress = contract.address;
        addAccount(sntPlaceHolderAddress, "SNTPlaceHolder");
        addSntPlaceHolderContractAddressAndAbi(sntPlaceHolderAddress, sntPlaceHolderAbi);
        printTxData("sntPlaceHolderAddress=" + sntPlaceHolderAddress, sntPlaceHolderTx);
      }
    }
  }
);

var dynamicCeilingMessage = "Deploy DynamicCeiling";
console.log("RESULT: " + dynamicCeilingMessage);
var dynamicCeilingContract = web3.eth.contract(dynamicCeilingAbi);
var dynamicCeilingTx = null;
var dynamicCeilingAddress = null;
var dynamicCeiling = dynamicCeilingContract.new(statusAccount, statusContributionAddress,
    {from: statusAccount, data: dynamicCeilingBin, gas: 4000000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        dynamicCeilingTx = contract.transactionHash;
      } else {
        dynamicCeilingAddress = contract.address;
        addAccount(dynamicCeilingAddress, "DynamicCeiling");
        addDynamicCeilingAddressAndAbi(dynamicCeilingAddress, dynamicCeilingAbi);
        printTxData("dynamicCeilingAddress=" + dynamicCeilingAddress, dynamicCeilingTx);
      }
    }
  }
);

var sgtGenTokensMessage = "Generate SGT Tokens";
console.log("RESULT: " + sgtGenTokensMessage);
var sgtGenTokensTx1 = sgt.generateTokens(sgtHolderAccount, 2500, {from: statusAccount, gas: 2000000});
var sgtGenTokensTx2 = sgt.generateTokens(statusAccount, 2500, {from: statusAccount, gas: 2000000});

var sntChangeControllerMessage = "SNT ChangeController To StatusContribution";
console.log("RESULT: " + sntChangeControllerMessage);
var sntChangeControllerTx = snt.changeController(statusContributionAddress, {from: statusAccount, gas: 2000000});

while (txpool.status.pending > 0) {
}

printBalances();

failIfGasEqualsGasUsed(contributionWalletTx, contributionWalletMessage);
printContributionWalletContractDetails();

failIfGasEqualsGasUsed(devTokensHolderTx, devTokensHolderMessage);
printDevTokensHolderContractDetails();

failIfGasEqualsGasUsed(sgtExchangerTx, sgtExchangerMessage);
printSgtExchangerContractDetails();

failIfGasEqualsGasUsed(sntPlaceHolderTx, sntPlaceHolderMessage);
printSntPlaceHolderContractDetails();

failIfGasEqualsGasUsed(dynamicCeilingTx, dynamicCeilingMessage);
printDynamicCeilingDetails();

printTxData("sgtGenTokensTx1", sgtGenTokensTx1);
printTxData("sgtGenTokensTx2", sgtGenTokensTx2);
failIfGasEqualsGasUsed(sgtGenTokensTx1, sgtGenTokensMessage + " - tx1 2500 SGT -> sgtHolderAccount");
failIfGasEqualsGasUsed(sgtGenTokensTx2, sgtGenTokensMessage + " - tx2 2500 SGT -> statusAccount");
printSgtContractDetails();

failIfGasEqualsGasUsed(sntChangeControllerTx, sntChangeControllerMessage);
printSntContractDetails();

console.log("RESULT: ");



// -----------------------------------------------------------------------------
// Prepare curve and hashes
// -----------------------------------------------------------------------------
var hashes = [];
var curves = [[web3.toWei(1000, "ether"), 30, Math.pow(10, 12)], \
    [web3.toWei(2000, "ether"), 30, Math.pow(10, 12)], \
    [web3.toWei(3000, "ether"), 30, Math.pow(10, 12)], \
    [web3.toWei(4000, "ether"), 30, Math.pow(10, 12)], \
    [web3.toWei(5000, "ether"), 30, Math.pow(10, 12)], \
    [web3.toWei(6000, "ether"), 30, Math.pow(10, 12)]];
var limits = [];
var slopeFactors = [];
var collectMinimums = [];
var lasts = [];
var salts = [];
for (var i = 0 ; i < curves.length; i++) {
  var c = curves[i];
  var hash = dynamicCeiling.calculateHash(c[0], c[1], c[2], i == curves.length - 1, "salt");
  hashes.push(hash);
  limits.push(c[0]);
  slopeFactors.push(c[1]);
  collectMinimums.push(c[2]);
  lasts.push(i == curves.length - 1);
  salts.push("salt");
}
hashes.push(web3.sha3("test1"));
hashes.push(web3.sha3("test2"));
hashes.push(web3.sha3("test3"));
hashes.push(web3.sha3("test4"));
console.log("RESULT: hashes=" + JSON.stringify(hashes));
console.log("RESULT: limits=" + JSON.stringify(limits));
console.log("RESULT: slopeFactors=" + JSON.stringify(slopeFactors));
console.log("RESULT: collectMinimums=" + JSON.stringify(collectMinimums));
console.log("RESULT: lasts=" + JSON.stringify(lasts));
console.log("RESULT: salts" + JSON.stringify(salts));


// -----------------------------------------------------------------------------
// Set Hidden Curve
// Initialise StatusContribution 
// -----------------------------------------------------------------------------
var setHiddenCurveMessage = "Set Hidden Curve";
console.log("RESULT: " + setHiddenCurveMessage);
var setHiddenCurveTx = dynamicCeiling.setHiddenCurves(hashes, {from: statusAccount, gas: 2000000});

var initialiseStatusContributionMessage = "Initialise StatusContribution";
var maxSgtSupply = 10000;
console.log("RESULT: " + initialiseStatusContributionMessage);
var initialiseStatusContributionTx = statusContribution.initialize(sntAddress, sntPlaceHolderAddress, \
  startBlock, endBlock, dynamicCeilingAddress, contributionWalletAddress, reserveAccount, sgtExchangerAddress, \
  devTokensHolderAddress, sgtAddress, maxSgtSupply, {from: statusAccount, gas: 2000000});

while (txpool.status.pending > 0) {
}

printTxData("setHiddenCurveTx", setHiddenCurveTx);
printTxData("initialiseStatusContributionTx", initialiseStatusContributionTx);

printBalances();
failIfGasEqualsGasUsed(setHiddenCurveTx, setHiddenCurveMessage);
printDynamicCeilingDetails();

failIfGasEqualsGasUsed(initialiseStatusContributionTx, initialiseStatusContributionMessage);
printStatusContributionContractDetails();

console.log("RESULT: ");


var revealAll = "$MODE" == "revealAll" ? true : false;

if (revealAll) {
// -----------------------------------------------------------------------------
var revealMultiMessage = "Reveal All Points In Curve";
console.log("RESULT: " + revealMultiMessage);
var c = curves[0];
var revealMultiTx = dynamicCeiling.revealMulti(limits, slopeFactors, collectMinimums,
    lasts, salts, {from: statusAccount, gas: 2000000});
while (txpool.status.pending > 0) {
}
printTxData("revealMultiTx", revealMultiTx);
printBalances();
failIfGasEqualsGasUsed(revealMultiTx, revealMultiMessage);
printDynamicCeilingDetails();
console.log("RESULT: ");
}

if (!revealAll) {
// -----------------------------------------------------------------------------
var revealCurveMessage = "Reveal 2 Points In Curve";
console.log("RESULT: " + revealCurveMessage);
var c = curves[0];
var revealCurveTx1 = dynamicCeiling.revealCurve(c[0], c[1], c[2], false, "salt",
    {from: statusAccount, gas: 200000});
c = curves[1];
var revealCurveTx2 = dynamicCeiling.revealCurve(c[0], c[1], c[2], false, "salt",
    {from: statusAccount, gas: 200000});
while (txpool.status.pending > 0) {
}
printTxData("revealCurveTx1", revealCurveTx1);
printTxData("revealCurveTx2", revealCurveTx2);
printBalances();
failIfGasEqualsGasUsed(revealCurveTx1, revealCurveMessage + " - 1st point");
failIfGasEqualsGasUsed(revealCurveTx2, revealCurveMessage + " - 2nd point");
printDynamicCeilingDetails();
console.log("RESULT: ");
}




EOF
grep "DATA: " $TEST2OUTPUT | sed "s/DATA: //" > $DEPLOYMENTDATA
cat $DEPLOYMENTDATA
grep "RESULT: " $TEST2OUTPUT | sed "s/RESULT: //" > $TEST2RESULTS
cat $TEST2RESULTS
