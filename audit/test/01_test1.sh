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
DYNAMICCEILING=`grep ^DYNAMICCEILING= settings.txt | sed "s/^.*=//"`
DYNAMICCEILINGJS=`grep ^DYNAMICCEILINGJS= settings.txt | sed "s/^.*=//"`
DEPLOYMENTDATA=`grep ^DEPLOYMENTDATA= settings.txt | sed "s/^.*=//"`
INCLUDEJS=`grep ^INCLUDEJS= settings.txt | sed "s/^.*=//"`
TEST1OUTPUT=`grep ^TEST1OUTPUT= settings.txt | sed "s/^.*=//"`
TEST1RESULTS=`grep ^TEST1RESULTS= settings.txt | sed "s/^.*=//"`

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
printf "DYNAMICCEILING        = '$DYNAMICCEILING'\n"
printf "DYNAMICCEILINGJS      = '$DYNAMICCEILINGJS'\n"
printf "DEPLOYMENTDATA        = '$DEPLOYMENTDATA'\n"
printf "INCLUDEJS             = '$INCLUDEJS'\n"
printf "TEST1OUTPUT           = '$TEST1OUTPUT'\n"
printf "TEST1RESULTS          = '$TEST1RESULTS'\n"
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

echo "var dynamicCeilingOutput=`solc = --optimize --combined-json abi,bin,interface $CONTRACTSTEMPDIR/$DYNAMICCEILING`;" > $DYNAMICCEILINGJS

geth --verbosity 3 attach $GETHATTACHPOINT << EOF | tee $TEST1OUTPUT
loadScript("$DYNAMICCEILINGJS");
loadScript("functions.js");

var dynamicCeilingAbi = JSON.parse(dynamicCeilingOutput.contracts["$CONTRACTSTEMPDIR/$DYNAMICCEILING:DynamicCeiling"].abi);
var dynamicCeilingBin = "0x" + dynamicCeilingOutput.contracts["$CONTRACTSTEMPDIR/$DYNAMICCEILING:DynamicCeiling"].bin;

console.log("DATA: dynamicCeilingAbi=" + JSON.stringify(dynamicCeilingAbi));

unlockAccounts("$PASSWORD");
printBalances();

console.log("RESULT: ");

// -----------------------------------------------------------------------------
var testMessage = "Test 1.1 Deploy DynamicCeiling Contract";
console.log("RESULT: " + testMessage);
var dynamicCeilingContract = web3.eth.contract(dynamicCeilingAbi);
var dynamicCeilingTx = null;
var dynamicCeilingAddress = null;
var dynamicCeiling = dynamicCeilingContract.new(contractOwnerAccount, contributionAccount, {from: contractOwnerAccount, data: dynamicCeilingBin, gas: 4000000},
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
while (txpool.status.pending > 0) {
}
printBalances();
failIfGasEqualsGasUsed(dynamicCeilingTx, testMessage);
printDynamicCeilingDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
// Prepare curve and hashes
// -----------------------------------------------------------------------------
var hashes = [];
var curves = [[web3.toWei(1000, "ether"), 30, 10^12], \
    [web3.toWei(21000, "ether"), 30, 10^12], \
    [web3.toWei(61000, "ether"), 30, 10^12]];
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
console.log("RESULT: hashes=" + JSON.stringify(hashes));
console.log("RESULT: limits=" + JSON.stringify(limits));
console.log("RESULT: slopeFactors=" + JSON.stringify(slopeFactors));
console.log("RESULT: collectMinimums=" + JSON.stringify(collectMinimums));
console.log("RESULT: lasts=" + JSON.stringify(lasts));
console.log("RESULT: salts" + JSON.stringify(salts));


// -----------------------------------------------------------------------------
var testMessage = "Test 1.2 Add Hidden Curve";
console.log("RESULT: " + testMessage);
var tx12_1 = dynamicCeiling.setHiddenCurves(hashes, {from: contractOwnerAccount, gas: 200000});
while (txpool.status.pending > 0) {
}
printTxData("tx12_1", tx12_1);
printBalances();
failIfGasEqualsGasUsed(tx12_1, testMessage);
printDynamicCeilingDetails();
console.log("RESULT: ");


var revealAll = "$MODE" == "revealAll" ? true : false;

if (revealAll) {
// -----------------------------------------------------------------------------
var testMessage = "Test 2.1 Reveal All Points In Curve";
console.log("RESULT: " + testMessage);
var c = curves[0];
var tx21_1 = dynamicCeiling.revealMulti(limits, slopeFactors, collectMinimums, lasts, salts, {from: contractOwnerAccount, gas: 2000000});
while (txpool.status.pending > 0) {
}
printTxData("tx21_1", tx21_1);
printBalances();
failIfGasEqualsGasUsed(tx21_1, testMessage);
printDynamicCeilingDetails();
console.log("RESULT: ");
}

if (!revealAll) {
// -----------------------------------------------------------------------------
var testMessage = "Test 2.2 Reveal 1st Point In Curve";
console.log("RESULT: " + testMessage);
var c = curves[0];
var tx22_1 = dynamicCeiling.revealCurve(c[0], c[1], c[2], false, "salt", {from: contractOwnerAccount, gas: 200000});
while (txpool.status.pending > 0) {
}
printTxData("tx22_1", tx22_1);
printBalances();
failIfGasEqualsGasUsed(tx22_1, testMessage);
printDynamicCeilingDetails();
console.log("RESULT: ");
}


EOF
grep "DATA: " $TEST1OUTPUT | sed "s/DATA: //" > $DEPLOYMENTDATA
cat $DEPLOYMENTDATA
grep "RESULT: " $TEST1OUTPUT | sed "s/RESULT: //" > $TEST1RESULTS
cat $TEST1RESULTS
