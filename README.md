# Heldnav Lending Risk (Solidity)

Foundry project for the Heldnav collateral desk. `MarketRegistry` lists markets, `HeldnavPool` records positions, and borrows are gated by `BorrowingLimit`.

Requires Foundry and Solidity 0.8.24. Run `forge test` from this directory. No external packages are needed.

`MarketRegistry` tests pass. `testBorrowWithinLimit`, `testBorrowExactlyAtLimit`, and `testBorrowWithinLimitIncreasesDebt` fail until `canBorrow` is implemented.

## Layout

- `src/MarketRegistry.sol` seeds ETH, WBTC, and stETH markets
- `src/HeldnavPool.sol` opens positions and calls the borrowing limit before increasing debt
- `src/interfaces/IBorrowingLimit.sol` is the check the pool depends on
- `src/BorrowingLimit.sol` is the unfinished check

## Candidate task: complete `canBorrow`

Implement only `canBorrow` in `src/BorrowingLimit.sol`. Return `true` when the total debt after the proposed borrow is at or below the maximum debt, otherwise return `false`. If LTV is above 10,000, revert with the existing `InvalidLTV` error.

1. `maxDebt = collateralValue * maxLtvBps / 10_000`, using integer division.
2. `totalDebt = existingDebt + additionalBorrow`.
3. Return `true` when `totalDebt <= maxDebt`. Borrowing exactly at the limit is allowed.

Solidity's checked arithmetic is sufficient. Do not add a math library or change the tests.
