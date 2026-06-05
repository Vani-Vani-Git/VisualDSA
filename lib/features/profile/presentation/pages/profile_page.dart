import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() =>
      _ProfilePageState();
}

class _ProfilePageState
    extends State<ProfilePage> {

  final TextEditingController
      emailController =
      TextEditingController(
    text: 'vani@gmail.com',
  );

  final TextEditingController
      phoneController =
      TextEditingController(
    text: '+91 9876543210',
  );

  final TextEditingController
      passwordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xFF0D1117),

      appBar: AppBar(

        backgroundColor:
            const Color(0xFF161B22),

        title: const Text(
          'User Profile',
        ),
      ),

      body: SingleChildScrollView(

        padding:
            const EdgeInsets.all(20),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            const Center(

              child: CircleAvatar(

                radius: 45,

                backgroundColor:
                    Colors.blue,

                child: Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 30),

            const Text(

              'Email',

              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 8),

            TextField(

              controller:
                  emailController,

              style: const TextStyle(
                color: Colors.white,
              ),

              decoration:
                  _inputDecoration(),
            ),

            const SizedBox(height: 20),

            const Text(

              'Phone Number',

              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 8),

            TextField(

              controller:
                  phoneController,

              style: const TextStyle(
                color: Colors.white,
              ),

              decoration:
                  _inputDecoration(),
            ),

            const SizedBox(height: 20),

            const Text(

              'Change Password',

              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 8),

            TextField(

              controller:
                  passwordController,

              obscureText: true,

              style: const TextStyle(
                color: Colors.white,
              ),

              decoration:
                  _inputDecoration(
                hint:
                    'Enter new password',
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(

              width: double.infinity,

              height: 52,

              child: ElevatedButton(

                onPressed: () {

                  ScaffoldMessenger.of(
                          context)
                      .showSnackBar(

                    const SnackBar(

                      content: Text(
                        'Profile Updated',
                      ),
                    ),
                  );
                },

                style:
                    ElevatedButton.styleFrom(

                  backgroundColor:
                      Colors.blue,

                  shape:
                      RoundedRectangleBorder(

                    borderRadius:
                        BorderRadius.circular(
                            14),
                  ),
                ),

                child: const Text(

                  'Save Changes',

                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    String? hint,
  }) {

    return InputDecoration(

      hintText: hint,

      hintStyle: const TextStyle(
        color: Colors.white38,
      ),

      filled: true,

      fillColor:
          const Color(0xFF161B22),

      border:
          OutlineInputBorder(

        borderRadius:
            BorderRadius.circular(14),

        borderSide: BorderSide.none,
      ),
    );
  }
}