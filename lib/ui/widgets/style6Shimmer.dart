// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

style6Shimmer(BuildContext context) {
  return Shimmer.fromColors(
      baseColor: Colors.grey.withOpacity(0.6),
      highlightColor: Colors.grey,
      child: SizedBox(
        height: MediaQuery.of(context).size.height / 2.8,
        child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsetsDirectional.only(top: 15.0),
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (_, i) =>
                    Container(margin: const EdgeInsets.all(5), decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: Colors.grey.withOpacity(0.6)), height: 150, width: 160),
                itemCount: 6)),
      ));
}
