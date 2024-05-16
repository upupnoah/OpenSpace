// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {ERC20Inscription} from "./ERC20Inscription.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";

contract ERC20InscriptionFactory {
    using Clones for address;
    using Address for address payable;

    uint256 public fee;
    address owner;

    struct Inscription {
        string name;
        string symbol;
        uint256 totalSupply;
        uint256 perMint;
        uint256 price;
        address tokenAddr;
        // 部署者
        address deployer;
    }

    address implementation;
    mapping(address => Inscription) public inscriptions; // erc20 address => Inscription

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

    constructor(uint8 _fee) {
        require(_fee <= 100, "ERC20InscriptionFactory: fee must be less than or equal to 100");
        implementation = address(new ERC20Inscription());
        owner = msg.sender;
        fee = _fee;
    }

    function setImplementation(address _implementation) public onlyOwner {
        implementation = _implementation;
    }

    /**
     *   ⽤户调⽤该⽅法创建 ERC20 Token合约，symbol 表示新创建代币的代号 (ERC20 代币名字可以使用固定的)，
     *   totalSupply 表示总发行量，perMint 表示单次的创建量，price 表示每次铭文铸造时需要的费用（wei 计价）。
     *   每次铸造费用在扣除手续费后（手续费请自定义）由调用该方法的用户收取。
     */
    function deployInscription(
        string calldata name,
        string calldata symbol,
        uint256 totalSupply,
        uint256 perMint,
        uint256 price
    )
        public
        totalSupplyMustGreaterThanZero(totalSupply)
        perMintMustGreaterThanZero(perMint)
        priceMustGreaterThanZero(price)
        returns (address)
    {
        address cloned = implementation.clone();
        ERC20Inscription(cloned).initialize(name, symbol, totalSupply, perMint);
        Inscription memory inscription = Inscription(name, symbol, totalSupply, perMint, price, cloned, msg.sender);
        inscriptions[cloned] = inscription;
        return cloned;
    }

    /**
     * 每次调用创建时确定的 perMint 数量的 token，并收取相应的费用。
     */
    function mintInscription(address tokenAddr) public payable {
        Inscription memory inscription = inscriptions[tokenAddr];
        require(inscription.tokenAddr != address(0), "ERC20InscriptionFactory: token not found");
        require(msg.value == inscription.price, "ERC20InscriptionFactory: invalid price");

        // mint token
        ERC20Inscription(tokenAddr).mint(msg.sender);

        // 收取手续费
        // (bool success,) = payable(owner).call{value: (msg.value * fee) / 100}("");
        // require(success, "ERC20InscriptionFactory: fee transfer failed");
        // Address.sendValue(payable(owner), (msg.value * fee) / 100);
        payable(owner).sendValue((msg.value * fee) / 100);

        // 收取 mint 费用
        // (success,) = payable(inscription.deployer).call{value: msg.value * (100 - fee) / 100}("");
        // require(success, "ERC20InscriptionFactory: mint value transfer failed");
        // Address.sendValue(payable(inscription.deployer), msg.value * (100 - fee) / 100);
        payable(inscription.deployer).sendValue(msg.value * (100 - fee) / 100);
    }

    /// @notice 获取铭文信息
    /// @param erc20InscriptionAddr 铭文合约地址
    function getInscription(address erc20InscriptionAddr) public view returns (Inscription memory) {
        return inscriptions[erc20InscriptionAddr];
    }
}
