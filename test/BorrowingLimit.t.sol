// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../src/BorrowingLimit.sol";

contract BorrowingLimitTest {
    BorrowingLimit private target;

    function setUp() public {
        target = new BorrowingLimit();
    }

    function testBorrowWithinLimit() public view {
        require(target.canBorrow(1000, 500, 200, 7500), "should allow");
    }

    function testBorrowOverLimit() public view {
        require(!target.canBorrow(1000, 500, 300, 7500), "should deny");
    }

    function testBorrowExactlyAtLimit() public view {
        require(target.canBorrow(1000, 500, 250, 7500), "should allow the boundary");
    }

    function testZeroCollateralDoesNotAllowBorrow() public view {
        require(!target.canBorrow(0, 0, 1, 7500), "should deny");
    }

    function testInvalidLtvReverts() public {
        (bool ok,) = address(target).call(
            abi.encodeWithSignature("canBorrow(uint256,uint256,uint256,uint256)", 1000, 0, 100, 10001)
        );
        require(!ok, "invalid ltv should revert");
    }
}
