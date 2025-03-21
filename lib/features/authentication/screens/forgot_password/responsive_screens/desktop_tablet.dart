import 'package:doc_sync/common/widgets/layout/templates/login_template.dart';
import 'package:doc_sync/features/authentication/screens/forgot_password/widgets/header_form.dart';
import 'package:flutter/material.dart';

class DesktopTabletForgotPasswordScreen extends StatelessWidget {
  const DesktopTabletForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLoginTemplate(child: HeaderAndForm());
  }
}
