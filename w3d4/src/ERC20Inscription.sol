// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

// import {IERC20} from "@openzeppelin/contracts/token/erc20/IERC20.sol";
// import {IERC20Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";
// import {Context} from "@openzeppelin/contracts/utils/Context.sol";
// import {IERC20Metadata} from "@openzeppelin/contracts/token/erc20/extensions/IERC20Metadata.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {ERC20} from "@openzeppelin/contracts/token/erc20/ERC20.sol";

// 心路历程: 我是一个 ERC20Inscription, 是一个 ERC20铭文合约, 因此我的 mint 中包含一些其他逻辑也是 ok 的
// 多一些和铭文相关的状态变量也是 ok 的

contract ERC20Inscription is Initializable, ERC20 {
    mapping(address account => uint256) private _balances;

    mapping(address account => mapping(address spender => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    uint256 private perMint;
    uint256 private totalSupplyLimit;

    constructor() ERC20("NoahInscription", "NoahINSC") {
        // do nothing
    }

    function initialize(string calldata name_, string calldata symbol_, uint256 totalSupply_, uint256 perMint_)
        public
        initializer
    {
        _name = name_;
        _symbol = symbol_;
        _totalSupply = totalSupply_;
        _balances[msg.sender] = totalSupply_; // msg.sender is the deployer

        perMint = perMint_;
        totalSupplyLimit = totalSupply_;
    }

    function mint(address to) public {
        // 检查供应量是否超过上限
        require(totalSupply() + perMint <= totalSupplyLimit, "totalSupply exceed limit");
        _mint(to, perMint);
    }
}
