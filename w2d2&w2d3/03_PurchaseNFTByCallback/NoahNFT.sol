// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// ERC721: NFT 标准
// 实际的合约应该不需要导入, 直接实现 IERC165, IERC721 接口即可
// import "./IERC165.sol";
// import "./IERC721.sol";

// 或者直接使用 OpenZeppelin 的合约, 直接继承 ERC721URIStorage 合约即可
// import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
// import "@openzeppelin/contracts/utils/Counters.sol";

// 为了学习, 我自己实现一遍这个接口, 拷贝了 Skeleton
// 看了一眼, ERC721UIRStorage 合约继承了 IERC4096接口(强制要求实现接口内的方法) 以及 ERC721
// 下面的代码模版拷贝自 OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/ERC721.sol)

// 因此我直接用别人实现好的 -> OpenZeppelin
// 在 Openzeppelin 5.x 中, Counter.sol 已经被移除(因为会给别人误导 以及 作用不大), 可以通过自定义 private 自增变量代替
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract NoahNFT is ERC721URIStorage {
    uint256 private _tokenIds;

    constructor() ERC721("NoahNFT", "Noah_0x3F") {}

    function mint(address to, string memory tokenURI) public returns (uint256) {
        uint256 newItemId = _tokenIds;
        _mint(to, newItemId);
        _setTokenURI(newItemId, tokenURI);

        _tokenIds++;
        return newItemId;
    }
}
