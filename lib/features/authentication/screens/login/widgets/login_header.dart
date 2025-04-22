import 'package:doc_sync/utils/constants/image_strings.dart';
import 'package:doc_sync/utils/constants/sizes.dart';
import 'package:doc_sync/utils/constants/text_strings.dart';
import 'package:flutter/material.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image(
                  width: 90,
                  height: 100,
                  image: AssetImage(AppImages.lightAppLogo),
                ),
                // Expanded(
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     mainAxisSize: MainAxisSize.min,
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     children: [
                //       RichText(
                //         text: TextSpan(
                //           children: [
                //             TextSpan(
                //               text: '\n',
                //               style: TextStyle(
                //                 color: AppColors.primary,
                //                 fontSize: 40,
                //                 fontWeight: FontWeight.w900,
                //                 height: 1.3, // Reduced line height
                //               ),
                //             ),
                //             TextSpan(
                //               text: 'oc',
                //               style: TextStyle(
                //                 color: AppColors.primary,
                //                 fontSize: 54,
                //                 fontWeight: FontWeight.w900,
                //                 height: 0.1, // Reduced line height
                //               ),
                //             ),
                //             TextSpan(
                //               text: '\nync',
                //               style: TextStyle(
                //                 color: AppColors.primary,
                //                 fontSize: 54,
                //                 fontWeight: FontWeight.w900,
                //                 height: 0.8, // Reduced line height
                //               ),
                //             ),
                //           ],
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
              ],
            ),
          ),
          SizedBox(height: AppSizes.spaceBtwSections),
          Text(
            AppTexts.loginTitle,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(height: AppSizes.sm),
          Text(
            AppTexts.loginSubTitle,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
