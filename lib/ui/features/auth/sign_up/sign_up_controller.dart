import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:exbix_flutter/data/local/constants.dart';
import 'package:exbix_flutter/data/remote/api_repository.dart';
import 'package:exbix_flutter/ui/features/auth/email_verify/email_verify_page.dart';
import 'package:exbix_flutter/utils/common_utils.dart';

class SignUpController extends GetxController {
  TextEditingController firstNameEditController = TextEditingController();
  TextEditingController lastNameEditController = TextEditingController();
  TextEditingController emailEditController = TextEditingController();
  TextEditingController phoneEditController = TextEditingController();
  TextEditingController passEditController = TextEditingController();
  TextEditingController confirmPassEditController = TextEditingController();
  RxBool isShowPassword = false.obs;
  Rx<Country> selectedPhone = Country.parse("US").obs;

  void clearInputData() {
    firstNameEditController.text = "";
    lastNameEditController.text = "";
    emailEditController.text = "";
    passEditController.text = "";
    confirmPassEditController.text = "";
    phoneEditController.text = "";
    isShowPassword = false.obs;
  }

  void isInPutDataValid(BuildContext context) {
    if (firstNameEditController.text.trim().isNotEmpty &&
        lastNameEditController.text.trim().isNotEmpty &&
        emailEditController.text.trim().isNotEmpty &&
        passEditController.text.isNotEmpty &&
        confirmPassEditController.text.isNotEmpty) {
      if (!GetUtils.isEmail(emailEditController.text.trim())) {
        showToast("Input a valid Email".tr);
        return;
      }

      if (!isValidPassword(passEditController.text)) {
        showToast("Password_invalid_message".trParams({"count": DefaultValue.kPasswordLength.toString()}), isError: true);
        return;
      }

      if (passEditController.text != confirmPassEditController.text) {
        showToast("Password and confirm password not matched".tr);
        return;
      }
      hideKeyboard(context: context);
      signUp();
    } else {
      showToast("Fields can not be empty".tr);
    }
  }

  void signUp() {
    showLoadingDialog();
    String? phone;
    if (phoneEditController.text.trim().isNotEmpty) {
      var number = removeSpecialChar(phoneEditController.text.trim());
      if (number.length > selectedPhone.value.phoneCode.length) phone = number;
    }
    APIRepository()
        .registerUser(
            firstNameEditController.text.trim(), lastNameEditController.text.trim(), emailEditController.text.trim(), passEditController.text,
            phone: phone)
        .then((resp) {
      hideLoadingDialog();
      showToast(resp.message, isError: !resp.success);
      if (resp.success) {
        Get.off(() => EmailVerifyPage(registrationId: emailEditController.text.trim()));
      }
    }, onError: (err) {
      hideLoadingDialog();
      showToast(err.toString());
    });
  }
}
