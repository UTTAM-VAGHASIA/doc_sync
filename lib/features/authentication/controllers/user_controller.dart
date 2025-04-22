import 'dart:convert';

import 'package:doc_sync/features/authentication/models/user_model.dart';
import 'package:doc_sync/utils/constants/enums.dart' show StorageType;
import 'package:doc_sync/utils/local_storage/storage_utility.dart';
import 'package:get/get.dart';

class UserController extends GetxController {
  Future<void> saveUserDetails(User user) async {
    final userData = jsonEncode(user.toJsonWithoutPassword());

    await StorageUtility.instance().writeData(
      "user",
      userData,
      type: StorageType.local,
    );
    await StorageUtility.instance().writeData(
      user.id.toString(),
      user.password.toString(),
      type: StorageType.secure,
    );

    // print("User Saved Successfully!");
  }

  Future<User> getUserDetails() async {
    String? token = await StorageUtility.instance().readData(
      "user",
      type: StorageType.local,
    );

    if (token == null || token == '') {
      return User.fromJson({});
    } else {
      return User.fromJson(jsonDecode(token));
    }
  }

  Future<User> getLoginCredentials() async {
    String? userData = await StorageUtility.instance().readData(
      "user",
      type: StorageType.local,
    );
    if (userData == null || userData == '' || userData == '{}') {
      return User.fromJson({});
    } else {
      User userWithoutPassword = User.fromJson(jsonDecode(userData));
      String id = userWithoutPassword.id!;

      String? password = await StorageUtility.instance().readData(
        id,
        type: StorageType.secure,
      );

      return User.fromJson({
        "email": userWithoutPassword.email,
        "password": password,
      });
    }
  }

  Future<void> clearUser({List<String> buckets = const ["userData"]}) async {
    await StorageUtility.instance().clearAll(localBuckets: buckets); // clears both local and secure
  }
}
