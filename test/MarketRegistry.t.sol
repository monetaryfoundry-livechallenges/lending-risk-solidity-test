// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../src/MarketRegistry.sol";

contract MarketRegistryTest {
    MarketRegistry private registry;

    function setUp() public {
        registry = new MarketRegistry();
    }

    function testSeedsThreeMarkets() public view {
        require(registry.marketCount() == 3, "expected three markets");
        (string memory collateral, string memory debt, uint256 maxLtv) = registry.getMarket(registry.marketId("eth-usdc"));
        require(keccak256(bytes(collateral)) == keccak256("ETH"), "collateral");
        require(keccak256(bytes(debt)) == keccak256("USDC"), "debt");
        require(maxLtv == 7500, "ltv");
    }

    function testRejectsDuplicateMarket() public {
        bytes32 id = registry.marketId("eth-usdc");
        (bool ok,) = address(registry).call(
            abi.encodeWithSignature("addMarket(bytes32,string,string,uint256)", id, "ETH", "USDC", 7500)
        );
        require(!ok, "duplicate market should revert");
    }

    function testAddsAnotherMarket() public {
        registry.addMarket(registry.marketId("dai-usdc"), "DAI", "USDC", 8000);
        require(registry.marketCount() == 4, "expected four markets");
    }
}
