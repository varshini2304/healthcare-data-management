from flask import Flask, request, jsonify
from flask_cors import CORS
from web3 import Web3

# Flask app setup
app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

# Connect to Ganache
ganache_url = "http://127.0.0.1:8545"   # Ganache RPC server
web3 = Web3(Web3.HTTPProvider(ganache_url))

# Check connection
try:
    web3.eth.blockNumber  # This will raise an error if not connected
    print("Connected to Ganache")
except Exception as e:
    print("Failed to connect to Ganache:", str(e))

# Contract details
contract_address = "0xea5247a7F18f58CDa1bEA645E98E9Dceb3BeE676"  # Replace with your contract address
contract_abi = [
    {
        "inputs": [
            {"internalType": "address", "name": "_owner", "type": "address"}
        ],
        "stateMutability": "nonpayable",
        "type": "constructor"
    },
    {
        "inputs": [
            {"internalType": "address", "name": "_ownerAddress", "type": "address"},
            {"internalType": "uint256[]", "name": "_products", "type": "uint256[]"}
        ],
        "name": "addProducts",
        "outputs": [
            {"internalType": "string", "name": "", "type": "string"}
        ],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            {"internalType": "uint256", "name": "_hashcode", "type": "uint256"}
        ],
        "name": "verifyProduct",
        "outputs": [
            {"internalType": "string", "name": "", "type": "string"}
        ],
        "stateMutability": "view",
        "type": "function",
        "constant": True
    }
]

# Contract instance
contract = web3.eth.contract(address=contract_address, abi=contract_abi)

# Default account (use the first Ganache account)
default_account = web3.eth.accounts[0]  # Make sure this is the right account

@app.route('/add_product', methods=['POST'])
def add_product():
    print(request.method)  # Log the method
    data = request.json
    product_id = data.get('product_id')
    product_name = data.get('product_name')
    owner_id = data.get('owner_id')
    try:
        # Ensure that product_id is a valid integer (uint256)
        tx_hash = contract.functions.addProducts(
            Web3.toChecksumAddress(owner_id),  # Ensure owner_id is a valid Ethereum address
            [int(product_id)]  # Convert product_id to uint256
        ).transact({'from': default_account})
        web3.eth.wait_for_transaction_receipt(tx_hash)
        return jsonify({'message': 'Product added successfully!'}), 201
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/check_product', methods=['GET'])
def check_product():
    product_id = request.args.get('product_id')
    try:
        # Verifying the product ID using the contract's verifyProduct method
        result = contract.functions.verifyProduct(int(product_id)).call()
        return jsonify({'result': result}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500


# Route: Retrieve All Products
@app.route('/retrieve_products', methods=['GET'])
def retrieve_products():
    try:
        # Retrieving all products (assuming getAllProducts exists in the contract)
        products = contract.functions.getAllProducts().call()
        return jsonify({'products': products}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)

print(app.url_map)
