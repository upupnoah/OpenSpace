import hashlib
import json
from time import time
from typing import Any, Dict, List, Optional
from urllib.parse import urlparse

import requests


class Blockchain(object):
    def __init__(self):
        self.chain = []  # 区块链
        self.current_transactions = []  # 交易池
        self.nodes = set()  # 节点

        # 创建创世块
        self.new_block_and_append(previous_hash='1', proof=100)

    def new_block_and_append(self, proof: int, previous_hash: Optional[str]) -> Dict[str, Any]:
        block = {
            'index': len(self.chain) + 1,
            'timestamp': time(),
            'transactions': self.current_transactions,
            'proof': proof,  # difficulty(难度系数)
            'previous_hash': previous_hash or self.hash(self.chain[-1]),
        }

        # Reset the current list of transactions
        self.current_transactions = []

        self.chain.append(block)
        return block

    def new_transaction(self, sender: str, recipient: str, amount: int) -> int:
        """
        生成新交易信息，信息将加入到下一个待挖的区块中
        """
        self.current_transactions.append({
            'sender': sender,
            'recipient': recipient,
            'amount': amount,
        })
        return self.last_block['index'] + 1

    @property
    def last_block(self) -> Dict[str, Any]:
        return self.chain[-1]

    @staticmethod
    def hash(block: Dict[str, Any]) -> str:
        """
        生成块的 SHA-256 hash值
        """
        block_string = json.dumps(block, sort_keys=True).encode()
        return hashlib.sha256(block_string).hexdigest()  # 返回 16 进制字符串

    def proof_of_work(self, last_proof: int) -> int:
        """
        简单的工作量证明:
        - 查找一个 p' 使得 hash(pp') 以 4 个零开头
        - p 是上一个块的证明, p' 是当前的证明
        """
        proof = 0  # 从0开始尝试
        while self.valid_proof(last_proof, proof) is False:
            proof += 1
        return proof

    @staticmethod
    def valid_proof(last_proof: int, proof: int) -> bool:
        """
        验证证明: 是否hash(last_proof, proof)以4个0开头

        :param last_proof: Previous Proof.
        :param proof: Current Proof.
        :return: True if correct, False if not.
        """
        guess = f'{last_proof}{proof}'.encode()
        guess_hash = hashlib.sha256(guess).hexdigest()
        return guess_hash[:4] == "0000"

    def register_node(self, address: str):
        """
        Add a new node to the list of nodes
        """
        parsed_url = urlparse(address)
        self.nodes.add(parsed_url.netloc)  # netloc = hostname:port

    def valid_chain(self, chain: List[Dict[str, Any]]) -> bool:
        """
        Determine if a given blockchain is valid
        """
        last_block = chain[0]  # 创世块
        current_index = 1
        while current_index < len(chain):
            block = chain[current_index]
            print(f'{last_block}')
            print(f'{block}')
            print("\n-----------\n")
            # Check that the hash of the block is correct
            if block['previous_hash'] != self.hash(last_block):
                return False
            # Check that the Proof of Work is correct
            if not self.valid_proof(last_block['proof'], block['proof']):
                return False
            # update last_block and current_index
            last_block = block
            current_index += 1

        return True

    def resolve_conflicts(self) -> bool:
        """
        共识算法解决冲突
        使用网络中最长的链.

        : return: 如果链被取代返回 True, 否则 False
        """
        neighbours = self.nodes
        print(neighbours)
        new_chain = None

        # Grab and verify the chains from all the nodes in our network
        max_length = len(self.chain)
        for node in neighbours:
            response = requests.get(f'http://{node}/chain')
            if response.status_code == 200:
                length = response.json()['length']
                chain = response.json()['chain']

                # Check if the length is longer and the chain is valid
                if length > max_length and self.valid_chain(chain):
                    max_length = length
                    new_chain = chain
        if new_chain:
            self.chain = new_chain
            return True

        return False
