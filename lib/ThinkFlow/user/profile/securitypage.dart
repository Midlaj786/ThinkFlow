import 'package:flutter/material.dart';

class SecurityPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Settings'),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text('Change Password'),
              subtitle: const Text('Update your current password'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Navigate to change password screen
              },
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: ListTile(
              leading: const Icon(Icons.security),
              title: const Text('Two-Factor Authentication'),
              subtitle: const Text('Add an extra layer of protection'),
              trailing: Switch(
                value: true, // Replace with actual state
                onChanged: (value) {
                  // Enable or disable 2FA
                },
              ),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: ListTile(
              leading: const Icon(Icons.fingerprint),
              title: const Text('App Lock'),
              subtitle: const Text('Enable fingerprint or face lock'),
              trailing: Switch(
                value: false, // Replace with actual state
                onChanged: (value) {
                  // Enable or disable App Lock
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
