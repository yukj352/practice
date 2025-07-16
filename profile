import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dashboardPage.dart';
import 'itemDashboard.dart';
import 'db_helper.dart';  // Import your DatabaseHelper here

class profilePage extends StatefulWidget {
  final int userId;

  const profilePage({Key? key, required this.userId}) : super(key: key);

  @override
  State<profilePage> createState() => _profilePageState();
}

class _profilePageState extends State<profilePage> {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController(text: '');
  final TextEditingController _emailController = TextEditingController(text: '');
  final TextEditingController _passwordController = TextEditingController(text: '');
  final TextEditingController _confirmPasswordController = TextEditingController(text: '');

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  int _selectedIndex = 2; // Profile is current tab index

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await DatabaseHelper().getUserById(widget.userId);
    if (user != null) {
      setState(() {
        _nameController.text = user['name'] ?? '';
        _emailController.text = user['email'] ?? '';
        // Leave password fields empty for security reasons
        _passwordController.text = '';
        _confirmPasswordController.text = '';
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  void _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      // Prepare updated data map
      Map<String, dynamic> updatedData = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
      };

      // If user entered new password, hash it and add to update map
      if (_passwordController.text.isNotEmpty) {
        updatedData['password'] = DatabaseHelper().hashPassword(_passwordController.text);
      }

      // Check if email is already taken by another user
      bool emailTaken = await DatabaseHelper().isEmailTaken(updatedData['email'], excludeUserId: widget.userId);

      if (emailTaken) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email is already in use by another user.')),
        );
        return;
      }

      // Update in DB
      int result = await DatabaseHelper().updateUser(widget.userId, updatedData);

      if (result > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => dashboardPage(userId: widget.userId)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile.')),
        );
      }
    }
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    if (index == 0) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => dashboardPage(userId: widget.userId)));
    } else if (index == 1) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => itemDashboard(userId: widget.userId)));
    } else if (index == 2) {
      // Already on profile page
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF010080),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new),
          color: Color(0xFFF7F4F2),
          onPressed: () async {
            print("back button pressed");
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => dashboardPage(userId: widget.userId)),
            );
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFD3E3FD),
              Color(0xFFFFFFFF),
              Color(0xFF505AD8),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 70,
                            backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                            child: _profileImage == null
                                ? Icon(
                              Icons.person,
                              size: 70,
                              color: Colors.grey[400],
                            )
                                : null,
                            backgroundColor: Colors.grey[200],
                          ),
                          Positioned(
                            bottom: 0,
                            right: 4,
                            child: InkWell(
                              onTap: _pickImage,
                              child: CircleAvatar(
                                radius: 20,
                                backgroundColor: Color(0xFF010080),
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) =>
                        value == null || value.isEmpty ? 'Please enter your name' : null,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          final emailRegex = RegExp(
                              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
                          if (!emailRegex.hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (_passwordController.text.isNotEmpty &&
                              (value == null || value.length < 6)) {
                            return 'Enter min 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (_passwordController.text.isNotEmpty &&
                              value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _updateProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF000000),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text("Update Profile", style: TextStyle(fontSize: 16)),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            BottomNavigationBar(
              backgroundColor: Color(0xFF010080),
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white70,
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  label: 'Item Details',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}










// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dashboardPage.dart';
// import 'itemDashboard.dart';
// import 'db_helper.dart';  // Import your DatabaseHelper here
//
// class profilePage extends StatefulWidget {
//   final int userId;
//
//   const profilePage({Key? key, required this.userId}) : super(key: key);
//
//   @override
//   State<profilePage> createState() => _profilePageState();
// }
//
// class _profilePageState extends State<profilePage> {
//   File? _profileImage;
//   final ImagePicker _picker = ImagePicker();
//
//   final _formKey = GlobalKey<FormState>();
//
//   final TextEditingController _nameController = TextEditingController(text: '');
//   final TextEditingController _emailController = TextEditingController(text: '');
//   final TextEditingController _passwordController = TextEditingController(text: '');
//   final TextEditingController _confirmPasswordController = TextEditingController(text: '');
//
//   bool _obscurePassword = true;
//   bool _obscureConfirmPassword = true;
//
//   int _selectedIndex = 2; // Profile is current tab index
//
//   @override
//   void initState() {
//     super.initState();
//     _loadUserData();
//   }
//
//   Future<void> _loadUserData() async {
//     final user = await DatabaseHelper().getUserById(widget.userId);
//     if (user != null) {
//       setState(() {
//         _nameController.text = user['name'] ?? '';
//         _emailController.text = user['email'] ?? '';
//         // Leave password fields empty for security reasons
//         _passwordController.text = '';
//         _confirmPasswordController.text = '';
//       });
//     }
//   }
//
//   Future<void> _pickImage() async {
//     final pickedFile =
//     await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
//
//     if (pickedFile != null) {
//       setState(() {
//         _profileImage = File(pickedFile.path);
//       });
//     }
//   }
//
//   void _updateProfile() async {
//     if (_formKey.currentState!.validate()) {
//       // Prepare updated data map
//       Map<String, dynamic> updatedData = {
//         'name': _nameController.text.trim(),
//         'email': _emailController.text.trim(),
//       };
//
//       // If user entered new password, hash it and add to update map
//       if (_passwordController.text.isNotEmpty) {
//         updatedData['password'] =
//             DatabaseHelper().hashPassword(_passwordController.text);
//       }
//
//       // Check if email is already taken by another user
//       bool emailTaken = await DatabaseHelper()
//           .isEmailTaken(updatedData['email'], excludeUserId: widget.userId);
//
//       if (emailTaken) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Email is already in use by another user.')),
//         );
//         return;
//       }
//
//       // Update in DB
//       int result =
//       await DatabaseHelper().updateUser(widget.userId, updatedData);
//
//       if (result > 0) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Profile updated successfully!')),
//         );
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => dashboardPage(userId: widget.userId)),
//         );
//
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to update profile.')),
//         );
//       }
//     }
//   }
//
//   void _onItemTapped(int index) {
//     if (index == _selectedIndex) return;
//     if (index == 0) {
//       Navigator.pushReplacement(
//           context, MaterialPageRoute(builder: (_) => dashboardPage(userId: widget.userId)));
//     } else if (index == 1) {
//       Navigator.pushReplacement(
//           context, MaterialPageRoute(builder: (_) => itemDashboard(userId: widget.userId)));
//     } else if (index == 2) {
//       // Already on profile page
//     }
//   }
//
//   @override
//   void dispose() {
//     _nameController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Profile',
//             style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
//         backgroundColor: const Color(0xFF010080),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back_ios_new),
//           color: Color(0xFFF7F4F2),
//           onPressed: () async{
//             print("back button pressed");
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (_) => dashboardPage(userId: widget.userId)),
//             );
//           },
//         ),
//       ),
//       body:Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               Color(0xFFD3E3FD),
//               Color(0xFFFFFFFF),
//               Color(0xFF505AD8),
//             ],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(20),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               children: [
//                 Stack(
//                   children: [
//                     CircleAvatar(
//                       radius: 70,
//                       backgroundImage:
//                       _profileImage != null ? FileImage(_profileImage!) : null,
//                       child: _profileImage == null
//                           ? Icon(
//                         Icons.person,
//                         size: 70,
//                         color: Colors.grey[400],
//                       )
//                           : null,
//                       backgroundColor: Colors.grey[200],
//                     ),
//                     Positioned(
//                       bottom: 0,
//                       right: 4,
//                       child: InkWell(
//                         onTap: _pickImage,
//                         child: CircleAvatar(
//                           radius: 20,
//                           backgroundColor: Color(0xFF010080),
//                           child: Icon(
//                             Icons.camera_alt,
//                             color: Colors.white,
//                             size: 22,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 30),
//                 TextFormField(
//                   controller: _nameController,
//                   decoration: InputDecoration(
//                     labelText: 'Name',
//                     border: OutlineInputBorder(),
//                     prefixIcon: Icon(Icons.person),
//                   ),
//                   validator: (value) =>
//                   value == null || value.isEmpty ? 'Please enter your name' : null,
//                 ),
//                 const SizedBox(height: 20),
//                 TextFormField(
//                   controller: _emailController,
//                   decoration: InputDecoration(
//                     labelText: 'Email',
//                     border: OutlineInputBorder(),
//                     prefixIcon: Icon(Icons.email),
//                   ),
//                   keyboardType: TextInputType.emailAddress,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter your email';
//                     }
//                     final emailRegex = RegExp(
//                         r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
//                     if (!emailRegex.hasMatch(value)) {
//                       return 'Please enter a valid email';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 20),
//                 TextFormField(
//                   controller: _passwordController,
//                   obscureText: _obscurePassword,
//                   decoration: InputDecoration(
//                     labelText: 'Password',
//                     border: OutlineInputBorder(),
//                     prefixIcon: Icon(Icons.lock),
//                     suffixIcon: IconButton(
//                       icon: Icon(
//                         _obscurePassword ? Icons.visibility_off : Icons.visibility,
//                       ),
//                       onPressed: () {
//                         setState(() {
//                           _obscurePassword = !_obscurePassword;
//                         });
//                       },
//                     ),
//                   ),
//                   validator: (value) {
//                     if (_passwordController.text.isNotEmpty &&
//                         (value == null || value.length < 6)) {
//                       return 'Enter min 6 characters';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 20),
//                 TextFormField(
//                   controller: _confirmPasswordController,
//                   obscureText: _obscureConfirmPassword,
//                   decoration: InputDecoration(
//                     labelText: 'Confirm Password',
//                     border: OutlineInputBorder(),
//                     prefixIcon: Icon(Icons.lock_outline),
//                     suffixIcon: IconButton(
//                       icon: Icon(
//                         _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
//                       ),
//                       onPressed: () {
//                         setState(() {
//                           _obscureConfirmPassword = !_obscureConfirmPassword;
//                         });
//                       },
//                     ),
//                   ),
//                   validator: (value) {
//                     if (_passwordController.text.isNotEmpty &&
//                         value != _passwordController.text) {
//                       return 'Passwords do not match';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 40),
//                 SizedBox(
//                   width: double.infinity,
//                   height: 50,
//                   child: ElevatedButton(
//                     onPressed: _updateProfile,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFF000000),
//                       foregroundColor: Colors.white,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: const Text("Update Profile", style: TextStyle(fontSize: 16)),
//                   ),
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//
//
//
//       bottomNavigationBar: BottomNavigationBar(
//         backgroundColor: Color(0xFF010080),
//         selectedItemColor: Colors.white,
//         unselectedItemColor: Colors.white70,
//         currentIndex: _selectedIndex,
//         onTap: _onItemTapped,
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.search),
//             label: 'Item Details',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person),
//             label: 'Profile',
//           ),
//         ],
//       ),
//     );
//   }
// }
