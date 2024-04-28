// export default function ConnectButton() {
//   return (
//     <div>
//       <button>Connect wallet</button>
//     </div>
//   );
// }

"use client";

import { useAccount } from "wagmi";
import { Account } from "./account";
import { WalletOptions } from "./wallet-options";

export default function ConnectButton() {
  const { isConnected } = useAccount();
  if (isConnected) return <Account />;
  return <WalletOptions />;
}