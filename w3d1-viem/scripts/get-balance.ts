import { createPublicClient, http, webSocket } from 'viem'
import { mainnet } from 'viem/chains'
import dotenv from 'dotenv';

dotenv.config(); // 这会加载同目录下的 .env 文件中的环境变量

const client = createPublicClient({
    chain: mainnet,
    transport: webSocket(process.env.ETHE_RPC_URL),
})

async function main() {

    const amount = await client.getBalance({
        address: "0x0000000000007f150bd6f54c40a34d7c3d5e9f56",
    })
    console.log(amount);
}

main().catch((err) => console.log(err));