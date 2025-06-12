import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:exbix_flutter/data/models/fiat_deposit.dart';
import 'package:exbix_flutter/data/models/wallet.dart';
import 'package:exbix_flutter/ui/features/auth/sign_in/sign_in_screen.dart';
import 'package:exbix_flutter/utils/alert_util.dart';
import 'package:exbix_flutter/utils/common_widgets.dart';
import 'package:exbix_flutter/utils/extentions.dart';
import 'package:exbix_flutter/utils/spacers.dart';
import 'package:exbix_flutter/utils/text_util.dart';
import 'package:exbix_flutter/data/local/constants.dart';
import 'package:exbix_flutter/ui/features/auth/sign_up/sign_up_screen.dart';
import 'package:exbix_flutter/utils/button_util.dart';
import 'package:exbix_flutter/utils/common_utils.dart';
import 'package:exbix_flutter/utils/decorations.dart';
import 'package:exbix_flutter/utils/dimens.dart';

class TwoTextSpaceFixed extends StatelessWidget {
  const TwoTextSpaceFixed(this.text, this.subText,
      {super.key,
      this.subColor,
      this.color,
      this.maxLine,
      this.subMaxLine,
      this.fontSize,
      this.flex,
      this.subTextAlign,
      this.tFontSize,
      this.vFontSize});

  final String text;
  final String subText;
  final Color? subColor;
  final Color? color;
  final int? maxLine;
  final int? subMaxLine;
  final double? fontSize;
  final double? tFontSize;
  final double? vFontSize;
  final int? flex;
  final TextAlign? subTextAlign;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
            flex: flex ?? 3,
            child: TextRobotoAutoBold(text,
                fontSize: tFontSize ?? fontSize,
                color: color ?? context.theme.primaryColorLight,
                textAlign: TextAlign.start,
                maxLines: maxLine ?? 1)),
        Expanded(
            flex: 6,
            child: TextRobotoAutoBold(subText,
                fontSize: vFontSize ?? fontSize,
                color: subColor,
                textAlign: subTextAlign ?? TextAlign.end,
                minFontSize: Dimens.regularFontSizeExtraMid,
                maxLines: subMaxLine ?? 1)),
      ],
    );
  }
}

Widget twoTextSpaceFixed(String text, String subText,
    {Color? subColor, Color? color, int maxLine = 1, int subMaxLine = 1, double? fontSize, int? flex}) {
  fontSize = fontSize ?? Dimens.regularFontSizeMid;
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(flex: flex ?? 3, child: TextRobotoAutoBold(text, fontSize: fontSize, color: color, textAlign: TextAlign.start, maxLines: maxLine)),
      Expanded(
          flex: 6,
          child: TextRobotoAutoBold(subText,
              fontSize: fontSize, color: subColor, textAlign: TextAlign.end, minFontSize: Dimens.regularFontSizeExtraMid, maxLines: subMaxLine)),
    ],
  );
}

Widget signInNeedView({bool isDrawer = false}) {
  final logoSize = isDrawer ? Dimens.iconSizeLargeExtra : Dimens.iconSizeLogo;
  return Padding(
    padding: const EdgeInsets.all(Dimens.paddingMid),
    child: SizedBox(
      height: isDrawer ? 210 : getContentHeight(withBottomNav: true, withToolbar: true) - 100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppLogo(size: logoSize),
          vSpacer20(),
          TextRobotoAutoBold("Sign In to unlock".tr, maxLines: 3, textAlign: TextAlign.center),
          isDrawer ? vSpacer10() : vSpacer20(),
          isDrawer
              ? buttonText("Sign In".tr, onPress: () => Get.offAll(() => const SignInPage()), visualDensity: VisualDensity.compact)
              : buttonRoundedMain(text: "Sign In".tr, onPress: () => Get.offAll(() => const SignInPage()), buttonHeight: Dimens.btnHeightMid),
          isDrawer ? vSpacer10() : vSpacer20(),
          textSpanWithAction('Do not have account'.tr, "Sign Up".tr, onTap: () => Get.offAll(() => const SignUpScreen())),
        ],
      ),
    ),
  );
}

Widget listHeaderView(String cFirst, String cSecond, String cThird) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      TextRobotoAutoNormal(cFirst),
      TextRobotoAutoNormal(cSecond, textAlign: TextAlign.center),
      TextRobotoAutoNormal(cThird, textAlign: TextAlign.end),
    ],
  );
}

Widget twoTextView(String text, String subText, {Color? subColor}) {
  return Row(
    children: [
      TextRobotoAutoNormal(text, fontSize: Dimens.regularFontSizeSmall),
      Expanded(child: TextRobotoAutoBold(subText, color: subColor, maxLines: 1)),
    ],
  );
}

Widget twoTextSpace(String text, String subText, {Color? subColor, Color? color}) {
  color = color ?? Get.theme.primaryColorLight;
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      TextRobotoAutoBold(text, fontSize: Dimens.regularFontSizeMid, color: color, textAlign: TextAlign.start),
      TextRobotoAutoBold(subText, fontSize: Dimens.regularFontSizeMid, color: subColor, textAlign: TextAlign.end),
    ],
  );
}

class DropDownViewWallets extends StatelessWidget {
  const DropDownViewWallets(this.wallets, this.selectedWallet, {super.key, this.onChange});

  final List<Wallet> wallets;
  final Wallet selectedWallet;
  final Function(Wallet value)? onChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 5, bottom: 5),
      height: 50,
      alignment: Alignment.center,
      child: DropdownButton<Wallet>(
        value: selectedWallet.coinType.isValid ? selectedWallet : null,
        hint: Text("Select".tr, style: context.textTheme.displaySmall),
        icon: Icon(Icons.keyboard_arrow_down_outlined, color: context.theme.primaryColor),
        elevation: 10,
        dropdownColor: context.theme.dialogBackgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        underline: Container(height: 0, color: Colors.transparent),
        menuMaxHeight: context.width,
        onChanged: onChange == null ? null : (value) => onChange!(value!),
        items: wallets.map<DropdownMenuItem<Wallet>>((Wallet value) {
          return DropdownMenuItem<Wallet>(
            value: value,
            child: Text(value.coinType ?? "", style: context.textTheme.labelMedium),
          );
        }).toList(),
      ),
    );
  }
}

Widget dropDownNetworks(List<Network> items, Network selectedValue, String hint,
    {Function(Network value)? onChange, double? viewWidth, double height = 50, bool isEditable = true, Color? bgColor, double? hMargin}) {
  hMargin = hMargin ?? 0;
  viewWidth = viewWidth ?? Get.width;
  return Container(
    margin: EdgeInsets.only(left: hMargin, top: 5, right: hMargin, bottom: 5),
    height: height,
    width: viewWidth,
    alignment: Alignment.center,
    decoration: boxDecorationRoundBorder(color: bgColor),
    child: DropdownButton<Network>(
      value: selectedValue.id == 0 ? null : selectedValue,
      hint: SizedBox(width: (viewWidth - 90), child: Text(hint, style: Get.textTheme.displaySmall)),
      icon: Icon(Icons.keyboard_arrow_down_outlined, color: isEditable ? Get.theme.primaryColor : Colors.transparent),
      elevation: 10,
      dropdownColor: gIsDarkMode ? Get.theme.secondaryHeaderColor : Get.theme.dividerColor,
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      underline: Container(height: 0, color: Colors.transparent),
      menuMaxHeight: Get.width,
      onChanged: (isEditable && onChange != null) ? (value) => onChange(value!) : null,
      items: items.map<DropdownMenuItem<Network>>((Network value) {
        return DropdownMenuItem<Network>(
          value: value,
          child: Text(value.networkName ?? "", style: Get.textTheme.displaySmall!.copyWith(color: Get.theme.primaryColor)),
        );
      }).toList(),
    ),
  );
}

walletsSuffixView(List<Wallet> walletList, Wallet selected, {Function(Wallet value)? onChange, double? width}) {
  return SizedBox(
    width: width ?? Dimens.suffixWide,
    child: Row(
      children: [
        dividerVertical(indent: Dimens.paddingMid),
        hSpacer5(),
        Expanded(child: DropDownViewWallets(walletList, selected, onChange: onChange))
      ],
    ),
  );
}

Widget coinDetailsItemView(String? title, String? subtitle,
    {bool isSwap = false, Color? subColor, String? fromKey, CrossAxisAlignment? crossAlignment}) {
  subColor = subColor ?? Get.theme.primaryColor;
  final mainColor = fromKey.isValid ? (fromKey == FromKey.up ? gBuyColor : gSellColor) : Get.theme.primaryColorLight;
  return Column(
    crossAxisAlignment: crossAlignment ?? CrossAxisAlignment.center,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextRobotoAutoBold(title ?? "", color: mainColor, fontSize: isSwap ? Dimens.regularFontSizeMid : Dimens.regularFontSizeSmall),
          if (fromKey.isValid)
            Icon(fromKey == FromKey.up ? Icons.arrow_upward : Icons.arrow_downward, color: mainColor, size: Dimens.iconSizeMinExtra)
        ],
      ),
      TextRobotoAutoBold((subtitle ?? 0).toString(), color: subColor, fontSize: isSwap ? Dimens.regularFontSizeSmall : Dimens.regularFontSizeMid),
    ],
  );
}

Widget currencyView(BuildContext context, FiatCurrency selectedCurrency, List<FiatCurrency> cList, Function(FiatCurrency) onChange) {
  final text = selectedCurrency.code.isValid ? selectedCurrency.name! : "Select".tr;
  return InkWell(
    onTap: () => chooseCurrencyModal(context, cList, onChange),
    child: SizedBox(
      width: Dimens.suffixWide,
      child: Row(
        children: [
          dividerVertical(indent: Dimens.paddingMid),
          vSpacer5(),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                    child: AutoSizeText(text,
                        style: Get.textTheme.displaySmall?.copyWith(color: Get.theme.primaryColor), maxLines: 2, textAlign: TextAlign.center)),
                Icon(Icons.keyboard_arrow_down, size: Dimens.iconSizeMin, color: Get.theme.primaryColor),
                hSpacer10()
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

void chooseCurrencyModal(BuildContext context, List<FiatCurrency> cList, Function(FiatCurrency) onChange) {
  showBottomSheetFullScreen(
      context,
      Expanded(
        child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(Dimens.paddingMid),
            children: List.generate(cList.length, (index) {
              final currency = cList[index];
              return InkWell(
                onTap: () {
                  onChange(currency);
                  Get.back();
                },
                child: Padding(
                  padding: const EdgeInsets.all(Dimens.paddingMid),
                  child: TextRobotoAutoBold(currency.name ?? ""),
                ),
              );
            })),
      ),
      title: "Select currency".tr,
      isScrollControlled: false);
}

class BankDetailsView extends StatelessWidget {
  const BankDetailsView({super.key, required this.bank});

  final Bank bank;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        vSpacer10(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextRobotoAutoBold("Bank details".tr),
            buttonTextBordered("Copy", true, onPress: () => copyToClipboard(bank.toCopy()), visualDensity: minimumVisualDensity),
          ],
        ),
        vSpacer5(),
        Container(
          decoration: boxDecorationRoundBorder(),
          padding: const EdgeInsets.all(Dimens.paddingMid),
          child: Column(
            children: [
              TwoTextSpaceFixed("AC Number".tr, bank.iban ?? "", subMaxLine: 2, fontSize: Dimens.regularFontSizeExtraMid),
              vSpacer2(),
              TwoTextSpaceFixed("Bank name".tr, bank.bankName ?? "", subMaxLine: 2, fontSize: Dimens.regularFontSizeExtraMid),
              vSpacer2(),
              TwoTextSpaceFixed("Bank address".tr, bank.bankAddress ?? "", subMaxLine: 3, fontSize: Dimens.regularFontSizeExtraMid),
              vSpacer2(),
              TwoTextSpaceFixed("AC holder name".tr, bank.accountHolderName ?? "", flex: 4, subMaxLine: 2, fontSize: Dimens.regularFontSizeExtraMid),
              vSpacer2(),
              TwoTextSpaceFixed("AC holder address".tr, bank.accountHolderAddress ?? "",
                  flex: 4, subMaxLine: 3, fontSize: Dimens.regularFontSizeExtraMid),
              vSpacer2(),
              TwoTextSpaceFixed("Swift code".tr, bank.swiftCode ?? "", subMaxLine: 2, fontSize: Dimens.regularFontSizeExtraMid),
            ],
          ),
        )
      ],
    );
  }
}
