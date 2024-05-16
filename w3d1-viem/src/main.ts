import { createPublicClient, parseAbiItem, webSocket } from 'viem';
import { mainnet } from 'viem/chains';
import dotenv from 'dotenv';

dotenv.config(); // 加载环境变量
// 初始化客户端
const client = createPublicClient({
    chain: mainnet,
    transport: webSocket(process.env.ETHE_RPC_URL),
});

async function main() {
    // 获取当前区块号
    try {
        const currentBlockNumber = await client.getBlockNumber();

        // 配置事件过滤器参数
        const filterParams = {
            address: '0xA0b86991c6218b36c1d19D4a2e9Eb0CE3606eb48' as `0x${string}`, // USDC合约地址
            event: parseAbiItem('event Transfer(address indexed from, address indexed to, uint256 value)'),
            fromBlock: currentBlockNumber - BigInt(100), // 向前100个区块
            toBlock: currentBlockNumber as bigint
        };

        // 创建事件过滤器
        const filter = await client.createEventFilter(filterParams);

        // 检索事件日志
        const logs = await client.getFilterLogs({ filter });

        // 解析并显示相关的转账记录
        logs.forEach(log => {
            // if (log.args.from === '0x099bc3af8a85015d1A39d80c42d10c023F5162F0' && log.args.to === '0xA4D65Fd5017bB20904603f0a174BBBD04F81757c') {
            const from = log.args.from;
            const to = log.args.to;
            const value = Number(log.args.value) / 1e6; // 调整USDC的小数位
            const transactionId = log.transactionHash;

            console.log(`从 ${from} 转账给 ${to} ${value} USDC ,交易ID：${transactionId}`);
            // }
        });
    } catch (error) {
        console.error('An error occurred:', error);
    }
}

main().catch(console.error);
