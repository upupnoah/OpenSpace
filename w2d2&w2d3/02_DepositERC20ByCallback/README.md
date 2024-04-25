# Deposit ERC20 By Callback

题目: 扩展 TokenBank, 在TokenBank 中利用上一题的转账回调实现存款

1. 为 TokenBank 专门设计的一个 ERC20 合约，用于存款，提款，查询余额等操作
   1. `transferWithCallback` in `Bank_ERC20Callback` contract
   2. `tokensReceived` in `TokenBank`
   
2. 我的思考
   1. 相当于用户存钱的时候直接记账了, 用户交互的合约是 Bank_ERC20
      1. 优点: 用户不需要关心存款的逻辑, 只需要调用 transferWithCallback (一次操作)。 原本需要先 approve, 然后再调用 transfer (两次操作)
      2. 缺点: 代码逻辑变长了 (但用户原本也是通过先向 ERC20 合约 approve Bank 签署金额, 现在直接通过 ERC20 合约转钱过去, ERC20 合约自动在 Bank 中记账)
   2. 取款逻辑不变, 是因为合约可以直接 transfer 钱给用户
   3. 对回调函数(callback)的思考
      1. 执行完想要的逻辑之后, 再调用的逻辑
   4. 深刻理解什么是 Callback
   5. 在用户层面, 如果一个函数的名字为 transfer, 那么最好不要干其他的事情, 可以暴露一个额外的函数, 专门用于(转账+存款(回调))