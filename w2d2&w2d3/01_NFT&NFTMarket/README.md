# NOTE

## Step
### NFT
1. 写好 721 合约
2. 在 ipfs 中发布图片 和 上传图片的 json, mint 的时候填入 json 的 ipfs 地址
3. 这样在 open sea 上就可以看到图片了

### NFT Market
- 维护每个 tokenid 对应的价格
- 维护每个 tokenid 对应的卖家address
- 维护 token 和 nftToken 的地址 -> 可以卸载 constructor 中, 在部署的时候传入
```solidity
    mapping(uint => uint) public tokenIdPrice;
    mapping(uint => address) public tokenSeller;
    address public immutable token;
    address public immutable nftToken;
```
- List
- Purchase