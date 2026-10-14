// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../src/HeldnavPool.sol";
import "../src/BorrowingLimit.sol";
import "../src/MarketRegistry.sol";

contract HeldnavPoolTest {
    MarketRegistry private registry;
    BorrowingLimit private limits;
    HeldnavPool private pool;
    bytes32 private positionId;

    function setUp() public {
        registry = new MarketRegistry();
        limits = new BorrowingLimit();
        pool = new HeldnavPool(registry, limits);
        positionId = keccak256("pos-1002");
        pool.openPosition(positionId, registry.marketId("eth-usdc"), address(0xB0B), 1000);
    }

    function testSupplyIncreasesCollateral() public {
        pool.supply(positionId, 250);
        (, , uint256 collateral,) = pool.getPosition(positionId);
        require(collateral == 1250, "collateral");
    }

    function testBorrowOverLimitDoesNotIncreaseDebt() public {
        require(!pool.borrow(positionId, 800), "should deny");
        (, , , uint256 debt) = pool.getPosition(positionId);
        require(debt == 0, "debt unchanged");
    }

    function testBorrowWithinLimitIncreasesDebt() public {
        require(pool.borrow(positionId, 200), "should allow");
        (, , , uint256 debt) = pool.getPosition(positionId);
        require(debt == 200, "debt should increase");
    }

    function testRepayWithNoDebtReverts() public {
        (bool ok,) = address(pool).call(abi.encodeWithSignature("repay(bytes32,uint256)", positionId, 1));
        require(!ok, "repay should revert");
    }

    function testUnknownMarketCannotOpen() public {
        (bool ok,) = address(pool).call(
            abi.encodeWithSignature(
                "openPosition(bytes32,bytes32,address,uint256)",
                keccak256("pos-x"),
                keccak256("missing"),
                address(this),
                1
            )
        );
        require(!ok, "unknown market should revert");
    }
}
