// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// 在以太坊上⽤ ERC20 模拟铭⽂铸造，编写一个可以通过最⼩代理来创建ERC20 的⼯⼚合约，⼯⼚合约包含两个方法：
// 1. deployInscription(string symbol, uint totalSupply, uint perMint, uint price),
// ⽤户调⽤该⽅法创建 ERC20 Token合约，symbol 表示新创建代币的代号（ ERC20 代币名字可以使用固定的），
// totalSupply 表示总发行量, perMint 表示单次的创建量, price 表示每个代币铸造时需要的费用（wei 计价）。
// 每次铸造费用在扣除手续费后（手续费请自定义）由调用该方法的用户收取
// 2. mintInscription(address tokenAddr) payable: 每次调用发行创建时确定的 perMint 数量的 token，并收取相应的费用

// 测试用例要求:
// 1. 费用按比例正确分配到发行者账号以及项目方账号
// 2. 每次发行的数量正确, 且不会超过 totalSupply

contract InscriptionToken is ERC20 {
    uint256 public totalSupply_;
    uint256 public perMint_;
    uint256 public price_;
    uint256 public totalMinted_;
    string public name_ = "InscriptionToken";
    string public symbol_ = "IT";

    bool private initialized;

    address public creator_;
    address public factoryOwner_;

    constructor() ERC20(name_, symbol_) {}

    // 初始化 Token
    function initialize(uint256 _totalSupply, uint256 _perMint, uint256 _price, address _creator, address _factoryOwner)
        external
        returns (bool)
    {
        require(!initialized, "Already initialized");
        initialized = true;
        totalSupply_ = _totalSupply;
        perMint_ = _perMint;
        price_ = _price;
        creator_ = _creator;
        factoryOwner_ = _factoryOwner;
        return true;
    }

    function mint(address to_) external payable {
        // 检查铸造者的价格 & 是否铸造结束
        require(msg.value == price_, "Invalid price!!!");
        require(totalMinted_ + perMint_ <= totalSupply_, "Minted over!!!");

        // 费用分配: 90% 给发行者, 10% 给工厂合约的拥有者
        uint256 feeToCreator = (msg.value * 90) / 100;
        uint256 feeToFactoryOwner = (msg.value * 10) / 100;
        payable(creator_).transfer(feeToCreator); // 转给发行者 90%
        payable(factoryOwner_).transfer(feeToFactoryOwner); // 转给工厂合约的拥有者 10%

        // 铸造 Token
        _mint(to_, perMint_);
        totalMinted_ += perMint_;
    }
}
