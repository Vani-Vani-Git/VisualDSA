import 'package:flutter/material.dart';
import '../../../../core/services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  bool isPasswordHidden = true;

  final GlobalKey<FormState> formKey =
      GlobalKey<FormState>();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();

  final AuthService authService =
      AuthService();

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: SafeArea(

        child: SingleChildScrollView(

          child: Padding(

            padding: const EdgeInsets.all(24),

            child: Form(

              key: formKey,

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  const SizedBox(height: 50),

                  const Text(

                    "Create Account",

                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(

                    "Start your VisualDSA journey",

                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade400,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // EMAIL FIELD
                  TextFormField(

                    controller: emailController,

                    decoration: const InputDecoration(
                      hintText: "Email",
                    ),

                    validator: (value) {

                      if (value == null ||
                          value.isEmpty) {

                        return "Email required";
                      }

                      if (!value.contains("@")) {

                        return "Enter valid email";
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // PASSWORD FIELD
                  TextFormField(

                    controller: passwordController,

                    obscureText: isPasswordHidden,

                    decoration: InputDecoration(

                      hintText: "Password",

                      suffixIcon: IconButton(

                        onPressed: () {

                          setState(() {

                            isPasswordHidden =
                                !isPasswordHidden;
                          });
                        },

                        icon: Icon(

                          isPasswordHidden
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                    ),

                    validator: (value) {

                      if (value == null ||
                          value.isEmpty) {

                        return "Password required";
                      }

                      if (value.length < 6) {

                        return
                            "Minimum 6 characters";
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // CONFIRM PASSWORD FIELD
                  TextFormField(

                    controller:
                        confirmPasswordController,

                    obscureText: isPasswordHidden,

                    decoration: const InputDecoration(
                      hintText: "Confirm Password",
                    ),

                    validator: (value) {

                      if (value !=
                          passwordController.text) {

                        return
                            "Passwords do not match";
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 35),

                  // REGISTER BUTTON
                  SizedBox(

                    width: double.infinity,
                    height: 55,

                    child: ElevatedButton(

                      onPressed: () async {

                        if (formKey.currentState!
                            .validate()) {

                          try {

                            await authService.registerUser(

                              email: emailController.text.trim(),

                              password:
                                  passwordController.text.trim(),
                            );

                            ScaffoldMessenger.of(context)
                                .showSnackBar(

                              const SnackBar(
                                content: Text(
                                  "Registration Successful",
                                ),
                              ),
                            );

                            Navigator.pop(context);

                          } catch (e) {

                            ScaffoldMessenger.of(context)
                                .showSnackBar(

                              SnackBar(
                                content: Text(
                                  e.toString(),
                                ),
                              ),
                            );
                          }
                        }
                      },

                      style:
                          ElevatedButton.styleFrom(

                        backgroundColor:
                            const Color(0xFF58A6FF),

                        shape:
                            RoundedRectangleBorder(

                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                      ),

                      child: const Text(

                        "Register",

                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // BACK TO LOGIN
                  Center(

                    child: TextButton(

                      onPressed: () {

                        Navigator.pop(context);
                      },

                      child: const Text(
                        "Already have an account?",
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}