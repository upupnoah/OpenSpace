import { createPublicClient, http, webSocket } from 'viem'
import { mainnet } from 'viem/chains'
import dotenv from 'dotenv';

dotenv.config(); // 这会加载同目录下的 .env 文件中的环境变量

export const publicClient = createPublicClient({
    chain: mainnet,
    transport: webSocket(process.env.ETHE_RPC_URL),
})
