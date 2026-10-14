// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IBorrowingLimit {
    function canBorrow(
        uint256 collateralValue,
        uint256 existingDebt,
        uint256 additionalBorrow,
        uint256 maxLtvBps
    ) external pure returns (bool);
}
