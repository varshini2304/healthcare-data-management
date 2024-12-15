import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'api_service.dart'; // Import the file containing the ApiService class
import 'package:firebase_core/firebase_core.dart';
import 'dart:io';
const Color appBarButtonColor = Color(0xFF363636);

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
  // Instantiate ApiService
  final ApiService apiService = ApiService();

  DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: fetchUser,
            child: const Text('Get User'),
          ),
          ElevatedButton(
            onPressed: createUser,
            child: const Text('Create User'),
          ),
          ElevatedButton(
            onPressed: addProduct,
            child: const Text('Add Product'),
          ),
          ElevatedButton(
            onPressed: checkProduct,
            child: const Text('Check Product'),
          ),
        ],
      ),
    );
  }

  // Fetch user details
  void fetchUser() async {
    try {
      final user = await apiService.getUser('123'); // Replace '123' with actual user ID
      print('User fetched: $user');
    } catch (e) {
      print('Error fetching user: $e');
    }
  }

  // Create a new user
  void createUser() async {
    try {
      final result = await apiService.createUser('123', 'John Doe'); // Replace with actual data
      print('User created: $result');
    } catch (e) {
      print('Error creating user: $e');
    }
  }

  // Add a product
  void addProduct() async {
    try {
      final result = await apiService.addProduct('001', 'Laptop', '123'); // Replace with actual data
      print('Product added: $result');
    } catch (e) {
      print('Error adding product: $e');
    }
  }

  // Check product details
  void checkProduct() async {
    try {
      final product = await apiService.checkProduct('001'); // Replace '001' with actual product ID
      print('Product details: $product');
    } catch (e) {
      print('Error fetching product: $e');
    }
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
  String userId;
  String name;
  String dob;
  String gender;
  String phone;
  String email;
  String aadharNumber;
  List<File> medicalRecords;

  User({
    required this.userId,
    this.name = "Your Name Here",
    this.dob = "Your DOB Here",
    this.gender = "Your Gender Here",
    this.phone = "Your Phone Number Here",
    this.email = "Your Email Here",
    this.aadharNumber = "Your Aadhaar Number Here",
    this.medicalRecords = const [],
  });
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade800, Colors.black],
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
                Text('Captcha: $_captcha', style: const TextStyle(color: Colors.white, fontSize: 20)),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: _generateCaptcha,
                ),
              ],
            ),
            _buildTextField('Enter Captcha', _captchaController),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signUp,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: Colors.transparent,
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.pinkAccent, Colors.blueAccent],
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
      style: const TextStyle(color: Colors.white, fontSize: 18),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 20),
        filled: true,
        fillColor: Colors.white10,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5),
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
        backgroundColor: appBarButtonColor,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade800, Colors.black],
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
                backgroundColor: Colors.transparent,
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.pinkAccent, Colors.blueAccent],
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
      style: const TextStyle(color: Colors.white, fontSize: 18),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 20),
        filled: true,
        fillColor: Colors.white10,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5),
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
        backgroundColor: Colors.black.withOpacity(0.7),
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade800, Colors.black],
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
                  MaterialPageRoute(
                    builder: (context) => const MessageScreen(message: 'Hi, welcome to Add Product!'),
                  ),
                );
              },
            ),
            MainScreenButton(
              icon: Icons.verified_rounded,
              label: 'Check Product',
              gradientColors: [Colors.tealAccent, Colors.teal],
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MessageScreen(message: 'Hi, welcome to Check Product!'),
                  ),
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
  final User? existingUser; // Added the named parameter

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

  @override
  void initState() {
    super.initState();
    if (widget.existingUser != null) {
      _nameController.text = widget.existingUser!.name;
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

  // Pick Documents (images or other types)
  Future<void> _pickDocuments() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      setState(() {
        _medicalRecords = result.paths.map((path) => File(path!)).toList();
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

  void _createUser() {
    // Collect form data and create the User object
    User newUser = User(
      userId: 'USER-${Random().nextInt(999999)}',
      name: _nameController.text.isEmpty ? "Your Name Here" : _nameController.text,
      dob: _selectedDOB ?? "Your DOB Here",
      gender: _selectedGender ?? "Your Gender Here",
      phone: _phoneController.text.isEmpty ? "Your Phone Number Here" : _phoneController.text,
      email: _emailController.text.isEmpty ? "Your Email Here" : _emailController.text,
      aadharNumber: _aadharController.text.isEmpty ? "Your Aadhaar Number Here" : _aadharController.text,
      medicalRecords: _medicalRecords,
    );

    // Navigate to ProfileScreen with the newUser object
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ProfileScreen(user: newUser)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create User')),
      body: Container(
        padding: const EdgeInsets.all(30.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade800, Colors.black],
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

              // Date of Birth Selector
              GestureDetector(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedDOB ?? 'Select Date of Birth',
                        style: TextStyle(
                          color: _selectedDOB == null ? Colors.white.withOpacity(0.7) : Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      const Icon(Icons.calendar_today, color: Colors.white),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),

              // Gender Selector (Radio Buttons)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Gender",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
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
                        activeColor: Colors.blueAccent,
                      ),
                      const Text(
                        "Male",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      Radio<String>(
                        value: 'Female',
                        groupValue: _selectedGender,
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value;
                          });
                        },
                        activeColor: Colors.pinkAccent,
                      ),
                      const Text(
                        "Female",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 22),

              _buildTextField('Phone Number', _phoneController, keyboardType: TextInputType.phone),
              const SizedBox(height: 22),
              _buildTextField('Email', _emailController, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 22),
              _buildTextField('Aadhaar Number', _aadharController, keyboardType: TextInputType.number),
              const SizedBox(height: 22),

              ElevatedButton(
                onPressed: _pickDocuments,
                child: const Text(
                  "Upload Medical Records",
                  style: TextStyle(fontSize: 15, color: Colors.black),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'Uploaded: ${_medicalRecords.length} file(s)',
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
              const SizedBox(height: 26),

              ElevatedButton(
                onPressed: _createUser,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Colors.transparent,
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.pinkAccent, Colors.blueAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: const Text(
                      'Create User',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // TextField widget with custom decoration to match the SignUpScreen design
  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text, bool obscureText = false}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white, fontSize: 18),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 20),
        filled: true,
        fillColor: Colors.white10,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5),
        ),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  final User user;

  const ProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${user.name} - Profile"),
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
                      Text("Name: ${user.name}", style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 6),
                      Text("Date of Birth: ${user.dob}", style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 6),
                      Text("Gender: ${user.gender}", style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 6),
                      Text("Phone: ${user.phone}", style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 6),
                      Text("Email: ${user.email}", style: TextStyle(fontSize: 16)),
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
                itemCount: user.medicalRecords.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 3,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      leading: const Icon(Icons.insert_drive_file, color: Colors.teal),
                      title: Text('Document ${index + 1}', style: TextStyle(fontSize: 16)),
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
