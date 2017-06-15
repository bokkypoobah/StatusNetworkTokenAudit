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

/// @title DynamicCeiling Contract
/// @author Jordi Baylina
/// @dev This contract calculates the ceiling from a series of curves.
///  These curves are committed first and revealed later.
///  All the curves must be in increasing order and the last curve is marked
///  as the last one.
///  This contract allows to hide and reveal the ceiling at will of the owner.


import "./SafeMath.sol";
import "./Owned.sol";

// BK For easier reading, `Curve` should be renamed `Point` as these represent points in the curve
contract DynamicCeiling is Owned {
    using SafeMath for uint256;

    // BK Should be `struct Point`
    struct Curve {
        bytes32 hash;
        // Absolute limit for this curve
        uint256 limit;
        // The funds remaining to be collected are divided by `slopeFactor` smooth ceiling
        // with a long tail where big and small buyers can take part.
        uint256 slopeFactor;
        // This keeps the curve flat at this number, until funds to be collected is less than this
        uint256 collectMinimum;
    }

    address public contribution;

    // BK Should be `Point[] public points` or `Point[] public curve` as this structure represents points in a single curve
    Curve[] public curves;
    uint256 public currentIndex;
    // BK Should be revealedPoints
    uint256 public revealedCurves;
    bool public allRevealed;

    /// @dev `contribution` is the only address that can call a function with this
    /// modifier
    modifier onlyContribution {
        require(msg.sender == contribution);
        _;
    }

    function DynamicCeiling(address _owner, address _contribution) {
        owner = _owner;
        contribution = _contribution;
    }

    // BK Testing
    event HashSet(uint256 index, bytes32 hash);
    // BK Testing
    event CurvePointRevealed(uint256 limit, uint256 slopeFactor, uint256 collectMinimum,
        bool last, bytes32 salt);

    /// @notice This should be called by the creator of the contract to commit
    ///  all the curves.
    /// @param _curveHashes Array of hashes of each curve. Each hash is calculated
    ///  by the `calculateHash` method. More hashes than actual curves can be
    ///  committed in order to hide also the number of curves.
    ///  The remaining hashes can be just random numbers.
    // BK Only the owner can call
    function setHiddenCurves(bytes32[] _curveHashes) public onlyOwner {
        // BK Only the owner can call once
        require(curves.length == 0);

        curves.length = _curveHashes.length;
        for (uint256 i = 0; i < _curveHashes.length; i = i.add(1)) {
            curves[i].hash = _curveHashes[i];
            // BK Testing
            HashSet(i, _curveHashes[i]);
        }
    }


    /// @notice Anybody can reveal the next curve if he knows it.
    /// @param _limit Ceiling cap.
    ///  (must be greater or equal to the previous one).
    /// @param _last `true` if it's the last curve.
    /// @param _salt Random number used to commit the curve
    // BK Anyone can call this, but they will have to know the curve point that
    //    generated the hashes that was set by the owner
    // BK In effect, accounts controlled by the owner will be able to call this function
    // BK The setting of the initial data and the revealed data will need to be exactly
    //    accurate, or else the curve point cannot be revealed correctly
    // BK In the worst case, the first cap is revealed and an error prevents the next
    //    cap in being revealed, resulting in only the first cap being effective for
    //    the whole crowdsale period
    function revealCurve(uint256 _limit, uint256 _slopeFactor, uint256 _collectMinimum,
                         bool _last, bytes32 _salt) public {
        // BK Cannot reveal if all already revealed
        require(!allRevealed);

        // BK Hash for the curve point being revealed must match the hash of the 
        //    hidden caps
        require(curves[revealedCurves].hash == keccak256(_limit, _slopeFactor, _collectMinimum,
                                                         _last, _salt));

        // BK Just checking for non nulls.
        //    Ideally this check should be done when constructing the hashes
        //    as once the hashes are set, you cannot set with invalid data 
        require(_limit != 0 && _slopeFactor != 0 && _collectMinimum != 0);
        // BK Next limit (after the first) must be greater than the previous
        if (revealedCurves > 0) {
            require(_limit >= curves[revealedCurves.sub(1)].limit);
        }

        // BK Set the data
        curves[revealedCurves].limit = _limit;
        curves[revealedCurves].slopeFactor = _slopeFactor;
        curves[revealedCurves].collectMinimum = _collectMinimum;
        // BK This point has been revealed, this is the next point to be revealed
        revealedCurves = revealedCurves.add(1);

        // BK What happens if the hash and yet-to-be-revealed points is incorrect
        if (_last) allRevealed = true;
        // BK Testing
        CurvePointRevealed(_limit, _slopeFactor, _collectMinimum, _last, _salt);
    }

    /// @notice Reveal multiple curves at once
    // BK Anyone can call this, but they will have to know the curve point that
    //    generated the hashes that was set by the owner
    function revealMulti(uint256[] _limits, uint256[] _slopeFactors, uint256[] _collectMinimums,
                         bool[] _lasts, bytes32[] _salts) public {
        // Do not allow none and needs to be same length for all parameters
        require(_limits.length != 0 &&
                _limits.length == _slopeFactors.length &&
                _limits.length == _collectMinimums.length &&
                _limits.length == _lasts.length &&
                _limits.length == _salts.length);

        // BK Can reveal the sets of points in batches
        for (uint256 i = 0; i < _limits.length; i = i.add(1)) {
            revealCurve(_limits[i], _slopeFactors[i], _collectMinimums[i],
                        _lasts[i], _salts[i]);
        }
    }

    /// @notice Move to curve, used as a failsafe
    // BK Only the owner can call this. What happens if the owner is unable to get
    //    their transaction mined?
    function moveTo(uint256 _index) public onlyOwner {
        // BK Can only move the index to up to the revealed points
        // BK Can only move up one point in the curve
        require(_index < revealedCurves &&       // No more curves
                _index == currentIndex.add(1));  // Only move one index at a time
        // BK Save new current index
        currentIndex = _index;
    }

    /// @return Return the funds to collect for the current point on the curve
    ///  (or 0 if no curves revealed yet)
    function toCollect(uint256 collected) public onlyContribution returns (uint256) {
        if (revealedCurves == 0) return 0;

        // Move to the next curve
        if (collected >= curves[currentIndex].limit) {  // Catches `limit == 0`
            uint256 nextIndex = currentIndex.add(1);
            if (nextIndex >= revealedCurves) return 0;  // No more curves
            currentIndex = nextIndex;
            if (collected >= curves[currentIndex].limit) return 0;  // Catches `limit == 0`
        }

        // Everything left to collect from this limit
        uint256 difference = curves[currentIndex].limit.sub(collected);

        // Current point on the curve
        uint256 collect = difference.div(curves[currentIndex].slopeFactor);

        // Prevents paying too much fees vs to be collected; breaks long tail
        if (collect <= curves[currentIndex].collectMinimum) {
            if (difference > curves[currentIndex].collectMinimum) {
                return curves[currentIndex].collectMinimum;
            } else {
                return difference;
            }
        } else {
            return collect;
        }
    }

    /// @notice Calculates the hash of a curve.
    /// @param _limit Ceiling cap.
    /// @param _last `true` if it's the last curve.
    /// @param _salt Random number that will be needed to reveal this curve.
    /// @return The calculated hash of this curve to be used in the `setHiddenCurves` method
    // BK Could consider checking the parameters here
    function calculateHash(uint256 _limit, uint256 _slopeFactor, uint256 _collectMinimum,
                           bool _last, bytes32 _salt) public constant returns (bytes32) {
        return keccak256(_limit, _slopeFactor, _collectMinimum, _last, _salt);
    }

    /// @return Return the total number of curves committed
    ///  (can be larger than the number of actual curves on the curve to hide
    ///  the real number of curves)
    function nCurves() public constant returns (uint256) {
        return curves.length;
    }

}
