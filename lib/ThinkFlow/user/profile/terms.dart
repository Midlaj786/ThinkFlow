import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thinkflow/thinkflow/Theme.dart';

class TermsAndConditionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Terms & Conditions",
          style: TextStyle(
            color: themeProvider.textColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: IconThemeData(color: themeProvider.textColor),
       backgroundColor: themeProvider.backgroundColor,
        elevation: 0,
      ),
      backgroundColor: themeProvider.backgroundColor,
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: SelectableText(
            '''
Welcome to ThinkFlow!

Please read these Terms and Conditions carefully before using our app.

1. ACCEPTANCE OF TERMS
By accessing or using ThinkFlow, you agree to be bound by these terms.

2. USE OF THE SERVICE
You must not use the service for any illegal or unauthorized purpose.

3. USER DATA
We collect and store personal data in accordance with our Privacy Policy.

4. INTELLECTUAL PROPERTY
All content remains the property of ThinkFlow unless otherwise stated.

5. MODIFICATIONS
We reserve the right to change these terms at any time.

If you have any questions, contact us at: support@thinkflow.com
            ''',
            style: TextStyle(
              color: themeProvider.textColor,
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
