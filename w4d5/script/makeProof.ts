const { MerkleTree } = require('merkletreejs');
const keccak256 = require('keccak256');
const { ethers } = require('ethers');

// 白名单数据
const whitelist = [
  { address: '0x123...', amount: 100 },
  { address: '0x456...', amount: 200 },
  { address: '0x789...', amount: 300 },
  { address: '0xabc...', amount: 400 },
  { address: '0xdef...', amount: 500 },
  { address: '0xghi...', amount: 600 },
  { address: '0xjkl...', amount: 700 },
  { address: '0xmno...', amount: 800 }
];

// 计算叶节点
const leaves = whitelist.map(x => 
  keccak256(ethers.utils.defaultAbiCoder.encode(
    ["address", "uint256"],
    [x.address, x.amount]
  ))
);

// 创建 Merkle Tree
const tree = new MerkleTree(leaves, keccak256, { sortPairs: true });

// 获取 merkleRoot
const root = tree.getRoot().toString('hex');
console.log("Merkle Root:", root);

// 获取 leaf1 的 Merkle Proof
const userAddress = '0x123...';
const userAmount = 100;
const leaf = keccak256(ethers.utils.defaultAbiCoder.encode(
  ["address", "uint256"],
  [userAddress, userAmount]
));

// getProof返回的数组中, 包含的信息是 leaf 到 root 的路径上所有的必要的节点, map 之后就是所有必要节点的 hash 值
const proof = tree.getProof(leaf).map(x => x.data.toString('hex'));
console.log("Merkle Proof for user:", proof);