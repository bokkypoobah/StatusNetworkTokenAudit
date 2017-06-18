### ContributionWallet.sol

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

/// @title ContributionWallet Contract
/// @author Jordi Baylina
/// @dev This contract will be hold the Ether during the contribution period.
///  The idea of this contract is to avoid recycling Ether during the contribution
///  period. So all the ETH collected will be locked here until the contribution
///  period ends

// @dev Contract to hold sale raised funds during the sale period.
// Prevents attack in which the Aragon Multisig sends raised ether
// to the sale contract to mint tokens to itself, and getting the
// funds back immediately.


import "./StatusContribution.sol";


// BK Ok - Note that there is no owner, but this contract's withdraw() function is restricted to the multisig address
// BK Needs to be tested to confirm interconnected operations
contract ContributionWallet {

    // Public variables
    // BK Ok
    address public multisig;
    // BK Ok
    uint256 public endBlock;
    // BK Ok - This is to check whether the crowdsale has been finalised
    StatusContribution public contribution;

    // @dev Constructor initializes public variables
    // @param _multisig The address of the multisig that will receive the funds
    // @param _endBlock Block after which the multisig can request the funds
    // @param _contribution Address of the StatusContribution contract
    // BK Ok
    function ContributionWallet(address _multisig, uint256 _endBlock, address _contribution) {
        // BK Ok
        require(_multisig != 0x0);
        // BK Ok
        require(_contribution != 0x0);
        // BK Ok - End block needs to be specified and before a particular block number
        require(_endBlock != 0 && _endBlock <= 4000000);
        // BK Next 3 lines Ok
        multisig = _multisig;
        endBlock = _endBlock;
        contribution = StatusContribution(_contribution);
    }

    // @dev Receive all sent funds without any further logic
    // BK Ok - This function allows this contract to receive all ETH sent to it
    function () public payable {}

    // @dev Withdraw function sends all the funds to the wallet if conditions are correct
    // BK Ok - Only the multisig can withdraw funds, after a specified block or when the crowdsale has been finalised
    function withdraw() public {
        // BK Ok - Only the multisig can withdraw the funds
        require(msg.sender == multisig);              // Only the multisig can request it
        // BK Ok - Funds can be withdrawn after the specified endBlock, or when the the crowdsale has been finalised
        require(block.number > endBlock ||            // Allow after end block
                contribution.finalizedBlock() != 0);  // Allow when sale is finalized
        // BK Ok - Safe as only the multisig can execute this function
        multisig.transfer(this.balance);
    }

}
```