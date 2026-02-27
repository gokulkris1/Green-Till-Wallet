import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greentill/bloc/main_bloc.dart';
import 'package:greentill/ui/res/color_resources.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Green Till'),
        backgroundColor: colortheme,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<MainBloc>().add(const NavigateToLogin());
            },
          )
        ],
      ),
      body: const Center(
        child: Text(
          'Welcome to Green Till!',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
