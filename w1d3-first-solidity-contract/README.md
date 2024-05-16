# Solidity

### 工具

- [Remix IDE](https://remix.ethereum.org/#lang=en&optimize=false&runs=200&evmVersion=null&version=soljson-v0.8.22+commit.4fc1097e.js)
- [WTF Solidity](https://www.wtf.academy/docs/solidity-101/ValueTypes/)
- [Decert.me](https://decert.me/tutorial/solidity/solidity-basic/solidity_layout/)

## 定义合约

```solidity
contract ContractName {
}
```

### 类型

- 布尔: `bool`

- 整形: `int, uint`

- 地址: `address`

- 定长字节数组: `bytes1 ~ bytes32`

  ```solidity
      // 固定长度的字节数组
      bytes32 public _byte32 = "MiniSolitidy";
      bytes1 public _byte = _byte32[0];
  ```

- 函数类型:    `function <function name>(<parameter types>) {internal|external|public|private} [pure|view|payable] [returns (<return types>)]`

  - 没有标明可见性类型的函数，默认为`public`

  - ```
    public|private|internal
    ```

     也可用于修饰状态变量。 

    ```
    public
    ```

    变量会自动生成同名的

    ```
    getter
    ```

    函数，用于查询数值

    - 访问级别

      ：

      `public`

       \> 

      `internal`

       \> 

      `private`

      - **`public`**是最开放的访问级别，任何外部调用者和继承的合约都可以访问。
      - **`internal`**提供了一定程度的封装，防止外部直接访问，但允许继承的合约访问。
      - **`private`**是最受限的，确保只有声明它们的合约内部可以访问，即使是子合约也无法访问。

  - 没有标明可见性类型的状态变量，默认为`internal`

  - 返回值

    - return: 用于函数主体中, 返回指定的返回值

    - returns: 跟在函数名之后,返回指定的变量以及返回值

      ```solidity
          // 返回多个变量
          function returnMultiple() public pure returns(uint256, bool, uint256[3] memory){
                  return(1, true, [uint256(1),2,5]);
          }
      ```

    - 类似于 Go 语言, 还可以命名式返回

      ```solidity
          // 命名式返回
          function returnNamed() public pure returns(uint256 _number, bool _bool, uint256[3] memory _array){
              _number = 2;
              _bool = false; 
              _array = [uint256(3),2,1];
          }
      ```

      - 即使是设置了命名式返回, 但是还是可以使用 return 关键字

- 枚举: `enum`

  ```solidity
      // 用 enum 将 uint 0,1,2 表示为 Buy，Hold，Sell
      enum ActionSet {
          Buy,
          Hold,
          Sell
      }
      ActionSet public action = ActionSet.Hold;
  ```

- 强制转换 `type(xxx)`

  ```solidity
      enum ActionSet {
          Buy,
          Hold,
          Sell
      }
      ActionSet action = ActionSet.Hold;
  
      // enum 可以和 uint 显示地转换
      function enumToUint() external view returns (uint) {
          return **uint(action)**;
      }
  ```

## 变量数据存储和作用域

### 引用类型

- `array, struct, mapping` 这些占空间大, 因此赋值的时候**传递的是地址**

### 变量作用域

- 状态变量

  状态变量是数据存储在链上的变量，所有合约内函数都可以访问 ，`gas`消耗高。状态变量在合约内、函数外声明

- 局部变量

  局部变量是仅在函数执行过程中有效的变量，函数退出后，变量无效。局部变量的数据存储在内存里，不上链，`gas`低

- 全局变量

  全局变量是全局范围工作的变量，都是`solidity`预留关键字 (不声明, 可直接使用)

  ```solidity
      function global() external view returns(address, uint, bytes memory){
          address sender = msg.sender;
          uint blockNum = block.number;
          bytes memory data = msg.data;
          return(sender, blockNum, data);
      }
  ```

  - 完整的全局变量表: https://learnblockchain.cn/docs/solidity/units-and-global-variables.html#special-variables-and-functions

### 数据位置

- `storage`: 状态变量一般默认都是 storage, 存储在链上

- `memory`: 函数里的参数以及临时变量, **不上链**

- `calldata`: 和 memory 一样, 唯一的区别是不能修改(immutable), 一般用于函数的参数, **不上链**

  ```solidity
      function fCalldata(uint[] calldata _x) public pure returns(uint[] calldata){
          //参数为calldata数组，不能被修改
          // _x[0] = 0 //这样修改会报错
          return(_x);
      }
  ```

### 赋值规则

1. `storage`（合约的状态变量）赋值给本地 `storage`（函数里的）时候，会创建引用，改变新变量会影响原变量

   ```solidity
       contract XXX {
         uint[] x = [1,2,3]; // 状态变量：数组 x
   
   	    function fStorage() public { 
   	      //声明一个storage的变量 xStorage，指向x。修改xStorage也会影响x
           uint[] storage xStorage = x;
           xStorage[0] = 100;
   	    }
       }
   ```

2. `storage`赋值给`memory`，会创建独立的副本，修改其中一个不会影响另一个；反之亦然

   ```solidity
       uint[] x = [1,2,3]; // 状态变量：数组 x
       
       function fMemory() public view{
           //声明一个Memory的变量xMemory，复制x。修改xMemory不会影响x
           uint[] memory xMemory = x;
           xMemory[0] = 100;
           xMemory[1] = 200;
           uint[] memory xMemory2 = x;
           xMemory2[0] = 300;
       }
   ```

3. `memory`赋值给`memory`，会创建引用，改变新变量会影响原变量

4. 其他情况，变量赋值给`storage`，会创建独立的副本，修改其中一个不会影响另一个