// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Test, console} from "forge-std/Test.sol";
import {NoahNFTMarket} from "../src/NoahNFTMarket.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MockERC20 is ERC20 {
    constructor() ERC20("Mock Token", "MTK") {
        _mint(msg.sender, 1000000 * 10 ** 18);
    }
}

contract MockERC721 is ERC721 {
    constructor() ERC721("Mock NFT", "MNFT") {}

    function mint(address to, uint256 tokenId) public {
        _mint(to, tokenId);
    }
}

contract NoahNFTMarketTest is Test {
    NoahNFTMarket private market;
    MockERC20 private token;
    MockERC721 private nft;

    function setUp() public {
        vm.startPrank(address(0xBEEF));
        token = new MockERC20();
        vm.stopPrank();

        nft = new MockERC721();
        market = new NoahNFTMarket(address(token), address(nft));

        // Mint NFT to the test address
        nft.mint(address(this), 1);
        // Approve market to transfer NFT
        nft.approve(address(market), 1);
        // Mint tokens to buyer
        // token.mint(address(0xBEEF), 1000 * 10 ** 18);
    }

    function testList() public {
        market.list(1, 500 * 10 ** 18);
        assertEq(market.tokenIdPrice(1), 500 * 10 ** 18);
        assertEq(market.tokenSeller(1), address(this));
    }

    function testPurchase() public {
        // Setup listing first
        market.list(1, 500 * 10 ** 18);

        vm.prank(address(0xBEEF));
        token.approve(address(market), 500 * 10 ** 18);

        // Buying process
        vm.prank(address(0xBEEF));
        market.purchase(1);

        // Check new owner of the NFT
        assertEq(nft.ownerOf(1), address(0xBEEF));

        // Check seller received funds
        assertEq(token.balanceOf(address(this)), 500 * 10 ** 18);
    }

    // function testListWithoutApproval() public {
    //     nft.revokeApproval(address(market), 1); // Revoke approval for the market
    //     vm.expectRevert("ERC721: transfer caller is not owner nor approved");
    //     market.list(1, 500 * 10 ** 18);
    // }

    function testPurchaseNonexistentNFT() public {
        vm.expectRevert("aleady selled");
        vm.prank(address(0xBEEF));
        market.purchase(1);
    }

    function testPurchaseWithoutSufficientTokens() public {
        // Setup listing first
        market.list(1, 500 * 10 ** 18);

        vm.prank(address(0xBEEF));
        token.approve(address(market), 100 * 10 ** 18); // 授权代币数量不足

        bytes memory revertData = abi.encodeWithSelector(
            IERC20Errors.ERC20InsufficientAllowance.selector, address(market), 100 * 10 ** 18, 500 * 10 ** 18
        );

        vm.prank(address(0xBEEF));
        vm.expectRevert(revertData);
        market.purchase(1);
    }
}
