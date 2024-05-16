import { parseAbiItem } from 'viem'
import { publicClient } from './client'
// import { wagmiAbi } from './abi'
 
async function onTransfer(logs: any) {
  logs.forEach((log: any) => {
    // if (log.args.from === '0x099bc3af8a85015d1A39d80c42d10c023F5162F0' && log.args.to === '0xA4D65Fd5017bB20904603f0a174BBBD04F81757c') {
    const from = log.args.from;
    const to = log.args.to;
    const value = Number(log.args.value) / 1e6; // 调整USDC的小数位
    const transactionId = log.transactionHash;

    console.log(`从 ${from} 转账给 ${to} ${value} USDC ,交易ID：${transactionId}`);
    // }
});
}

async function watchTransferEvents() {
  const unwatch = publicClient.watchEvent({
    address: "0xdAC17F958D2ee523a2206206994597C13D831ec7",
    event: parseAbiItem(
      "event transfer(address indexed from, address indexed to, uint256 value)"
    ),
    onLogs: onTransfer,
  })
}  