import 'package:doc_sync/common/widgets/layout/templates/login_template.dart';
import 'package:doc_sync/features/authentication/screens/reset_password/widgets/reset_password_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DesktopTabletResetPasswordScreen extends StatelessWidget {
  const DesktopTabletResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLoginTemplate(child: ResetPasswordWidget());
  }
}
