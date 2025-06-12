import 'package:get/get.dart';
import 'package:exbix_flutter/data/local/api_constants.dart';
import 'package:exbix_flutter/data/models/blog_news.dart';
import 'package:exbix_flutter/data/models/settings.dart';
import 'package:exbix_flutter/data/remote/api_repository.dart';
import 'package:exbix_flutter/utils/common_utils.dart';

class LandingController extends GetxController {
  Rx<LandingData> landingData = LandingData().obs;
  RxBool isLoading = false.obs;
  RxInt selectedTab = 0.obs;
  RxList<Blog> latestBlogList = <Blog>[].obs;

  void getLandingSettings() async {
    isLoading.value = true;
    APIRepository().getCommonSettings().then((resp) {
      isLoading.value = false;
      if (resp.success && resp.data != null && resp.data is Map<String, dynamic>) {
        final settings = resp.data[APIKeyConstants.landingSettings];
        if (settings != null && settings is Map<String, dynamic>) {
          landingData.value = LandingData.fromJson(settings);
        }
      }
    }, onError: (err) {
      isLoading.value = false;
      showToast(err.toString());
    });
  }

  void getLatestBlogList() async {
    APIRepository().getLatestBlogList().then((resp) {
      if (resp.success && resp.data != null) {
        latestBlogList.value = List<Blog>.from(resp.data.map((x) => Blog.fromJson(x)));
      }
    }, onError: (err) {
      showToast(err.toString());
    });
  }

}
