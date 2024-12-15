from flask import Flask, request, jsonify

app = Flask(__name__)

# Mock Blockchain Functionality (Replace with actual blockchain interaction)
blockchain_data = {
    "users": {},
    "products": {}
}

# Endpoint to get user details
@app.route('/get_user', methods=['GET'])
def get_user():
    user_id = request.args.get('user_id')
    user = blockchain_data['users'].get(user_id)
    if user:
        return jsonify({"status": "success", "data": user}), 200
    return jsonify({"status": "error", "message": "User not found"}), 404

# Endpoint to create a user
@app.route('/create_user', methods=['POST'])
def create_user():
    data = request.json
    user_id = data.get('user_id')
    user_name = data.get('user_name')
    if user_id in blockchain_data['users']:
        return jsonify({"status": "error", "message": "User already exists"}), 400
    blockchain_data['users'][user_id] = {"name": user_name}
    return jsonify({"status": "success", "message": "User created"}), 201

# Endpoint to add a product
@app.route('/add_product', methods=['POST'])
def add_product():
    data = request.json
    product_id = data.get('product_id')
    product_name = data.get('product_name')
    owner_id = data.get('owner_id')
    if product_id in blockchain_data['products']:
        return jsonify({"status": "error", "message": "Product already exists"}), 400
    if owner_id not in blockchain_data['users']:
        return jsonify({"status": "error", "message": "Owner not found"}), 404
    blockchain_data['products'][product_id] = {"name": product_name, "owner": owner_id}
    return jsonify({"status": "success", "message": "Product added"}), 201

# Endpoint to check product details
@app.route('/check_product', methods=['GET'])
def check_product():
    product_id = request.args.get('product_id')
    product = blockchain_data['products'].get(product_id)
    if product:
        return jsonify({"status": "success", "data": product}), 200
    return jsonify({"status": "error", "message": "Product not found"}), 404

if __name__ == '__main__':
    app.run(debug=True)
