// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./interfaces/IBorrowingLimit.sol";

contract BorrowingLimit is IBorrowingLimit {
    uint256 public constant BPS_DENOMINATOR = 10_000;
    error InvalidLTV();

    function canBorrow(
        uint256 collateralValue,
        uint256 existingDebt,
        uint256 additionalBorrow,
        uint256 maxLtvBps
    ) external pure returns (bool) {
        // TODO: implement the check. Avoid unchecked arithmetic.
        if (maxLtvBps > BPS_DENOMINATOR) revert InvalidLTV();
        return false;
    }
}
