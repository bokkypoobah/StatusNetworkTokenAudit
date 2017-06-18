# DevTokensHolder.md

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

/// @title DevTokensHolder Contract
/// @author Jordi Baylina
/// @dev This contract will hold the tokens of the developers.
///  Tokens will not be able to be collected until 6 months after the contribution
///  period ends. And it will be increasing linearly until 2 years.


//  collectable tokens
//   |                         _/--------   vestedTokens rect
//   |                       _/
//   |                     _/
//   |                   _/
//   |                 _/
//   |               _/
//   |             _/
//   |           _/
//   |          |
//   |        . |
//   |      .   |
//   |    .     |
//   +===+======+--------------+----------> time
//     Contrib   6 Months       24 Months
//       End


import "./MiniMeToken.sol";
import "./StatusContribution.sol";
import "./SafeMath.sol";
import "./ERC20Token.sol";

// BK Ok
// BK Needs to be tested to confirm interconnected operations
contract DevTokensHolder is Owned {
    // BK Using safe maths
    using SafeMath for uint256;

    // BK Next 3 lines Ok
    uint256 collectedTokens;
    StatusContribution contribution;
    MiniMeToken snt;

    // BK Constructor Ok
    function DevTokensHolder(address _owner, address _contribution, address _snt) {
        // BK Note that the owner assigned in the Owned constructor is re-assigned here
        owner = _owner;
        // BK Ok - Reference to crowdsale contract
        contribution = StatusContribution(_contribution);
        // BK Ok - Reference to SNT contract
        snt = MiniMeToken(_snt);
    }


    /// @notice The Dev (Owner) will call this method to extract the tokens
    function collectTokens() public onlyOwner {
        // BK Ok - This is the current SNT balance
        uint256 balance = snt.balanceOf(address(this));
        // BK Ok - collectedTokens is the sum of all SNTs collected previously
        // BK Ok - total is the sum of all collected and uncollected SNTs
        uint256 total = collectedTokens.add(balance);

        // BK Ok - Time crowdsale is finalised
        uint256 finalizedTime = contribution.finalizedTime();

        // BK Ok - Check that finalised time is filled, and we are now 6 months after the finalised time
        require(finalizedTime > 0 && getTime() > finalizedTime.add(months(6)));

        // BK Ok - Amount that can be extracted
        //         = total * (now - finalised)/24 months
        uint256 canExtract = total.mul(getTime().sub(finalizedTime)).div(months(24));

        // BK Ok - And subtract amount already collected
        canExtract = canExtract.sub(collectedTokens);

        // BK Ok - Checking minimum, probably for rounding
        if (canExtract > balance) {
            canExtract = balance;
        }

        // BK Ok - Keep track of the total collected 
        collectedTokens = collectedTokens.add(canExtract);
        // BK Ok - Transfer the amount
        assert(snt.transfer(owner, canExtract));

        TokensWithdrawn(owner, canExtract);
    }

    // BK Could be marked as constant, but internal anyway
    function months(uint256 m) internal returns (uint256) {
        return m.mul(30 days);
    }

    // BK Could be marked as constant, but internal anyway
    function getTime() internal returns (uint256) {
        return now;
    }


    //////////
    // Safety Methods
    //////////

    /// @notice This method can be used by the controller to extract mistakenly
    ///  sent tokens to this contract.
    /// @param _token The address of the token contract that you want to recover
    ///  set to 0 in case you want to extract ether.
    // BK Ok - Only the specified owner can withdraw tokens held by ths contract address
    function claimTokens(address _token) public onlyOwner {
        // BK Ok - Restriction so SNTs cannot be withdrawn early
        require(_token != address(snt));
        // BK Ok - Can move any ethers trapped here. There is no payable functions so there should be no ETH in this contract anyway 
        if (_token == 0x0) {
            // BK Ok - Safe as only the owner can execute this
            owner.transfer(this.balance);
            return;
        }

        // BK Next 4 lines Ok
        ERC20Token token = ERC20Token(_token);
        uint256 balance = token.balanceOf(this);
        token.transfer(owner, balance);
        ClaimedTokens(_token, owner, balance);
    }

    event ClaimedTokens(address indexed _token, address indexed _controller, uint256 _amount);
    event TokensWithdrawn(address indexed _holder, uint256 _amount);
}
```