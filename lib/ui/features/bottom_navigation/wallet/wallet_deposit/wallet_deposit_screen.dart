import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:exbix_flutter/data/local/api_constants.dart';
import 'package:exbix_flutter/data/local/constants.dart';
import 'package:exbix_flutter/data/models/faq.dart';
import 'package:exbix_flutter/data/models/history.dart';
import 'package:exbix_flutter/data/models/wallet.dart';
import 'package:exbix_flutter/helper/app_helper.dart';
import 'package:exbix_flutter/ui/features/side_navigation/faq/faq_page.dart';
import 'package:exbix_flutter/utils/button_util.dart';
import 'package:exbix_flutter/utils/common_utils.dart';
import 'package:exbix_flutter/utils/decorations.dart';
import 'package:exbix_flutter/utils/extentions.dart';
import 'package:exbix_flutter/utils/text_field_util.dart';
import 'package:exbix_flutter/utils/text_util.dart';
import 'package:exbix_flutter/helper/app_widgets.dart';
import 'package:exbix_flutter/utils/appbar_util.dart';
import 'package:exbix_flutter/utils/common_widgets.dart';
import 'package:exbix_flutter/utils/dimens.dart';
import 'package:exbix_flutter/utils/image_util.dart';
import 'package:exbix_flutter/utils/number_util.dart';
import 'package:exbix_flutter/utils/spacers.dart';
import '../../../side_navigation/activity/activity_screen.dart';
import '../wallet_widgets.dart';
import 'wallet_deposit_controller.dart';

class WalletDepositScreen extends StatefulWidget {
  const WalletDepositScreen({super.key, required this.wallet});

  final Wallet wallet;

  @override
  State<WalletDepositScreen> createState() => _WalletDepositScreenState();
}

class _WalletDepositScreenState extends State<WalletDepositScreen> {
  final _controller = Get.put(WalletDepositController());
  Rx<Wallet> walletRx = Wallet(id: 0).obs;
  RxString selectedAddress = "".obs;
  RxString selectedTokenAddress = "".obs;
  RxString selectedMemo = "".obs;
  RxList<Network> networkList = <Network>[].obs;
  RxList<NetworkAddress> addressList = <NetworkAddress>[].obs;
  Rx<Network> selectedNetwork = Network(id: 0).obs;
  RxList<History> historyList = <History>[].obs;
  RxList<FAQ> faqList = <FAQ>[].obs;
  RxInt baseNetworkType = 0.obs;

  @override
  void initState() {
    walletRx.value = widget.wallet;
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => _controller.getWalletDeposit(widget.wallet.id, (value) {
          _setViewData(value);
          _controller.getHistoryListData(HistoryType.deposit, (list) => historyList.value = list);
          _controller.getFAQList(FAQType.deposit, (list) => faqList.value = list);
        }));
  }

  @override
  Widget build(BuildContext context) {
    final eColor = context.theme.colorScheme.error;
    return Scaffold(
        appBar: appBarBackWithActions(
            title: "Deposit".tr,
            actionIcons: [Icons.history],
            onPress: (i) {
              TemporaryData.activityType = HistoryType.deposit;
              Get.to(() => const ActivityScreen());
            }),
        body: SafeArea(
            child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(Dimens.paddingMid),
          children: [
            Padding(
              padding: const EdgeInsets.all(Dimens.paddingMid),
              child: WalletNameView(wallet: walletRx.value),
            ),
            Obx(() => WalletBalanceViewWithBg(balance: walletRx.value.balance)),
            vSpacer10(),
            Container(
              padding: const EdgeInsets.all(Dimens.paddingMid),
              decoration: boxDecorationRoundCorner(),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      showImageAsset(icon: Icons.warning_outlined, iconSize: Dimens.iconSizeMin, color: eColor),
                      hSpacer5(),
                      TextRobotoAutoBold("Warning".tr, color: eColor, fontSize: Dimens.regularFontSizeLarge),
                    ],
                  ),
                  vSpacer5(),
                  TextRobotoAutoNormal("Sending_any_other_asset_message".trParams({"coinName": walletRx.value.coinType ?? ""}),
                      maxLines: 5, color: eColor),
                  _memoView(),
                  _networkView(),
                  vSpacer10(),
                  _addressView(),
                ],
              ),
            ),
            vSpacer20(),
            _historyListView(),
            Obx(() => FAQRelatedView(faqList.toList())),
          ],
        )));
  }

  void _setViewData(WalletDeposit dData) {
    if (dData.wallet != null) walletRx.value = dData.wallet!;
    if (dData.memo.isValid) selectedMemo.value = dData.memo!;

    if (getSettingsLocal()?.isEvmWallet ?? false) {
      baseNetworkType.value = makeInt(dData.data[APIKeyConstants.baseType]);
      if (dData.data != null && dData.data is Map) {
        final nList = dData.data[APIKeyConstants.networks] ?? dData.data[APIKeyConstants.coinPaymentNetworks] ?? [];
        networkList.value = List<Network>.from(nList.map((x) => Network.fromJson(x)));
      }
      if ([NetworkType.trc20Token, NetworkType.evmBaseCoin, NetworkType.evmSolana].contains(baseNetworkType.value)) {
        final aList = dData.data[APIKeyConstants.address] ?? [];
        addressList.value = List<NetworkAddress>.from(aList.map((x) => NetworkAddress.fromJson(x)));
      } else {
        if (networkList.isNotEmpty) {
          final net = networkList.firstWhereOrNull((element) => element.id == walletRx.value.network);
          if (net != null) selectedNetwork.value = net;
          selectedAddress.value = selectedNetwork.value.address ?? "";
        } else {
          final aList = dData.data[APIKeyConstants.address] ?? [];
          final adList = List<NetworkAddress>.from(aList.map((x) => NetworkAddress.fromJson(x)));
          if (adList.isNotEmpty) {
            selectedAddress.value = adList.first.address ?? "";
            selectedTokenAddress.value = adList.first.tokenAddress ?? "";
          }
        }
      }
    } else {
      if (dData.address.isValid) selectedAddress.value = dData.address!;

      if (dData.data != null && dData.data is List) {
        networkList.value = List<Network>.from(dData.data.map((x) => Network.fromJson(x)));
      }
      if (selectedAddress.value.isEmpty && networkList.isNotEmpty) {
        final net = networkList.firstWhereOrNull((element) => element.id == walletRx.value.network);
        if (net != null) selectedNetwork.value = net;
        selectedAddress.value = selectedNetwork.value.address ?? "";
      }
    }
  }

  Widget _memoView() {
    return Obx(() => selectedMemo.isNotEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              vSpacer10(),
              TextRobotoAutoBold("Memo".tr),
              vSpacer5(),
              textFieldWithSuffixIcon(controller: TextEditingController(text: selectedMemo.value), isEnable: false)
            ],
          )
        : vSpacer0());
  }

  Widget _networkView() {
    return Obx(() => networkList.isNotEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              vSpacer10(),
              TextRobotoAutoBold("Select Network".tr),
              vSpacer5(),
              dropDownNetworks(networkList, selectedNetwork.value, "Select".tr, onChange: (value) {
                selectedNetwork.value = value;
                if ([NetworkType.trc20Token, NetworkType.evmBaseCoin, NetworkType.evmSolana].contains(baseNetworkType.value)) {
                  final address = addressList.firstWhere((element) => element.networkId == selectedNetwork.value.id);
                  selectedAddress.value = address.address ?? "";
                  selectedTokenAddress.value = address.tokenAddress ?? "";
                } else {
                  selectedAddress.value = selectedNetwork.value.address ?? "";
                }
              })
            ],
          )
        : vSpacer0());
  }

  //6,8,10

  _addressView() {
    return Obx(() {
      if ([NetworkType.trc20Token, NetworkType.evmBaseCoin, NetworkType.evmSolana].contains(baseNetworkType.value) && selectedNetwork.value.id == 0) {
        return vSpacer0();
      } else {
        return Container(
          width: context.width,
          padding: const EdgeInsets.all(Dimens.paddingMid),
          decoration: boxDecorationRoundBorder(),
          child: selectedAddress.value.isNotEmpty
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextRobotoAutoBold("Deposit Address".tr),
                    vSpacer10(),
                    Align(alignment: Alignment.center, child: qrView(selectedAddress.value)),
                    vSpacer20(),
                    textWithCopyButton(selectedAddress.value),
                    if ([NetworkType.trc20Token, NetworkType.evmBaseCoin, NetworkType.evmSolana].contains(baseNetworkType.value) &&
                        selectedTokenAddress.isNotEmpty)
                      Column(
                        children: [
                          dividerHorizontal(height: Dimens.paddingLargeExtra),
                          Theme(
                            data: context.theme.copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              title: TextRobotoAutoBold("Display Contract Address".tr),
                              backgroundColor: Colors.transparent,
                              collapsedIconColor: context.theme.primaryColor,
                              iconColor: context.theme.primaryColor,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingMid),
                                  child: textWithCopyButton(selectedTokenAddress.value),
                                )
                              ],
                            ),
                          ),
                        ],
                      )
                  ],
                )
              : Column(
                  children: [
                    TextRobotoAutoNormal("Address not found".tr, fontSize: Dimens.regularFontSizeMid),
                    selectedNetwork.value.id != 0
                        ? Column(children: [
                            vSpacer20(),
                            buttonRoundedMain(text: "Get Address".tr, onPress: () => _getNetworkAddress(), buttonHeight: Dimens.btnHeightMid)
                          ])
                        : vSpacer0()
                  ],
                ),
        );
      }
    });
  }

  void _getNetworkAddress() {
    if ([NetworkType.trc20Token, NetworkType.evmBaseCoin, NetworkType.evmSolana].contains(baseNetworkType.value)) {
      _controller.createNetworkAddress(selectedNetwork.value, walletRx.value.coinType ?? "", (address) {
        selectedNetwork.value.address = address;
        addressList.add(NetworkAddress(networkId: selectedNetwork.value.id, address: address));
        selectedAddress.value = address ?? "";
      });
    } else {
      _controller.walletNetworkAddress(selectedNetwork.value, (address) {
        selectedNetwork.value.address = address;
        selectedAddress.value = address ?? "";
      });
    }
  }

  _historyListView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextRobotoAutoBold("Recent Deposits".tr),
        Obx(() => historyList.isEmpty
            ? showEmptyView(height: 50)
            : Column(
                children: List.generate(historyList.length, (index) {
                  return WalletRecentTransactionItemView(history: historyList[index], type: HistoryType.deposit);
                }),
              ))
      ],
    );
  }
}

// void _setViewData(WalletDeposit dData) {
//   if (dData.wallet != null) walletRx.value = dData.wallet!;
//   if (dData.address.isValid) selectedAddress.value = dData.address!;
//   if (dData.memo.isValid) selectedMemo.value = dData.memo!;
//
//   if (getSettingsLocal()?.isEvmWallet ?? false) {
//     baseNetworkType.value = makeInt(dData.data[APIKeyConstants.baseType]);
//     if (dData.data != null && dData.data is Map) {
//       final nList = dData.data[APIKeyConstants.networks] ?? dData.data[APIKeyConstants.coinPaymentNetworks] ?? [];
//       networkList.value = List<Network>.from(nList.map((x) => Network.fromJson(x)));
//     }
//     if ([NetworkType.trc20Token, NetworkType.evmBaseCoin].contains(baseNetworkType.value)) {
//       final aList = dData.data[APIKeyConstants.address] ?? [];
//       addressList.value = List<NetworkAddress>.from(aList.map((x) => NetworkAddress.fromJson(x)));
//     } else {
//       if (selectedAddress.value.isEmpty && networkList.isNotEmpty) {
//         final net = networkList.firstWhereOrNull((element) => element.id == walletRx.value.network);
//         if (net != null) selectedNetwork.value = net;
//         selectedAddress.value = selectedNetwork.value.address ?? "";
//       }
//     }
//   } else {
//     if (dData.data != null && dData.data is List) {
//       networkList.value = List<Network>.from(dData.data.map((x) => Network.fromJson(x)));
//     }
//     if (selectedAddress.value.isEmpty && networkList.isNotEmpty) {
//       final net = networkList.firstWhereOrNull((element) => element.id == walletRx.value.network);
//       if (net != null) selectedNetwork.value = net;
//       selectedAddress.value = selectedNetwork.value.address ?? "";
//     }
//   }
// }

// Widget _networkView() {
//   return Obx(() => Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           vSpacer10(),
//           textAutoSizeKarla(networkList.isNotEmpty ? "Select Network".tr : "Network Name".tr,
//               fontSize: Dimens.regularFontSizeMid, textAlign: TextAlign.start),
//           vSpacer5(),
//           if (networkList.isNotEmpty)
//             dropDownNetworks(networkList, selectedNetwork.value, "Select".tr, onChange: (value) {
//               selectedNetwork.value = value;
//               if ([NetworkType.trc20Token, NetworkType.evmBaseCoin].contains(baseNetworkType.value)) {
//                 selectedAddress.value = addressList.firstWhereOrNull((element) => element.networkId == selectedNetwork.value.id)?.address ?? "";
//               } else {
//                 selectedAddress.value = selectedNetwork.value.address ?? "";
//               }
//             })
//           else
//             Container(
//               height: 50,
//               alignment: Alignment.centerLeft,
//               width: context.width,
//               padding: const EdgeInsets.all(10),
//               decoration: boxDecorationRoundBorder(),
//               child: textAutoSizeKarla(walletRx.value.networkName ?? "", fontSize: Dimens.regularFontSizeMid, textAlign: TextAlign.start),
//             )
//         ],
//       ));
// }
