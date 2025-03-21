import 'package:doc_sync/common/widgets/layout/templates/login_template.dart';
import 'package:doc_sync/features/authentication/screens/login/widgets/login_form.dart';
import 'package:doc_sync/features/authentication/screens/login/widgets/login_header.dart';
import 'package:flutter/material.dart';

class MobileLoginScreen extends StatelessWidget {
  const MobileLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLoginTemplate(
      child: Column(
        children: [
          // Header
          LoginHeader(),

          // Form
          LoginForm(),
        ],
      ),
    );
  }
}
