from flask import Flask, request, jsonify
from flask_cors import CORS
import random
import string
import os

app = Flask(__name__)
CORS(app)

UPLOAD_FOLDER = 'uploaded_medical_records'
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)


users_db = []

def generate_captcha():
    characters = string.ascii_uppercase + string.digits
    captcha = ''.join(random.choice(characters) for _ in range(6))
    return captcha

@app.route('/register', methods=['POST'])
def register():
    data = request.json
    name = data.get('name')
    dob = data.get('dob')
    gender = data.get('gender')
    phone = data.get('phone')
    email = data.get('email')
    aadhar_number = data.get('aadhar_number')
    password = data.get('password')

    # Validation
    if len(phone) != 10 or not phone.isdigit():
        return jsonify({"error": "Invalid phone number"}), 400

    if not email or '@' not in email:
        return jsonify({"error": "Invalid email"}), 400

    if len(password) < 6:
        return jsonify({"error": "Password too short"}), 400

    if not name or not dob or not gender or not aadhar_number:
        return jsonify({"error": "All fields are required"}), 400

    # Check if user already exists
    if any(user['phone'] == phone for user in users_db):
        return jsonify({"error": "User already registered"}), 400

    # Process medical records if they exist
    medical_records = []
    if 'medicalRecords' in request.files:
        files = request.files.getlist('medicalRecords')
        for file in files:
            # Save each file to the server
            if file:
                filename = os.path.join(app.config['UPLOAD_FOLDER'], file.filename)
                file.save(filename)
                medical_records.append(filename)  # Store the file path in the DB

    # Create user
    user = {
        'name': name,
        'dob': dob,
        'gender': gender,
        'phone': phone,
        'email': email,
        'aadhar_number': aadhar_number,
        'password': password,
        'medical_records': medical_records  # Add medical records info
    }

    # Save user to "database"
    users_db.append(user)

    return jsonify({"message": "Registration successful"}), 201

@app.route('/login', methods=['POST'])
def login():
    data = request.json
    phone = data.get('phone')
    password = data.get('password')

    user = next((user for user in users_db if user['phone'] == phone), None)
    if user is None or user['password'] != password:
        return jsonify({"error": "Invalid phone number or password"}), 401

    return jsonify({"message": "Login successful", "user": user}), 200


@app.route('/captcha', methods=['GET'])
def captcha():
    captcha = generate_captcha()
    return jsonify({"captcha": captcha})

if __name__ == '__main__':
    app.run(debug=True)
