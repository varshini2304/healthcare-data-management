import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';// For rootBundle
import 'package:http/http.dart' as http;
import 'api_service.dart'; // Import the ApiService
import 'dart:math';
import 'package:firebase_core/firebase_core.dart';
import 'dart:io';// Ensure this matches the actual file name
import 'dart:convert';
import 'package:web3dart/web3dart.dart';
const Color appBarButtonColor = Color(0xFF26A69A);

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: DashboardScreen(), // Remove 'const' here
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: appBarButtonColor,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Sign Up Button with Dual Color Gradient
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignUpScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.tealAccent, Colors.teal],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Login Button with Dual Color Gradient
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.tealAccent, Colors.teal],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class Log {
  final String phoneNumber;
  final String emailId;
  final String password;

  Log({
    required this.phoneNumber,
    required this.emailId,
    required this.password,
  });
}
List<Log> logs = [];
class User {
  final String userId;
  final String userName;
  final String dob;
  final String gender;
  final String phone;
  final String email;
  final String aadharNumber;
  final List<File> medicalRecords;

  User({
    required this.userId,
    required this.userName,
    required this.dob,
    required this.gender,
    required this.phone,
    required this.email,
    required this.aadharNumber,
    required this.medicalRecords,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      userId: map['user_id'],
      userName: map['user_name'],
      dob: map['dob'],
      gender: map['gender'],
      phone: map['phone'],
      email: map['email'],
      aadharNumber: map['aadhar_number'],
      medicalRecords: map['medical_records'] != null
          ? (map['medical_records'] as List).map((e) => File(e.toString())).toList()
          : [], // Convert to List<File> or default to an empty list
    );
  }
}

List<User> users = [];

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  SignUpScreenState createState() => SignUpScreenState();
}
class SignUpScreenState extends State<SignUpScreen> {
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _captchaController = TextEditingController();

  String _captcha = '';

  @override
  void initState() {
    super.initState();
    _generateCaptcha();
  }

  void _generateCaptcha() {
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    setState(() {
      _captcha = List.generate(6, (index) => characters[random.nextInt(characters.length)]).join();
    });
  }

  void _showAlert(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    final phoneRegex = RegExp(r'^\d{10}$');
    return phoneRegex.hasMatch(phone);
  }

  void _signUp() {
    final phoneNumber = _phoneController.text;
    final emailId = _emailController.text;
    final password = _passwordController.text;

    if (!_isValidPhone(phoneNumber)) {
      _showAlert("Invalid phone number. It must be 10 digits.");
      return;
    }

    if (!_isValidEmail(emailId)) {
      _showAlert("Invalid email format.");
      return;
    }

    if (password.length < 6) {
      _showAlert("Password should be at least 6 characters long.");
      return;
    }

    if (logs.any((log) => log.phoneNumber == phoneNumber)) {
      _showAlert("This phone number is already registered.");
      return;
    }

    Log customer = Log(
      phoneNumber: phoneNumber,
      emailId: emailId,
      password: password,
    );

    logs.add(customer);
    _showAlert("Account created successfully!");
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        backgroundColor: appBarButtonColor,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.white],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildTextField('Phone Number', _phoneController, keyboardType: TextInputType.phone),
            const SizedBox(height: 15),
            _buildTextField('Email', _emailController, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 15),
            _buildTextField('Password', _passwordController, obscureText: true),
            const SizedBox(height: 20),
            Row(
              children: [
                Text('Captcha: $_captcha', style: const TextStyle(color: Colors.black, fontSize: 20)),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.black),
                  onPressed: _generateCaptcha,
                ),
              ],
            ),
            _buildTextField('Enter Captcha', _captchaController ,),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signUp,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.tealAccent, Colors.teal],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Container(
                  alignment: Alignment.center,
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text, bool obscureText = false}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.black, fontSize: 18),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.black.withOpacity(0.9), fontSize: 20),
        filled: true,
        fillColor: Colors.white10,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.black.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.teal, width: 1.5),
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  LoginScreenState createState() => LoginScreenState();
}
class LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() {
    final phone = _phoneController.text;
    final password = _passwordController.text;

    // Find user by phone number, return a dummy Log if not found
    Log log = logs.firstWhere(
          (log) => log.phoneNumber == phone,
      orElse: () => Log(phoneNumber: '', emailId: '', password: ''), // Dummy user
    );

    // Check if user exists and password matches
    if (log.phoneNumber.isNotEmpty && log.password == password) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login successful!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid phone number or password.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Colors.teal.shade700,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.white],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildTextField('Phone Number', _phoneController, keyboardType: TextInputType.phone),
            const SizedBox(height: 20),
            _buildTextField('Password', _passwordController, obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: Colors.white,
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.tealAccent, Colors.teal],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Container(
                  alignment: Alignment.center,
                  child: const Text(
                    'Login',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text, bool obscureText = false}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.black, fontSize: 18),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.black.withOpacity(0.9), fontSize: 20),
        filled: true,
        fillColor: Colors.white10,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.black.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.teal, width: 1.5),
        ),
      ),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get screen width to dynamically set the number of columns
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = (screenWidth ~/ 150).clamp(2, 4); // Adjust number of columns based on screen width

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Main Screen',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal.shade700,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              // Check if the users list is not empty
              if (users.isNotEmpty) {
                // Navigate to the profile screen and pass the last user as an example
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(user: users.last),
                  ),
                );
              } else {
                // Optionally, handle the case where there are no users
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("No user data available."),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.white],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: GridView.count(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 20, // Set vertical spacing between buttons
          crossAxisSpacing: 20, // Set horizontal spacing between buttons
          padding: const EdgeInsets.all(20), // Padding around the grid
          children: [
            MainScreenButton(
              icon: Icons.create,
              label: 'Create User',
              gradientColors: [Colors.tealAccent, Colors.teal],
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateUser()),
                );
              },
            ),
            MainScreenButton(
              icon: Icons.search,
              label: 'Get User',
              gradientColors: [Colors.tealAccent, Colors.teal],
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MessageScreen(message: 'Hi, welcome to Get User!'),
                  ),
                );
              },
            ),
            MainScreenButton(
              icon: Icons.add,
              label: 'Add Product',
              gradientColors: [Colors.tealAccent, Colors.teal],
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddProductScreen()),
                );
              },
            ),
            MainScreenButton(
              icon: Icons.verified_rounded,
              label: 'Verify Product',
              gradientColors: [Colors.tealAccent, Colors.teal],
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const VerifyProductScreen()),
                );
              },
            ),
            MainScreenButton(
              icon: Icons.file_upload_outlined,
              label: 'Retrieve Product',
              gradientColors: [Colors.tealAccent, Colors.teal],
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MessageScreen(message: 'Hi, welcome to Retrieve Product!'),
                  ),
                );
              },
            ),
            MainScreenButton(
              icon: Icons.support_agent,
              label: 'Online Assistance',
              gradientColors: [Colors.tealAccent, Colors.teal],
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MessageScreen(message: 'Hi, welcome to Online Assistance!'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
class MainScreenButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final List<Color> gradientColors;

  const MainScreenButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(30), // Set the border radius here
      splashColor: Colors.white.withOpacity(0.2), // Splash effect color
      highlightColor: Colors.white.withOpacity(0.1), // Highlight effect color
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30), // Adjust border radius here
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              offset: const Offset(0, 4),
              blurRadius: 8,
            ),
          ],
        ),
        padding: const EdgeInsets.all(16), // Add padding inside the button
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 40),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MessageScreen extends StatelessWidget {
  final String message;

  const MessageScreen({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Message'),
        backgroundColor: Colors.black.withOpacity(0.7),
      ),
      body: Center(
        child: Text(
          message,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class CreateUser extends StatefulWidget {
  final User? existingUser;

  CreateUser({Key? key, this.existingUser}) : super(key: key);

  @override
  CreateUserState createState() => CreateUserState();
}
class CreateUserState extends State<CreateUser> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _aadharController = TextEditingController();

  String? _selectedDOB;
  String? _selectedGender;
  List<File> _medicalRecords = [];

  final String apiBaseUrl = 'http://127.0.0.1:5000'; // Replace with production URL

  @override
  void initState() {
    super.initState();
    if (widget.existingUser != null) {
      _nameController.text = widget.existingUser!.userName;
      _phoneController.text = widget.existingUser!.phone;
      _emailController.text = widget.existingUser!.email;
      _aadharController.text = widget.existingUser!.aadharNumber;
      _selectedDOB = widget.existingUser!.dob;
      _selectedGender = widget.existingUser!.gender;
      _medicalRecords = widget.existingUser!.medicalRecords;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _aadharController.dispose();
    super.dispose();
  }

  Future<void> _pickDocuments() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      setState(() {
        _medicalRecords.addAll(
          result.paths.whereType<String>().map((path) => File(path)),
        );
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDOB = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      });
    }
  }

  bool _validateInputs() {
    if (_nameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _aadharController.text.isEmpty ||
        _selectedDOB == null ||
        _selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required.')),
      );
      return false;
    }

    if (!RegExp(r'^\d{10}\$').hasMatch(_phoneController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid phone number.')),
      );
      return false;
    }

    if (!RegExp(r'^\w+@[a-zA-Z_]+?\.[a-zA-Z]{2,3}\$').hasMatch(_emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid email address.')),
      );
      return false;
    }

    return true;
  }

  Future<void> _createUser() async {
    if (!_validateInputs()) return;

    Map<String, dynamic> userData = {
      "user_id": "USER-${Random().nextInt(999999)}",
      "user_name": _nameController.text,
      "dob": _selectedDOB,
      "gender": _selectedGender,
      "phone": _phoneController.text,
      "email": _emailController.text,
      "aadhar_number": _aadharController.text,
    };

    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/create_user'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(userData),
      );

      if (response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(jsonResponse['message'] ?? 'User created successfully!')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileScreen(user: User.fromMap(userData)),
          ),
        );
      } else {
        final jsonResponse = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(jsonResponse['message'] ?? 'Error occurred.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to connect to server.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create User'),
        backgroundColor: Colors.teal.shade700,
      ),
      body: Container(
        padding: const EdgeInsets.all(30.0),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.white],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 22),
              _buildTextField('Name', _nameController),
              const SizedBox(height: 22),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: _buildDateSelector(),
              ),
              const SizedBox(height: 22),
              _buildGenderSelector(),
              const SizedBox(height: 22),
              _buildTextField('Phone Number', _phoneController, keyboardType: TextInputType.phone),
              const SizedBox(height: 22),
              _buildTextField('Email', _emailController, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 22),
              _buildTextField('Aadhaar Number', _aadharController, keyboardType: TextInputType.number),
              const SizedBox(height: 22),
              ElevatedButton(
                onPressed: _pickDocuments,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal, // Set the background color for the button
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Upload Medical Records',
                  style: TextStyle(fontSize: 16, color: Colors.white), // Set the text color
                ),
              ),

              const SizedBox(height: 22),
              Text('Uploaded: ${_medicalRecords.length} file(s)',
                  style: const TextStyle(fontSize: 16, color: Colors.black)),
              const SizedBox(height: 26),
          ElevatedButton(
            onPressed: _createUser,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal, // Set the background color for the button
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'Create User',
              style: TextStyle(fontSize: 16, color: Colors.white), // Set the text color
            ),
          ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black),
        filled: true,
        fillColor: Colors.white10,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _selectedDOB ?? 'Select Date of Birth',
            style: TextStyle(
              color: _selectedDOB == null ? Colors.black.withOpacity(0.7) : Colors.black,
            ),
          ),
          const Icon(Icons.calendar_today, color: Colors.black),
        ],
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Gender', style: TextStyle(color: Colors.black)),
        Row(
          children: [
            Radio<String>(
              value: 'Male',
              groupValue: _selectedGender,
              onChanged: (value) {
                setState(() {
                  _selectedGender = value;
                });
              },
            ),
            const Text('Male', style: TextStyle(color: Colors.black)),
            Radio<String>(
              value: 'Female',
              groupValue: _selectedGender,
              onChanged: (value) {
                setState(() {
                  _selectedGender = value;
                });
              },
            ),
            const Text('Female', style: TextStyle(color: Colors.black)),
          ],
        ),
      ],
    );
  }
}

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({Key? key}) : super(key: key);

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}
class _AddProductScreenState extends State<AddProductScreen> {
  final _companyAddressController = TextEditingController();
  final _productIdController = TextEditingController();
  final _manufacturerIdController = TextEditingController();
  final _productNameController = TextEditingController();
  final _productBrandController = TextEditingController();

  late Web3Client _web3Client;
  late EthereumAddress _contractAddress;
  late EthPrivateKey _credentials;
  late DeployedContract _contract;

  final String _rpcUrl = 'http://127.0.0.1:8545'; // Ganache
  final String _privateKey = '0x45f789ac8c034c5b153440849129c4f8f8ba6f04756e6d3611a0d645e25bb648'; // Your private key (replace it)
  final String _contractAddressStr = '0xea5247a7F18f58CDa1bEA645E98E9Dceb3BeE676'; // Your contract address

  late ApiService _apiService;

  @override
  void initState() {
    super.initState();
    _initWeb3();
    _apiService = ApiService(); // Initialize the API service
  }

  // Initialize Web3

  // Initialize Web3 and the smart contract
  Future<void> _initWeb3() async {
    _web3Client = Web3Client(_rpcUrl, http.Client());

    _contractAddress = EthereumAddress.fromHex(_contractAddressStr);
    _credentials = await _web3Client.credentialsFromPrivateKey(_privateKey);

    final abiString = await rootBundle.loadString('assets/abi.json'); // Load ABI from file or hardcode it
    _contract = DeployedContract(
      ContractAbi.fromJson(abiString, 'Company'),
      _contractAddress,
    );
  }



  Future<void> _submitProduct() async {
    final companyAddress = _companyAddressController.text;
    final productId = _productIdController.text;
    final manufacturerId = _manufacturerIdController.text;
    final productName = _productNameController.text;
    final productBrand = _productBrandController.text;

    if (companyAddress.isEmpty ||
        productId.isEmpty ||
        manufacturerId.isEmpty ||
        productName.isEmpty ||
        productBrand.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required.')),
      );
      return;
    }

    try {
      // Call the API to add the product
      final response = await _apiService.addProduct(
        productId,       // Product ID
        productName,     // Product Name
        manufacturerId,  // Owner's Ethereum address
      );


      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Product added successfully! Transaction Hash: $response',
          ),
        ),
      );

      // Clear the text fields after successful submission
      _companyAddressController.clear();
      _productIdController.clear();
      _manufacturerIdController.clear();
      _productNameController.clear();
      _productBrandController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add product: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
        backgroundColor: Colors.teal,
      ),
      body: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.white],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField('Company Address', _companyAddressController),
              const SizedBox(height: 15),
              _buildTextField('Product ID', _productIdController),
              const SizedBox(height: 15),
              _buildTextField('Manufacturer ID', _manufacturerIdController),
              const SizedBox(height: 15),
              _buildTextField('Product Name', _productNameController),
              const SizedBox(height: 15),
              _buildTextField('Product Brand', _productBrandController),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: _submitProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Submit',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black),
        filled: true,
        fillColor: Colors.white10,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

class VerifyProductScreen extends StatefulWidget {
  const VerifyProductScreen({Key? key}) : super(key: key);

  @override
  _VerifyProductScreenState createState() => _VerifyProductScreenState();
}
class _VerifyProductScreenState extends State<VerifyProductScreen> {
  final _companyAddressController = TextEditingController();
  final _productIdController = TextEditingController();

  late Web3Client _web3Client;
  late EthereumAddress _contractAddress;
  late Credentials _credentials;
  late DeployedContract _contract;

  final String _rpcUrl = 'http://127.0.0.1:8545'; // Ganache or Infura URL
  final String _privateKey = '0x45f789ac8c034c5b153440849129c4f8f8ba6f04756e6d3611a0d645e25bb648'; // Replace with your private key
  final String _contractAddressStr = '0xea5247a7F18f58CDa1bEA645E98E9Dceb3BeE676'; // Replace with your contract address

  String _verificationResult = '';

  @override
  void initState() {
    super.initState();
    _initWeb3();
  }

  Future<void> _initWeb3() async {
    _web3Client = Web3Client(_rpcUrl, http.Client());

    _contractAddress = EthereumAddress.fromHex(_contractAddressStr);
    _credentials = await _web3Client.credentialsFromPrivateKey(_privateKey);

    final abiString = await rootBundle.loadString('assets/abi.json'); // Load ABI from assets
    _contract = DeployedContract(
      ContractAbi.fromJson(abiString, 'Company'),
      _contractAddress,
    );
  }

  Future<void> _verifyProduct() async {
    final companyAddress = _companyAddressController.text;
    final productId = _productIdController.text;

    if (companyAddress.isEmpty || productId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Both fields are required.')),
      );
      return;
    }

    try {
      final verifyProductFunction = _contract.function('verifyProduct');
      final result = await _web3Client.call(
        contract: _contract,
        function: verifyProductFunction,
        params: [BigInt.parse(productId)],
      );

      setState(() {
        _verificationResult = result[0]; // Result will be 'Authenticated' or 'Counterfeit'
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Product'),
        backgroundColor: Colors.teal,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.white],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField('Company Address', _companyAddressController),
            const SizedBox(height: 15),
            _buildTextField('Product ID', _productIdController),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _verifyProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Verify',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 30),
            if (_verificationResult.isNotEmpty)
              Center(
                child: Text(
                  'Verification Result: $_verificationResult',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black),
        filled: true,
        fillColor: Colors.white10,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}


class ProfileScreen extends StatelessWidget {
  final User user;

  ProfileScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${user.userName} - Profile"),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Info Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Personal Details",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text("Name: ${user.userName}", style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 6),
                      Text("Date of Birth: ${user.dob}", style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 6),
                      Text("Gender: ${user.gender}", style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 6),
                      Text("Phone: ${user.phone}", style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 6),
                      Text("Email: ${user.email}", style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Medical Records Section
              const Text(
                "Previous Medical Records",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
              ),
              const SizedBox(height: 10),
              user.medicalRecords.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/placeholder_image.png',
                      height: 150,
                      width: 150,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "You have not uploaded any medical records.",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: user.medicalRecords.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 3,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      leading: const Icon(Icons.insert_drive_file, color: Colors.teal),
                      title: Text('Document ${index + 1}', style: const TextStyle(fontSize: 16)),
                      subtitle: const Text('Tap to view', style: TextStyle(fontSize: 14, color: Colors.grey)),
                      onTap: () {
                        // Implement viewing of document if needed
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Edit Details Button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate back to CreateUser screen and pass user data for editing
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateUser(
                          existingUser: user,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Edit Details',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
