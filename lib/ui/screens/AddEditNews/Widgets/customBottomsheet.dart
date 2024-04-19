// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news/cubits/appLocalizationCubit.dart';
import 'package:news/cubits/categoryCubit.dart';
import 'package:news/cubits/locationCityCubit.dart';
import 'package:news/cubits/updateBottomsheetContentCubit.dart';
import 'package:news/cubits/tagCubit.dart';
import 'package:news/utils/uiUtils.dart';
import 'package:news/ui/widgets/customTextLabel.dart';

class CustomBottomsheet extends StatefulWidget {
  final BuildContext context;
  final String titleTxt;
  final int listLength;
  final NullableIndexedWidgetBuilder listViewChild;

  const CustomBottomsheet({super.key, required this.context, required this.titleTxt, required this.listLength, required this.listViewChild});

  @override
  CustomBottomsheetState createState() => CustomBottomsheetState();
}

class CustomBottomsheetState extends State<CustomBottomsheet> {
  late final ScrollController locationScrollController = ScrollController();
  late final ScrollController languageScrollController = ScrollController();
  late final ScrollController categoryScrollController = ScrollController();
  late final ScrollController subcategoryScrollController = ScrollController();
  late final ScrollController tagScrollController = ScrollController();

  ScrollController scController = ScrollController();
  @override
  void initState() {
    super.initState();

    initScrollController();
  }

  @override
  void dispose() {
    disposeScrollController();
    super.dispose();
  }

  void initScrollController() {
    switch (widget.titleTxt) {
      case 'chooseLanLbl':
        scController = languageScrollController;
        break;
      case 'selCatLbl':
        scController = categoryScrollController;
        break;
      case 'selSubCatLbl':
        scController = subcategoryScrollController;
        break;
      case 'selTagLbl':
        scController = tagScrollController;
        break;
      case 'selLocationLbl':
        scController = locationScrollController;
        break;
    }
    scController.addListener(() => hasMoreLocationScrollListener());
  }

  disposeScrollController() {
    switch (widget.titleTxt) {
      case 'chooseLanLbl':
        languageScrollController.dispose();
        break;
      case 'selCatLbl':
        categoryScrollController.dispose();
        break;
      case 'selSubCatLbl':
        subcategoryScrollController.dispose();
        break;
      case 'selTagLbl':
        tagScrollController.dispose();
        break;
      case 'selLocationLbl':
        locationScrollController.dispose();
        break;
    }
  }

  void hasMoreLocationScrollListener() {
    if (scController.offset >= scController.position.maxScrollExtent && !scController.position.outOfRange) {
      switch (widget.titleTxt) {
        case 'selCatLbl':
          if (context.read<CategoryCubit>().hasMoreCategory()) {
            context.read<CategoryCubit>().getMoreCategory(langId: context.read<AppLocalizationCubit>().state.id);
          }
          break;
        case 'selTagLbl':
          if (context.read<TagCubit>().hasMoreTags()) {
            context.read<TagCubit>().getMoreTags(langId: context.read<AppLocalizationCubit>().state.id);
          }
          break;
        case 'selLocationLbl':
          if (context.read<LocationCityCubit>().hasMoreLocation()) {
            context.read<LocationCityCubit>().getMoreLocationCity();
          }
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
        builder: (BuildContext context) => BlocBuilder<BottomSheetCubit, BottomSheetState>(
              builder: (context, state) {
                int listLength = widget.listLength;
                switch (widget.titleTxt) {
                  case 'selLocationLbl':
                    listLength = state.locationData.length;
                    break;
                  case 'selTagLbl':
                    listLength = state.tagsData.length;
                    break;
                  case 'chooseLanLbl':
                    listLength = state.languageData.length;
                    break;
                }
                return DraggableScrollableSheet(
                    snap: true,
                    snapSizes: const [0.5, 0.9],
                    expand: false,
                    builder: (_, controller) {
                      controller = scController;
                      return Container(
                          padding: const EdgeInsetsDirectional.only(bottom: 15.0, top: 15.0, start: 20.0, end: 20.0),
                          decoration:
                              BoxDecoration(borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)), color: UiUtils.getColorScheme(context).background),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomTextLabel(
                                  text: widget.titleTxt,
                                  textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: UiUtils.getColorScheme(context).primaryContainer)),
                              const SizedBox(height: 10),
                              Expanded(
                                  child: ListView.builder(
                                      controller: controller,
                                      physics: const AlwaysScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      padding: const EdgeInsetsDirectional.only(top: 10.0, bottom: 25.0),
                                      itemCount: listLength,
                                      itemBuilder: widget.listViewChild)),
                            ],
                          ));
                    });
              },
            ));
  }
}
