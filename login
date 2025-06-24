import 'package:final_cal/SignUpPage.dart';
import 'package:flutter/material.dart';

import 'dashboardPage.dart';

class loginPage extends StatefulWidget {
  const loginPage({super.key});

  @override
  State<loginPage> createState() => _loginPageState();
}

class _loginPageState extends State<loginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new),color: Color(0xFFF7F4F2),
        onPressed: (){
              Navigator.pop(context);
        },
        ),
        title: const Text("Login", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF010080),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFD3E3FD),
                Color(0xFFFFFFFF),
                // Peach Puff
                Color(0xFF505AD8),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            color: Color(0xFFFFFFFF)

        ),
        child: Form(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: ListView(
                shrinkWrap: true,
                children: [
                  const SizedBox(height: 16),
                  _buildTextField("Email", "Enter your email", Icons.email),
                  const SizedBox(height: 16),
                  _buildTextField("Password", "Enter your password", Icons.lock, obscureText: true),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(context,
                          MaterialPageRoute(builder: (context)=>dashboardPage()),);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF000000),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Submit", style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("New User?"),
                      TextButton(
                        onPressed: () {
                          Navigator.push(context,
                          MaterialPageRoute(builder: (context)=>SignupPage()),);
                        },
                        child: const Text("Create Account"),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),

    );
  }

  Widget _buildTextField(String label, String hint, IconData icon, {bool obscureText = false}) {
    return TextFormField(
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.grey[500],
          fontSize: 14,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.normal,
          letterSpacing: 0.5,
        ),
        prefixIcon: Icon(icon, color: Color(0xFF000000)),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF010080), width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
