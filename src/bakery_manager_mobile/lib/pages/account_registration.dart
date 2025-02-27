import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  CreateAccountPageState createState() => CreateAccountPageState();
}

class CreateAccountPageState extends State<CreateAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController employeeIDController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Password requirement indicators
  bool _has8Characters = false;
  bool _hasNumber = false;
  bool _hasSpecialCharacter = false;

  @override
  void initState() {
    super.initState();
    passwordController.addListener(_validatePassword);
    usernameController.addListener(_checkRequirement);
  }

  void _validatePassword() {
    String password = passwordController.text;
    setState(() {
      _has8Characters = password.length >= 8;
      _hasNumber = password.contains(RegExp(r'\d'));
      _hasSpecialCharacter = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  void _checkRequirement() {
    if (usernameController.text.toLowerCase() == 'velociraptor') {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('RAWRRRRRR!!!!!!! 🦖'),
            content: const Text('Ya like velociprators?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _createAccount() async {
    if (_formKey.currentState!.validate()) {
      String firstName = firstNameController.text.trim();
      String lastName = lastNameController.text.trim();
      String employeeID = employeeIDController.text.trim();
      String username = usernameController.text.trim();
      String password = passwordController.text.trim();
      String email = emailController.text.trim();
      String phoneNumber = phoneController.text.trim();

      try {
        // Step 1: Attempt to create account
        Map<String, dynamic> accountResponse = await ApiService.createAccount(
          firstName,
          lastName,
          employeeID,
          username,
          password,
          email,
          phoneNumber
        );

        if (accountResponse['status'] == 'success') {
          // Step 2: Save credentials and show success message
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('username', username);
          await prefs.setString('password', password);

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account created successfully!')),
          );
          Navigator.pop(context); // Go back after success
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Account creation failed: ${accountResponse['reason']}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all fields correctly')),
      );
    }
  }

  @override
  void dispose() {
    passwordController.removeListener(_validatePassword);
    employeeIDController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 209, 125, 51),
        shape: const RoundedRectangleBorder(),
        title: const Stack(
          children: <Widget>[
            Text(
              'Register Account',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),

                TextFormField(
                  controller: firstNameController,
                  maxLength: 64, 
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    counterText: ''
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'First Name is required';
                    }
                    if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
                      return 'First Name can only contain letters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // LastName Field
                TextFormField(
                  controller: lastNameController,
                  maxLength: 64,
                  decoration: const InputDecoration(
                    labelText: 'Last Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    counterText: ''
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Last Name is required';
                    }
                    if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
                      return 'Last Name can only contain letters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // EmployeeID Field
                TextFormField(
                  controller: employeeIDController,
                  maxLength: 50,
                  decoration: const InputDecoration(
                    labelText: 'Employee ID',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    counterText: ''
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Employee ID is required';
                    }
                    if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
                      return 'Employee ID can only contain letters and numbers';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Username Field
                TextFormField(
                  controller: usernameController,
                  maxLength: 20, 
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    counterText: ''
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Employee ID is required';
                    }
                    if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
                      return 'Employee ID can only contain letters and numbers';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password Field
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: passwordController,
                        maxLength: 256, 
                        obscureText: _obscurePassword,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          counterText: ''
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password is required';
                          }
                          if (!_has8Characters) {
                            return 'Password must be at least 8 characters';
                          }
                          if (!_hasNumber) {
                            return 'Password must contain at least one number';
                          }
                          if (!_hasSpecialCharacter) {
                            return 'Password must contain at least one special character';
                          }
                          return null;
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Password Requirements
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _has8Characters ? Icons.check_circle : Icons.radio_button_unchecked,
                          color: _has8Characters ? Colors.green : Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text('At least 8 characters'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          _hasNumber ? Icons.check_circle : Icons.radio_button_unchecked,
                          color: _hasNumber ? Colors.green : Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text('Contains a number'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          _hasSpecialCharacter ? Icons.check_circle : Icons.radio_button_unchecked,
                          color: _hasSpecialCharacter ? Colors.green : Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text('Contains a special character'),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Confirm Password Field
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: const InputDecoration(
                          labelText: 'Confirm Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          counterText: ''
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Email Field
                TextFormField(
                  controller: emailController,
                  maxLength: 50,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    counterText: '',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email is required';
                    }
                    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Phone Number Field
                TextFormField(
                  controller: phoneController,
                  maxLength: 10,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    counterText: null,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Phone number is required';
                    }
                    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                      return 'Phone number must be 10 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Create Account Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 209, 125, 51),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _createAccount, // Call the create account function
                  child: const Text(
                    'Create Account',
                    style: TextStyle(color: Colors.white), // Set font color to white
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}