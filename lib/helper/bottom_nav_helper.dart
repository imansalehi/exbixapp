import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:exbix_flutter/data/local/constants.dart';
import 'package:exbix_flutter/helper/app_helper.dart';

class AppBottomNav {
  AppBottomNav({required this.id, required this.icon, this.name});

  int id;
  IconData icon;
  String? name;
}

class AppBottomNavHelper {
  static List<AppBottomNav> getBottomNavList() {
    final List<AppBottomNav> list = [];
    list.add(AppBottomNav(id: AppBottomNavKey.home, icon: Icons.home, name: "Home".tr));
    list.add(AppBottomNav(id: AppBottomNavKey.market, icon: Icons.bar_chart, name: "Markets".tr));
    list.add(AppBottomNav(id: AppBottomNavKey.trade, icon: Icons.wifi_protected_setup, name: "Trade".tr));
    if (getSettingsLocal()?.enableFutureTrade == 1) list.add(AppBottomNav(id: AppBottomNavKey.future, icon: Icons.launch, name: "Futures".tr));
    list.add(AppBottomNav(id: AppBottomNavKey.wallet, icon: Icons.account_balance_wallet, name: "Wallets".tr));

    return list;
  }

  static int getNavIndex(int key) {
    return getBottomNavList().indexWhere((element) => element.id == key);
  }
}
