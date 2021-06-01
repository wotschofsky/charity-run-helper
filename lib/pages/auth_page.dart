import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:form_validator/form_validator.dart';
import 'package:velocity_x/velocity_x.dart';

class AuthPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void showSnackbar(BuildContext ctx, String message) {
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(message)));
  }

  void signUp(BuildContext ctx) async {
    if (!_formKey.currentState!.validate()) {
      showSnackbar(ctx, 'Please complete the form!');
      return;
    }

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.value.text,
          password: passwordController.value.text);

      VxNavigator.of(ctx).pop();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        showSnackbar(ctx, 'The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        showSnackbar(ctx, 'The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }

  void signIn(BuildContext ctx) async {
    if (!_formKey.currentState!.validate()) {
      showSnackbar(ctx, 'Please complete the form!');
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.value.text,
          password: passwordController.value.text);

      VxNavigator.of(ctx).pop();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showSnackbar(ctx, 'No user found for that email.');
      } else if (e.code == 'wrong-password') {
        showSnackbar(ctx, 'Wrong password provided for that user.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Authentication'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: 'Email'),
                  validator: ValidationBuilder().email().build()),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(), labelText: 'Password'),
                    validator: ValidationBuilder().minLength(8).build()),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () => signIn(context),
                    child: const Text('Sign In'),
                  ),
                  TextButton(
                    onPressed: () => signUp(context),
                    child: const Text('Sign Up'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
