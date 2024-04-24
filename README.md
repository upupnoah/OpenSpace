# OpenSpace
> 使用 Rust/Go/Solidity

## Logs
### w1d1
- [x] POW
- [x] RSA

### w1d2
- [x] 最小区块链
  
### w1d3
- [x] Ethereum Concept
- [x] Counter contract

### w1d4
- [x] Bank contract

### w1d5
- [x] Big Bank

### w2d1
- [x] ERC20 token contract
- [x] TokenBank

### w2d2
- [x] ERC721 token contract (NFT)
- [x] NFT Market
- [] 扩展 ERC20 合约，使其具备在转账的时候，如果目标地址是合约的话，调用目标地址的 tokensReceived() 方法
- [] 扩展 TokenBank, 在TokenBank 中利用上一题的转账回调实现存款
- [] 扩展挑战Token 购买 NFT 合约，能够使用ERC20扩展中的回调函数来购买某个 NFT ID