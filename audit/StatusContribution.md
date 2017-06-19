# StatusContribution (TODO)

My comments prefixed with `// BK` below.

```javascript
// BK Ok - Recent Solidity
pragma solidity ^0.4.11;

/*
    Copyright 2017, Jordi Baylina

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/// @title StatusContribution Contract
/// @author Jordi Baylina
/// @dev This contract will be the SNT controller during the contribution period.
///  This contract will determine the rules during this period.
///  Final users will generally not interact directly with this contract. ETH will
///  be sent to the SNT token contract. The ETH is sent to this contract and from here,
///  ETH is sent to the contribution walled and SNTs are mined according to the defined
///  rules.


import "./Owned.sol";
import "./MiniMeToken.sol";
import "./DynamicCeiling.sol";
import "./SafeMath.sol";
import "./ERC20Token.sol";


contract StatusContribution is Owned, TokenController {
    // BK Using safe maths
    using SafeMath for uint256;

    // BK Next 5 lines Ok
    uint256 constant public failSafeLimit = 300000 ether;
    uint256 constant public maxGuaranteedLimit = 30000 ether;
    uint256 constant public exchangeRate = 10000;
    uint256 constant public maxGasPrice = 50000000000;
    uint256 constant public maxCallFrequency = 20;

    // BK Next 4 lines Ok
    MiniMeToken public SGT;
    MiniMeToken public SNT;
    uint256 public startBlock;
    uint256 public endBlock;

    // BK Ok
    address public destEthDevs;

    // BK Next 5 lines Ok
    address public destTokensDevs;
    address public destTokensReserve;
    uint256 public maxSGTSupply;
    address public destTokensSgt;
    DynamicCeiling public dynamicCeiling;

    // BK Ok
    address public sntController;

    // BK Next 2 lines Ok
    mapping (address => uint256) public guaranteedBuyersLimit;
    mapping (address => uint256) public guaranteedBuyersBought;

    // BK Next 2 lines Ok
    uint256 public totalGuaranteedCollected;
    uint256 public totalNormalCollected;

    // BK Next 2 lines Ok
    uint256 public finalizedBlock;
    uint256 public finalizedTime;

    // BK Ok
    mapping (address => uint256) public lastCallBlock;

    // BK Ok
    bool public paused;

    // BK Ok - Initialised when SNT address set
    modifier initialized() {
        require(address(SNT) != 0x0);
        _;
    }

    // BK Ok - Open between start and end block inclusive, finalizedBlock not set and SNT address set
    modifier contributionOpen() {
        require(getBlockNumber() >= startBlock &&
                getBlockNumber() <= endBlock &&
                finalizedBlock == 0 &&
                address(SNT) != 0x0);
        _;
    }

    // BK Ok
    modifier notPaused() {
        require(!paused);
        _;
    }

    // BK Ok - Constructor
    function StatusContribution() {
        paused = false;
    }


    /// @notice This method should be called by the owner before the contribution
    ///  period starts This initializes most of the parameters
    /// @param _snt Address of the SNT token contract
    /// @param _sntController Token controller for the SNT that will be transferred after
    ///  the contribution finalizes.
    /// @param _startBlock Block when the contribution period starts
    /// @param _endBlock The last block that the contribution period is active
    /// @param _dynamicCeiling Address of the contract that controls the ceiling
    /// @param _destEthDevs Destination address where the contribution ether is sent
    /// @param _destTokensReserve Address where the tokens for the reserve are sent
    /// @param _destTokensSgt Address of the exchanger SGT-SNT where the SNT are sent
    ///  to be distributed to the SGT holders.
    /// @param _destTokensDevs Address where the tokens for the dev are sent
    /// @param _sgt Address of the SGT token contract
    /// @param _maxSGTSupply Quantity of SGT tokens that would represent 10% of status.
    function initialize(
        address _snt,
        address _sntController,

        uint256 _startBlock,
        uint256 _endBlock,

        address _dynamicCeiling,

        address _destEthDevs,

        address _destTokensReserve,
        address _destTokensSgt,
        address _destTokensDevs,

        address _sgt,
        uint256 _maxSGTSupply
    ) public onlyOwner {
        // Initialize only once
        // BK Ok
        require(address(SNT) == 0x0);

        // BK Next 4 lines Ok - SNT with no tokens, this contract is the controller and same decimal places
        SNT = MiniMeToken(_snt);
        require(SNT.totalSupply() == 0);
        require(SNT.controller() == address(this));
        require(SNT.decimals() == 18);  // Same amount of decimals as ETH

        // BK Ok
        require(_sntController != 0x0);
        sntController = _sntController;

        // BK Next 4 lines Ok - future start block, start before end
        require(_startBlock >= getBlockNumber());
        require(_startBlock < _endBlock);
        startBlock = _startBlock;
        endBlock = _endBlock;

        // BK Ok
        require(_dynamicCeiling != 0x0);
        dynamicCeiling = DynamicCeiling(_dynamicCeiling);

        // BK Ok
        require(_destEthDevs != 0x0);
        destEthDevs = _destEthDevs;

        // BK Ok
        require(_destTokensReserve != 0x0);
        destTokensReserve = _destTokensReserve;

        // BK Ok
        require(_destTokensSgt != 0x0);
        destTokensSgt = _destTokensSgt;

        // BK Ok
        require(_destTokensDevs != 0x0);
        destTokensDevs = _destTokensDevs;

        // BK Ok
        require(_sgt != 0x0);
        SGT = MiniMeToken(_sgt);

        // BK Ok
        require(_maxSGTSupply >= MiniMeToken(SGT).totalSupply());
        maxSGTSupply = _maxSGTSupply;
    }

    /// @notice Sets the limit for a guaranteed address. All the guaranteed addresses
    ///  will be able to get SNTs during the contribution period with his own
    ///  specific limit.
    ///  This method should be called by the owner after the initialization
    ///  and before the contribution starts.
    /// @param _th Guaranteed address
    /// @param _limit Limit for the guaranteed address.
    function setGuaranteedAddress(address _th, uint256 _limit) public initialized onlyOwner {
        // BK Ok - Can only set before start
        require(getBlockNumber() < startBlock);
        // BK Ok - Can only set limit less than a max
        require(_limit > 0 && _limit <= maxGuaranteedLimit);
        // BK Ok
        guaranteedBuyersLimit[_th] = _limit;
        // BK Log event
        GuaranteedAddress(_th, _limit);
    }

    /// @notice If anybody sends Ether directly to this contract, consider he is
    ///  getting SNTs.
    // BK Ok - Accept ETH (payable), when not paused, and a proxy payment to self
    function () public payable notPaused {
        proxyPayment(msg.sender);
    }


    //////////
    // MiniMe Controller functions
    //////////

    /// @notice This method will generally be called by the SNT token contract to
    ///  acquire SNTs. Or directly from third parties that want to acquire SNTs in
    ///  behalf of a token holder.
    /// @param _th SNT holder where the SNTs will be minted.
    // BK Ok - Accept ETH, when not paused, initialised, during crowdsale period, not finalised
    function proxyPayment(address _th) public payable notPaused initialized contributionOpen returns (bool) {
        // BK Ok
        require(_th != 0x0);
        // BK Ok - Is this a guaranteed buyer?
        if (guaranteedBuyersLimit[_th] > 0) {
            buyGuaranteed(_th);
        // BK Ok - A non-guaranteed buyer
        } else {
            buyNormal(_th);
        }
        return true;
    }

    // BK Ok
    function onTransfer(address, address, uint256) public returns (bool) {
        return false;
    }

    // BK Ok
    function onApprove(address, address, uint256) public returns (bool) {
        return false;
    }

    // BK Ok
    function buyNormal(address _th) internal {
        // BK Ok - Cap on tx gas price
        require(tx.gasprice <= maxGasPrice);

        // Antispam mechanism
        address caller;
        if (msg.sender == address(SNT)) {
            caller = _th;
        } else {
            caller = msg.sender;
        }

        // Do not allow contracts to game the system
        // BK Ok
        require(!isContract(caller));

        // BK Minimum number of blocks between transactions from the same account
        require(getBlockNumber().sub(lastCallBlock[caller]) >= maxCallFrequency);
        lastCallBlock[caller] = getBlockNumber();

        // BK Ok - Max that can be collected, w.r.t. running sum
        uint256 toCollect = dynamicCeiling.toCollect(totalNormalCollected);

        uint256 toFund;
        // BK Ok - Amount contributed below max that can be collected
        if (msg.value <= toCollect) {
            toFund = msg.value;
        // BK Ok - Only take contribution up to the max that can be collected 
        } else {
            toFund = toCollect;
        }

        // BK Ok - Keep running sum
        totalNormalCollected = totalNormalCollected.add(toFund);
        // BK Ok
        doBuy(_th, toFund, false);
    }

    // BK Ok
    function buyGuaranteed(address _th) internal {
        // BK Ok
        uint256 toCollect = guaranteedBuyersLimit[_th];

        uint256 toFund;
        // BK Ok - Sum of contributions > guarantee for the account
        if (guaranteedBuyersBought[_th].add(msg.value) > toCollect) {
            // BK Ok - Remaining guaranteed
            toFund = toCollect.sub(guaranteedBuyersBought[_th]);
        } else {
            // BK Ok - Take full amount
            toFund = msg.value;
        }

        // BK Ok - Keep sum for the account
        guaranteedBuyersBought[_th] = guaranteedBuyersBought[_th].add(toFund);
        // BK Ok - Keep running sum
        totalGuaranteedCollected = totalGuaranteedCollected.add(toFund);
        // BK Ok
        doBuy(_th, toFund, true);
    }

    // BK Ok
    function doBuy(address _th, uint256 _toFund, bool _guaranteed) internal {
        // BK Ok
        assert(msg.value >= _toFund);  // Not needed, but double check.
        // BK Ok
        assert(totalCollected() <= failSafeLimit);

        // BK Ok
        if (_toFund > 0) {
            // BK Ok
            uint256 tokensGenerated = _toFund.mul(exchangeRate);
            // BK Ok
            assert(SNT.generateTokens(_th, tokensGenerated));
            // BK Ok - Transfer ETH to ContributionWallet
            destEthDevs.transfer(_toFund);
            // BK Ok - Log sale
            NewSale(_th, _toFund, tokensGenerated, _guaranteed);
        }

        // BK Ok - Amount to refund if over the contribution limit
        uint256 toReturn = msg.value.sub(_toFund);
        // BK Ok
        if (toReturn > 0) {
            // If the call comes from the Token controller,
            // then we return it to the token Holder.
            // Otherwise we return to the sender.
            // BK Ok
            if (msg.sender == address(SNT)) {
                _th.transfer(toReturn);
            } else {
                msg.sender.transfer(toReturn);
            }
        }
    }

    // NOTE on Percentage format
    // Right now, Solidity does not support decimal numbers. (This will change very soon)
    //  So in this contract we use a representation of a percentage that consist in
    //  expressing the percentage in "x per 10**18"
    // This format has a precision of 16 digits for a percent.
    // Examples:
    //  3%   =   3*(10**16)
    //  100% = 100*(10**16) = 10**18
    //
    // To get a percentage of a value we do it by first multiplying it by the percentage in  (x per 10^18)
    //  and then divide it by 10**18
    //
    //              Y * X(in x per 10**18)
    //  X% of Y = -------------------------
    //               100(in x per 10**18)
    //


    /// @notice This method will can be called by the owner before the contribution period
    ///  end or by anybody after the `endBlock`. This method finalizes the contribution period
    ///  by creating the remaining tokens and transferring the controller to the configured
    ///  controller.
    // BK Ok - Can only finalise if initialised
    function finalize() public initialized {
        // BK Ok - Can only finalise after start block
        require(getBlockNumber() >= startBlock);
        // BK Ok - Owner can finalise before end block, anyone can finalise otherwise
        require(msg.sender == owner || getBlockNumber() > endBlock);
        // BK Ok - Cannot finalise more than once
        require(finalizedBlock == 0);

        // Do not allow termination until all curves revealed.
        // BK Ok - Can only finalise when all the curves have been revealed
        require(dynamicCeiling.allRevealed());

        // Allow premature finalization if final limit is reached
        // BK Ok - Finalising before end block
        if (getBlockNumber() <= endBlock) {
            // BK Ok - Find last limit - not the zero amount
            var (,lastLimit,,) = dynamicCeiling.curves(dynamicCeiling.revealedCurves().sub(1));
            // BK Ok - Can only finalise prematurely if the final limit is reached
            require(totalNormalCollected >= lastLimit);
        }

        // BK Ok - Record the block number finalised at
        finalizedBlock = getBlockNumber();
        // BK Ok - Record the block time finalised at
        finalizedTime = now;

        uint256 percentageToSgt;
        // BK Ok - Max 10%
        if (SGT.totalSupply() >= maxSGTSupply) {
            percentageToSgt = percent(10);  // 10%
        } else {

            //
            //                           SGT.totalSupply()
            //  percentageToSgt = 10% * -------------------
            //                             maxSGTSupply
            //
            percentageToSgt = percent(10).mul(SGT.totalSupply()).div(maxSGTSupply);
        }

        // BK Ok
        uint256 percentageToDevs = percent(20);  // 20%


        //
        //  % To Contributors = 41% + (10% - % to SGT holders)
        //
        // BK Ok
        uint256 percentageToContributors = percent(41).add(percent(10).sub(percentageToSgt));

        // BK Ok
        uint256 percentageToReserve = percent(29);


        // SNT.totalSupply() -> Tokens minted during the contribution
        //  totalTokens  -> Total tokens that should be after the allocation
        //                   of devTokens, sgtTokens and reserve
        //  percentageToContributors -> Which percentage should go to the
        //                               contribution participants
        //                               (x per 10**18 format)
        //  percent(100) -> 100% in (x per 10**18 format)
        //
        //                       percentageToContributors
        //  SNT.totalSupply() = -------------------------- * totalTokens  =>
        //                             percent(100)
        //
        //
        //                            percent(100)
        //  =>  totalTokens = ---------------------------- * SNT.totalSupply()
        //                      percentageToContributors
        //
        // BK Ok
        uint256 totalTokens = SNT.totalSupply().mul(percent(100)).div(percentageToContributors);


        // Generate tokens for SGT Holders.

        //
        //                    percentageToReserve
        //  reserveTokens = ----------------------- * totalTokens
        //                      percentage(100)
        //
        // BK Ok
        assert(SNT.generateTokens(
            destTokensReserve,
            totalTokens.mul(percentageToReserve).div(percent(100))));

        //
        //                  percentageToSgt
        //  sgtTokens = ----------------------- * totalTokens
        //                   percentage(100)
        //
        // BK Ok
        assert(SNT.generateTokens(
            destTokensSgt,
            totalTokens.mul(percentageToSgt).div(percent(100))));


        //
        //                   percentageToDevs
        //  devTokens = ----------------------- * totalTokens
        //                   percentage(100)
        //
        // BK Ok
        assert(SNT.generateTokens(
            destTokensDevs,
            totalTokens.mul(percentageToDevs).div(percent(100))));

        // BK Ok
        SNT.changeController(sntController);

        // BK Ok - Log message
        Finalized();
    }

    // BK Ok
    function percent(uint256 p) internal returns (uint256) {
        // BK Ok
        return p.mul(10**16);
    }

    /// @dev Internal function to determine if an address is a contract
    /// @param _addr The address being queried
    /// @return True if `_addr` is a contract
    // BK Ok
    function isContract(address _addr) constant internal returns (bool) {
        if (_addr == 0) return false;
        uint256 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }


    //////////
    // Constant functions
    //////////

    /// @return Total tokens issued in weis.
    // BK Ok - Information function
    function tokensIssued() public constant returns (uint256) {
        return SNT.totalSupply();
    }

    /// @return Total Ether collected.
    // BK Ok - Information function
    function totalCollected() public constant returns (uint256) {
        return totalNormalCollected.add(totalGuaranteedCollected);
    }


    //////////
    // Testing specific methods
    //////////

    /// @notice This function is overridden by the test Mocks.
    // BK Ok
    function getBlockNumber() internal constant returns (uint256) {
        return block.number;
    }


    //////////
    // Safety Methods
    //////////

    /// @notice This method can be used by the controller to extract mistakenly
    ///  sent tokens to this contract.
    /// @param _token The address of the token contract that you want to recover
    ///  set to 0 in case you want to extract ether.
    // BK Ok
    function claimTokens(address _token) public onlyOwner {
        // BK Ok - This tokens
        if (SNT.controller() == address(this)) {
            SNT.claimTokens(_token);
        }
        // BK Ok - ETH
        if (_token == 0x0) {
            owner.transfer(this.balance);
            return;
        }

        // BK Ok - Any other ERC20 tokens 
        ERC20Token token = ERC20Token(_token);
        uint256 balance = token.balanceOf(this);
        token.transfer(owner, balance);
        ClaimedTokens(_token, owner, balance);
    }


    /// @notice Pauses the contribution if there is any issue
    // BK Ok - Owner can pause contributions
    function pauseContribution() onlyOwner {
        paused = true;
    }

    /// @notice Resumes the contribution
    // BK Ok - Owner can resume contributions
    function resumeContribution() onlyOwner {
        paused = false;
    }

    // BK Ok - Events
    event ClaimedTokens(address indexed _token, address indexed _controller, uint256 _amount);
    event NewSale(address indexed _th, uint256 _amount, uint256 _tokens, bool _guaranteed);
    event GuaranteedAddress(address indexed _th, uint256 _limit);
    event Finalized();
}
```