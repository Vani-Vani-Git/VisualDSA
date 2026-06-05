import 'package:flutter/material.dart';
import 'register_page.dart';
import '../../../../core/services/auth_service.dart';
import 'package:visualdsa/features/home/presentation/pages/main_shell.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() =>
      _LoginPageState();
}

class _LoginPageState
    extends State<LoginPage> {

  bool isPasswordHidden = true;

  final GlobalKey<FormState> formKey =
      GlobalKey<FormState>();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  final AuthService authService =
    AuthService();

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: SafeArea(

        child: Padding(
          padding: const EdgeInsets.all(24),

          child: Form(
            key: formKey,

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                const SizedBox(height: 60),

                const Text(
                  "VisualDSA",

                  style: TextStyle(
                    fontSize: 38,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  "Learn Algorithms Visually",

                  style: TextStyle(
                    fontSize: 16,
                    color:
                        Colors.grey.shade400,
                  ),
                ),

                const SizedBox(height: 50),

                TextFormField(
                  controller: emailController,

                  decoration:
                      const InputDecoration(
                    hintText: "Email",
                  ),

                  validator: (value) {

                    if (value == null ||
                        value.isEmpty) {

                      return
                          "Email required";
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 20),

                TextFormField(
                  controller:
                      passwordController,

                  obscureText:
                      isPasswordHidden,

                  decoration:
                      InputDecoration(

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
                            ? Icons
                                .visibility_off
                            : Icons.visibility,
                      ),
                    ),
                  ),

                  validator: (value) {

                    if (value == null ||
                        value.isEmpty) {

                      return
                          "Password required";
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 55,

                  child: ElevatedButton(

                    onPressed: () async {

                      if (formKey
                          .currentState!
                          .validate()) {
                        try {
                           await authService.loginUser(
                            email: emailController.text.trim(),
                            password: passwordController.text.trim(),
                           );
                           ScaffoldMessenger.of(context).showSnackBar (
                            const SnackBar (content: Text ("Login Successful",),),
                           );
                           Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const MainShell()),
                                        (route) => false,);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar (
                            SnackBar(content: Text(e.toString(),),),
                          );
                        }
                      }
                    },

                    style:
                        ElevatedButton
                            .styleFrom(

                      backgroundColor:
                          const Color(
                              0xFF58A6FF),

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                                    14),
                      ),
                    ),

                    child: const Text(
                      "Login",

                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Center(
                  child: TextButton(

                    onPressed: () {

                      Navigator.push(

                        context,

                        MaterialPageRoute(

                          builder:
                              (context) =>
                                  const RegisterPage(),
                        ),
                      );
                    },

                    child: const Text(
                      "Create Account",
                    ),
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