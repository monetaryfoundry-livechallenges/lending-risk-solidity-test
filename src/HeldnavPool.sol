// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./MarketRegistry.sol";
import "./interfaces/IBorrowingLimit.sol";

contract HeldnavPool {
    struct Position {
        bytes32 marketId;
        address owner;
        uint256 collateralValue;
        uint256 debt;
        bool exists;
    }

    MarketRegistry public immutable registry;
    IBorrowingLimit public immutable limits;

    mapping(bytes32 => Position) private positions;

    error UnknownPosition(bytes32 id);
    error PositionExists(bytes32 id);
    error RepayExceedsDebt();

    constructor(MarketRegistry registry_, IBorrowingLimit limits_) {
        registry = registry_;
        limits = limits_;
    }

    function openPosition(bytes32 positionId, bytes32 marketId_, address owner, uint256 collateralValue) external {
        if (positions[positionId].exists) revert PositionExists(positionId);
        registry.getMarket(marketId_);
        positions[positionId] = Position(marketId_, owner, collateralValue, 0, true);
    }

    function supply(bytes32 positionId, uint256 amount) external {
        Position storage position = positions[positionId];
        if (!position.exists) revert UnknownPosition(positionId);
        position.collateralValue += amount;
    }

    function repay(bytes32 positionId, uint256 amount) external {
        Position storage position = positions[positionId];
        if (!position.exists) revert UnknownPosition(positionId);
        if (amount > position.debt) revert RepayExceedsDebt();
        position.debt -= amount;
    }

    function getPosition(bytes32 positionId) external view returns (bytes32, address, uint256, uint256) {
        Position storage position = positions[positionId];
        if (!position.exists) revert UnknownPosition(positionId);
        return (position.marketId, position.owner, position.collateralValue, position.debt);
    }

    function borrow(bytes32 positionId, uint256 additionalBorrow) external returns (bool allowed) {
        Position storage position = positions[positionId];
        if (!position.exists) revert UnknownPosition(positionId);
        (, , uint256 maxLtvBps) = registry.getMarket(position.marketId);
        allowed = limits.canBorrow(position.collateralValue, position.debt, additionalBorrow, maxLtvBps);
        if (allowed) {
            position.debt += additionalBorrow;
        }
    }
}
