// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import "@openzeppelin/contracts/proxy/Proxy.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./InscriptionERC20.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "./InscriptionERC20.sol";

// 在以太坊上⽤ ERC20 模拟铭⽂铸造，编写一个可以通过最⼩代理来创建ERC20 的⼯⼚合约，⼯⼚合约包含两个方法：
// - deployInscription(string symbol, uint totalSupply, uint perMint, uint price), ⽤户调⽤该⽅法创建 ERC20 Token合约，
//symbol 表示新创建代币的代号（ ERC20 代币名字可以使用固定的），totalSupply 表示总发行量， perMint 表示单次的创建量， price 表示每个代币铸造时需要的费用（wei 计价）。每次铸造费用在扣除手续费后（手续费请自定义）由调用该方法的用户收取。
// - mintInscription(address tokenAddr) payable: 每次调用发行创建时确定的 perMint 数量的 token，并收取相应的费用。
contract InscriptionProxyFactory {
    address public implementation;

    // 收取固定的手续费: 收取 10%
    uint256 public constant FIX_FEE = 10;

    // 合约 owner
    address payable owner;

    mapping(address => Inscription) public inscriptions;

    constructor() {
        implementation = address(new InscriptionERC20());
        owner = payable(msg.sender);
    }

    struct Inscription {
        string symbol;
        uint256 totalSupply;
        uint256 perMint;
        uint256 price;
        address tokenAddr;
        // 部署者
        address deployer;
    }

    modifier totalSupplyMustGreaterThanZero(uint256 totalSupply) {
        require(totalSupply > 0, "totalSupply must greater than zero");
        _;
    }

    modifier perMintMustGreaterThanZero(uint256 perMint) {
        require(perMint > 0, "perMint must greater than zero");
        _;
    }

    modifier priceMustGreaterThanZero(uint256 price) {
        require(price > 0, "price must greater than zero");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "only owner can call");
        _;
    }

    function setImplementation(address _implementation) public onlyOwner {
        implementation = _implementation;
    }

    /// @notice  ⽤户调⽤该⽅法创建 ERC20 Token合约
    /// @param _symbol，新创建代币的代号
    /// @param _totalSupply 总发行量
    /// @param _perMint 单次的创建量
    /// @param _price 每个代币铸造时需要的费用（wei 计价）
    /// @return 部署的ERC20地址
    function deployInscription(string memory _symbol, uint256 _totalSupply, uint256 _perMint, uint256 _price)
        public
        totalSupplyMustGreaterThanZero(_totalSupply)
        perMintMustGreaterThanZero(_perMint)
        priceMustGreaterThanZero(_price)
        returns (address)
    {
        // 克隆 ERC20 Token合约
        address cloned = Clones.clone(implementation);
        InscriptionERC20(cloned).initialize(address(this), _symbol, _totalSupply, _perMint);
        Inscription memory inscription = Inscription(_symbol, _totalSupply, _perMint, _price, cloned, msg.sender);
        inscriptions[cloned] = inscription;
        return cloned;
    }

    /// @notice 每次调用发行创建时确定的 perMint 数量的 token，并收取相应的费用
    /// @param tokenAddr mint 的合约地址
    function mintInscription(address tokenAddr) public payable {
        Inscription memory inscription = inscriptions[tokenAddr];
        // 检查inscription是否存在
        require(inscription.deployer != address(0), "inscription not exist");
        uint256 totalCost = inscription.price * inscription.perMint;
        require(msg.value >= totalCost, "mint value not enough");

        // mint token
        InscriptionERC20(tokenAddr).mint(msg.sender);

        // 收取手续费
        // payable(owner).transfer(totalCost * FIX_FEE / 100);
        payable(owner).call{value: totalCost * FIX_FEE / 100}("");

        // 向合约部署者转账，收取 mint 费用
        payable(inscription.deployer).call{value: totalCost * (100 - FIX_FEE) / 100}("");
        // payable(inscription.deployer).transfer(totalCost * (100 - FIX_FEE) / 100);
    }

    // 以下为辅助函数
    function getInscription(address inscriptionAddress) public view returns (Inscription memory) {
        return inscriptions[inscriptionAddress];
    }
}
