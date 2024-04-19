// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:news/utils/uiUtils.dart';

class CustomNetworkImage extends StatelessWidget {
  final String networkImageUrl;
  final double? width, height;
  final BoxFit? fit;
  final bool? isVideo;
  final Widget? errorBuilder;

  const CustomNetworkImage({super.key, required this.networkImageUrl, this.width, this.height, this.fit, this.isVideo, this.errorBuilder});

  @override
  Widget build(BuildContext context) {
    return FadeInImage.assetNetwork(
        fadeInDuration: const Duration(milliseconds: 150),
        fadeOutCurve: Curves.bounceOut,
        image: networkImageUrl,
        width: width ?? 100,
        height: height ?? 100,
        fit: fit ?? BoxFit.cover,
        imageErrorBuilder: (context, error, stackTrace) {
          return SvgPicture.asset(
              bundle: DefaultAssetBundle.of(context),
              UiUtils.getSvgImagePath((isVideo!) ? "placeholder_video" : "placeholder"),
              width: width ?? 100,
              height: height ?? 100,
              fit: fit ?? BoxFit.contain);
        },
        placeholderErrorBuilder: (context, error, stackTrace) {
          return SvgPicture.asset(
              bundle: DefaultAssetBundle.of(context),
              UiUtils.getSvgImagePath((isVideo!) ? "placeholder_video" : "placeholder"),
              width: width ?? 100,
              height: height ?? 100,
              fit: fit ?? BoxFit.contain);
        },
        placeholderFit: BoxFit.cover,
        placeholder: UiUtils.getSvgImagePath((isVideo!) ? "placeholder_video" : "placeholder"));
  }
}
