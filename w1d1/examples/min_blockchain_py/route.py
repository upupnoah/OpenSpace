from flask import Flask, jsonify, request
from model import Blockchain
from uuid import uuid4

from flask import Flask, jsonify, request


# Instantiate the Node
app = Flask(__name__)

# Generate a globally unique address for this node
# 虽然理论上有重复的可能性，但是在实际应用中几乎可以忽略不计，因此通常认为 uuid4() 生成的 UUID 是全局唯一
# 用来标识一个节点(矿工)
node_identifier = str(uuid4()).replace('-', '')

blockchain = Blockchain()


@app.route('/chain', methods=['GET'])
def full_chain():
    response = {
        'chain': blockchain.chain,
        'length': len(blockchain.chain)
    }
    return jsonify(response), 200


@app.route('/transactions/new', methods=['POST'])
def new_transaction():
    values = request.get_json()

    required = ['sender', 'recipient', 'amount']
    if not all(k in values for k in required):
        return 'Missing values', 400

    # Create a new Transaction
    index = blockchain.new_transaction(
        values['sender'], values['recipient'], values['amount'])
    response = {
        'message': f'Transaction will be added to Block {index}'
    }
    return jsonify(response), 201


@app.route('/mine', methods=['GET'])
def mine():
    last_proof = blockchain.last_block['proof']
    proof = blockchain.proof_of_work(last_proof)

    # 给工作量证明的节点提供奖励
    # 发送者为"0"表明是新挖出的币
    blockchain.new_transaction(
        "0", node_identifier, 1
    )

    # Forge the new Block by adding it to the chain
    block = blockchain.new_block_and_append(proof, None)

    response = {
        'message': "New Block Forged",
        'index': block['index'],
        'transactions': block['transactions'],
        'proof': block['proof'],
        'previous_hash': block['previous_hash'],
    }
    return jsonify(response), 200


@app.route('/nodes/register', methods=['POST'])
def register_nodes():
    values = request.get_json()
    nodes = values.get('nodes')

    if nodes is None:
        return "Error: Please supply a valid list of nodes", 400

    for node in nodes:
        blockchain.register_node(node)

    response = {
        'message': 'New nodes have been added',
        'total_nodes': list(blockchain.nodes),
    }
    return jsonify(response), 201


@app.route('/nodes/resolve', methods=['GET'])
def consensus():
    replaced = blockchain.resolve_conflicts()

    if replaced:
        response = {
            'message': 'Our chain was replaced',
            'new_chain': blockchain.chain
        }
    else:
        response = {
            'message': 'Our chain is authoritative',
            'chain': blockchain.chain
        }

    return jsonify(response), 200
