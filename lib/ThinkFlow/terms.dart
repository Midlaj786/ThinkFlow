import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thinkflow/ThinkFlow/Theme.dart';

class TermsAndConditionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Terms & Conditions", style: TextStyle(color: themeProvider.textColor)),
        iconTheme: IconThemeData(color: themeProvider.textColor),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: themeProvider.backgroundColor,
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Text(
            '''
Welcome to ThinkFlow!

Please read these Terms and Conditions carefully before using our app.

1. **Acceptance of Terms**
By accessing or using ThinkFlow, you agree to be bound by these terms.

2. **Use of the Service**
You must not use the service for any illegal or unauthorized purpose.

3. **User Data**
We collect and store personal data in accordance with our Privacy Policy.

4. **Intellectual Property**
All content remains the property of ThinkFlow unless otherwise stated.

5. **Modifications**
We reserve the right to change these terms at any time.

If you have questions, contact us at support@thinkflow.com.
            ''',
            style: TextStyle(color: themeProvider.textColor, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
