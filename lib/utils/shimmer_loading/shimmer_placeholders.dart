import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BannerPlaceholder extends StatelessWidget {
  const BannerPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200.0,
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.0), color: Colors.white),
    );
  }
}

class TitlePlaceholder extends StatelessWidget {
  final double width;

  const TitlePlaceholder({super.key, required this.width});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: width, height: 12.0, color: Colors.white),
          const SizedBox(height: 8.0),
          Container(width: width, height: 12.0, color: Colors.white),
        ],
      ),
    );
  }
}

class SliderPlaceholder extends StatelessWidget {
  const SliderPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final width = (context.width - 60) / 2;
    final height = width / 2;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(width: height, height: height, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.0), color: Colors.white)),
          const SizedBox(width: 15),
          Container(width: width, height: height, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.0), color: Colors.white)),
          const SizedBox(width: 15),
          Container(width: height, height: height, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.0), color: Colors.white)),
        ],
      ),
    );
  }
}

enum ContentLineType { twoLines, threeLines }

class ContentPlaceholder extends StatelessWidget {
  final ContentLineType lineType;

  const ContentPlaceholder({
    super.key,
    required this.lineType,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(width: 96.0, height: 72.0, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.0), color: Colors.white)),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: double.infinity, height: 10.0, color: Colors.white, margin: const EdgeInsets.only(bottom: 8.0)),
                if (lineType == ContentLineType.threeLines)
                  Container(width: double.infinity, height: 10.0, color: Colors.white, margin: const EdgeInsets.only(bottom: 8.0)),
                Container(width: 100.0, height: 10.0, color: Colors.white)
              ],
            ),
          )
        ],
      ),
    );
  }
}
