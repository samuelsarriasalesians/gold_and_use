import 'package:flutter/material.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

import 'constants.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Set background color
      appBar: AppBar(
        actions: [
          PopupMenuButton<String>(
            icon: Image.asset('assets/icono_ajustes.png'),
            onSelected: (String result) {
              switch (result) {
                case 'profile':
                  Navigator.of(context).pushNamed('/account_screen');
                  break;
                case 'settings':
                  Navigator.of(context).pushNamed('/settings_screen');
                  break;
                case 'logout':
                  Supabase.instance.client.auth.signOut();
                  Navigator.of(context).pushReplacementNamed('/');
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'profile',
                child: Text('Profile'),
              ),
              const PopupMenuItem<String>(
                value: 'settings',
                child: Text('Settings'),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 24), // Add some space above the logo
          // Logo en la parte superior
          Center(
            child: Image.asset(
              'assets/logo.png',
              height: 50,
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'You are home',
                    style: TextStyle(fontSize: 42),
                  ),
                  
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
