import {
  NFTCreated as NFTCreatedEvent,
  // NFTRegesitered as NFTRegesiteredEvent,
  // OwnershipTransferred as OwnershipTransferredEvent
} from "../generated/Contract/Contract"
import {
  NFTCreated,
  TokenInfo
  // NFTRegesitered,
  // OwnershipTransferred
} from "../generated/schema"
import {S2NFT as S2NFTTemplate} from "../generated/templates"
import { Transfer as TransferEvent, S2NFT, Transfer } from "../generated/templates/S2NFT/S2NFT"
import { Address } from "@graphprotocol/graph-ts"

/**
 * 新增 NFTCreated
 * @param event 
 */
export function handleNFTCreated(event: NFTCreatedEvent): void {
  let entity = new NFTCreated(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.nftCA = event.params.nftCA


  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
  S2NFTTemplate.create(event.params.nftCA)
}

/**
 * 新增或修改 TokenInfo
 * @param event
 * @returns 
 */
export function handleTransfer(event: TransferEvent): void {
  let entity: TokenInfo | null;
  if (event.params.from.equals(Address.zero())) {
    entity = new TokenInfo(
      event.address.toHexString().concat(event.params.tokenId.toString())
    )
  } else {
    entity = TokenInfo.load(event.address.toHexString().concat(event.params.tokenId.toString()))
  }
  if (entity == null) {
    return;
  }
  entity.ca = event.address;
  entity.tokenId = event.params.tokenId;
  let s2Nft = S2NFT.bind(event.address);
  entity.tokenURL = s2Nft.tokenURI(event.params.tokenId);
  entity.name = s2Nft.name();
  entity.owner = event.params.to;
  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;
  entity.save()
}

// export function handleNFTRegesitered(event: NFTRegesiteredEvent): void {
//   let entity = new NFTRegesitered(
//     event.transaction.hash.concatI32(event.logIndex.toI32())
//   )
//   entity.nftCA = event.params.nftCA

//   entity.blockNumber = event.block.number
//   entity.blockTimestamp = event.block.timestamp
//   entity.transactionHash = event.transaction.hash

//   entity.save()
// }

// export function handleOwnershipTransferred(
//   event: OwnershipTransferredEvent
// ): void {
//   let entity = new OwnershipTransferred(
//     event.transaction.hash.concatI32(event.logIndex.toI32())
//   )
//   entity.previousOwner = event.params.previousOwner
//   entity.newOwner = event.params.newOwner

//   entity.blockNumber = event.block.number
//   entity.blockTimestamp = event.block.timestamp
//   entity.transactionHash = event.transaction.hash

//   entity.save()
// }

// export function handleTokenInfo(
//   event: TokenInfoEvent
// ): void {
// }