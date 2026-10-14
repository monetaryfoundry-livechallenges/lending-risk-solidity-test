// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract MarketRegistry {
    struct Market {
        string collateralSymbol;
        string debtSymbol;
        uint256 maxLtvBps;
        bool exists;
    }

    mapping(bytes32 => Market) private markets;
    bytes32[] private ids;

    error UnknownMarket(bytes32 id);
    error MarketExists(bytes32 id);
    error MarketLtvTooHigh();

    constructor() {
        _add(marketId("eth-usdc"), "ETH", "USDC", 7_500);
        _add(marketId("wbtc-usdc"), "WBTC", "USDC", 7_000);
        _add(marketId("steth-usdc"), "stETH", "USDC", 6_500);
    }

    function marketId(string memory name) public pure returns (bytes32) {
        return keccak256(bytes(name));
    }

    function addMarket(
        bytes32 id,
        string calldata collateralSymbol,
        string calldata debtSymbol,
        uint256 maxLtvBps
    ) external {
        _add(id, collateralSymbol, debtSymbol, maxLtvBps);
    }

    function getMarket(bytes32 id) external view returns (string memory, string memory, uint256) {
        Market storage market = markets[id];
        if (!market.exists) revert UnknownMarket(id);
        return (market.collateralSymbol, market.debtSymbol, market.maxLtvBps);
    }

    function marketCount() external view returns (uint256) {
        return ids.length;
    }

    function marketIdAt(uint256 index) external view returns (bytes32) {
        return ids[index];
    }

    function _add(bytes32 id, string memory collateralSymbol, string memory debtSymbol, uint256 maxLtvBps) private {
        if (markets[id].exists) revert MarketExists(id);
        if (maxLtvBps > 10_000) revert MarketLtvTooHigh();
        markets[id] = Market(collateralSymbol, debtSymbol, maxLtvBps, true);
        ids.push(id);
    }
}
