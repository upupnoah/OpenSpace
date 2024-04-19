# 目录说明
- src 中的代码为 min_blockchain 的 Rust 实现
- examples 中的代码为 pow&rsa 的 rust 实现 以及 min_block 的 python 实现
  - 使用 Makefile 执行测试

## min_blockchain
### 操作流程
1. 启动两个节点(10500, 105001 端口)
1. 分别 `POST /nodes/register`, body 为对应邻居们(节点) 的 `URL`, 例如: http://localhost:10500
2. 在 `10500` 这个端口的节点上挖两个新的块
   1. 先创建 `Transaction`
        ```shell
        ## POST transactions/new
        curl -X "POST" "http://localhost:10500/transactions/new" \
             -H 'Content-Type: application/json; charset=utf-8' \
             -d $'{
          "amount": "99",
          "recipient": "someone-other-address",
          "sender": "d4ee26eee15148ee92c6cd394edd974e"
        }'
        
        ```
   
   2. 挖矿 mine
   
      ```shell
      ## GET mine
      curl "http://localhost:10500/mine"
      ```
   
   3. 再创建 Transaction
   
      ```shell
      ## POST transactions/new
      curl -X "POST" "http://localhost:10500/transactions/new" \
           -H 'Content-Type: application/json; charset=utf-8' \
           -d $'{
        "amount": "100",
        "recipient": "someone-other-address",
        "sender": "d4ee26eee15148ee92c6cd394edd974e"
      }'
      
      ```
   
   4. 挖矿 mine
   
      ```shell
      ## GET mine
      curl "http://localhost:10500/mine"
      ```
   
   5. 在 10501 上解决冲突, chain 更新为最长的 10500 的 chain
   
      ```shell
      ## GET nodes/resolve
      curl "http://localhost:10501/nodes/resolve"