// ignore_for_file: file_names, library_private_types_in_public_api, use_build_context_synchronously, must_be_immutable

import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:news/cubits/AddNewsCubit.dart';
import 'package:news/cubits/appSystemSettingCubit.dart';
import 'package:news/cubits/deleteImageId.dart';
import 'package:news/cubits/getUserNewsCubit.dart';
import 'package:news/cubits/languageCubit.dart';
import 'package:news/cubits/locationCityCubit.dart';
import 'package:news/cubits/slugCheckCubit.dart';
import 'package:news/cubits/tagCubit.dart';
import 'package:news/cubits/appLocalizationCubit.dart';
import 'package:news/cubits/categoryCubit.dart';
import 'package:news/app/routes.dart';
import 'package:news/cubits/updateBottomsheetContentCubit.dart';
import 'package:news/data/models/TagModel.dart';
import 'package:news/data/models/CategoryModel.dart';
import 'package:news/data/models/NewsModel.dart';
import 'package:news/data/models/appLanguageModel.dart';
import 'package:news/data/models/locationCityModel.dart';
import 'package:news/data/repositories/Settings/settingsLocalDataRepository.dart';
import 'package:news/ui/screens/AddEditNews/Widgets/customBottomsheet.dart';
import 'package:news/ui/styles/colors.dart';
import 'package:news/ui/widgets/SnackBarWidget.dart';
import 'package:news/ui/widgets/customTextLabel.dart';
import 'package:news/ui/widgets/networkImage.dart';
import 'package:news/ui/widgets/showUploadImageBottomsheet.dart';
import 'package:news/ui/widgets/circularProgressIndicator.dart';
import 'package:news/ui/screens/NewsDescription.dart';
import 'package:news/utils/internetConnectivity.dart';
import 'package:news/utils/uiUtils.dart';
import 'package:news/utils/validators.dart';

class AddNews extends StatefulWidget {
  NewsModel? model;
  bool isEdit;
  String from;
  AddNews({super.key, this.model, required this.isEdit, required this.from});

  @override
  _AddNewsState createState() => _AddNewsState();

  static Route route(RouteSettings routeSettings) {
    final arguments = routeSettings.arguments as Map<String, dynamic>;
    return CupertinoPageRoute(builder: (_) => AddNews(model: arguments['model'], isEdit: arguments['isEdit'], from: arguments['from']));
  }
}

class _AddNewsState extends State<AddNews> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  String catSel = "", subCatSel = "", conType = "", conTypeId = "standard_post", langId = "", langName = "", locationSel = "";
  String? title, catSelId, subSelId, showTill, url, desc, locationSelId, metaKeyword, metaDescription, metaTitle, slug;
  int? catIndex, locationIndex;
  List<String> tagsName = [], tagsId = [];
  Map<String, String> contentType = {};
  List<File> otherImage = [];
  File? image, videoUpload;
  bool isNext = false, isDescLoading = true, isMetaKeyword = false, isMetaDescription = false, isMetaTitle = false, isSlug = false;
  TextEditingController titleC = TextEditingController(),
      urlC = TextEditingController(),
      metaTitleC = TextEditingController(),
      metaDescriptionC = TextEditingController(),
      metaKeywordC = TextEditingController(),
      slugC = TextEditingController();
  List<CategoryModel> categories = [];
  List<LocationCityModel> locationCities = [];

  clearText() {
    setState(() {
      catSel = "";
      subCatSel = "";
      locationSel = "";
      conType = UiUtils.getTranslatedLabel(context, 'stdPostLbl');
      title = catSelId = subSelId = showTill = url = catIndex = locationSelId = locationIndex = image = videoUpload = desc = null;
      conTypeId = 'standard_post';
      tagsName = tagsId = [];
      otherImage = [];
      isNext = false;
      titleC.clear();
      urlC.clear();
      metaTitleC.clear();
      metaDescriptionC.clear();
      metaKeywordC.clear();
      slugC.clear();
    });
  }

  setContentType() {
    contentType = {
      "standard_post": UiUtils.getTranslatedLabel(context, 'stdPostLbl'),
      "video_youtube": UiUtils.getTranslatedLabel(context, 'videoYoutubeLbl'),
      "video_other": UiUtils.getTranslatedLabel(context, 'videoOtherUrlLbl'),
      "video_upload": UiUtils.getTranslatedLabel(context, 'videoUploadLbl'),
    };
  }

  addDataFromModel() {
    if (widget.model != null) {
      Future.delayed(Duration.zero, () {
        setState(() {
          setContentType();
          titleC.text = widget.model!.title!;
          title = widget.model!.title!;
          catSel = widget.model!.categoryName!;
          catSelId = widget.model!.categoryId!;
          subCatSel = widget.model!.subCatName!;
          subSelId = widget.model!.subCatId!;
          langId = widget.model!.langId!;
          for (final entry in contentType.entries) {
            if (entry.key == widget.model!.contentType!) {
              conType = entry.value;
              conTypeId = entry.key;
            }
          }
          if (conTypeId == "video_youtube" || conTypeId == "video_other" || conTypeId == "video_upload") urlC.text = widget.model!.contentValue!;
          if (widget.model!.tagName! != "") tagsName = widget.model!.tagName!.split(',');
          if (widget.model!.tagId! != "") tagsId = widget.model!.tagId!.split(",");
          if (widget.model!.showTill != "0000-00-00") showTill = widget.model!.showTill!;
          desc = widget.model!.desc!;
          metaTitleC.text = metaTitle = widget.model!.metaTitle!;
          metaDescriptionC.text = metaDescription = widget.model!.metaDescription!;
          metaKeywordC.text = metaKeyword = widget.model!.metaKeyword!;
          slugC.text = slug = widget.model!.slug!;
          locationSelId = widget.model!.locationId;
          locationSel = widget.model!.locationName!;
        });
      });
    }
  }

  @override
  void initState() {
    getStandardPostLabel();
    getCategory();
    getTag();
    getLanguageData();
    if (context.read<AppConfigurationCubit>().getLocationWiseNewsMode() == "1") getLocationCities();
    if (widget.isEdit) addDataFromModel();
    super.initState();
  }

  @override
  void dispose() {
    titleC.dispose();
    urlC.dispose();
    metaTitleC.dispose();
    metaDescriptionC.dispose();
    metaKeywordC.dispose();
    slugC.dispose();

    super.dispose();
  }

  Future<void> getStandardPostLabel() async {
    conType = UiUtils.getTranslatedLabel(context, 'stdPostLbl');
    setState(() {});
  }

  Future getLanguageData() async {
    Future.delayed(Duration.zero, () {
      if (widget.isEdit) {
        context.read<LanguageCubit>().getLanguage().then((value) {
          for (int i = 0; i < value.length; i++) {
            if (widget.model!.langId! == value[i].id) {
              setState(() => langName = value[i].language!);
            }
          }
        });
      } else {
        context.read<LanguageCubit>().getLanguage();
      }
    });
  }

  void getCategory({String? languageId}) {
    Future.delayed(Duration.zero, () {
      context.read<CategoryCubit>().getCategory(langId: languageId ?? (context.read<AppLocalizationCubit>().state.id));
    });
  }

  void getTag({String? languageId}) {
    Future.delayed(Duration.zero, () {
      context.read<TagCubit>().getTags(langId: languageId ?? (context.read<AppLocalizationCubit>().state.id));
    });
  }

  void getLocationCities() {
    Future.delayed(Duration.zero, () {
      context.read<LocationCityCubit>().getLocationCity();
    });
  }

  getAppBar() {
    if (!isNext) {
      return PreferredSize(
          preferredSize: const Size(double.infinity, 45),
          child: AppBar(
            centerTitle: false,
            backgroundColor: Colors.transparent,
            title: Transform(
                transform: Matrix4.translationValues(-20.0, 0.0, 0.0),
                child: CustomTextLabel(
                    text: (widget.isEdit) ? 'editNewsLbl' : 'createNewsLbl',
                    textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer, fontWeight: FontWeight.w600, letterSpacing: 0.5))),
            leading: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: InkWell(
                  onTap: () {
                    if (!isNext) {
                      Navigator.of(context).pop();
                    } else {
                      setState(() => isNext = false);
                    }
                  },
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: Icon(Icons.arrow_back, color: UiUtils.getColorScheme(context).primaryContainer)),
            ),
            actions: [
              Container(
                  padding: const EdgeInsetsDirectional.only(end: 20),
                  alignment: Alignment.center,
                  child: CustomTextLabel(text: 'step1Of2Lbl', textStyle: Theme.of(context).textTheme.bodySmall!.copyWith(color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.6))))
            ],
          ));
    }
  }

  showLanguageModalBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return CustomBottomsheet(
              context: context,
              titleTxt: 'chooseLanLbl',
              listLength: context.read<LanguageCubit>().langList().length,
              listViewChild: (context, index) {
                return langListItem(index, context.read<LanguageCubit>().langList());
              });
        });
  }

  Widget languageSelName() {
    return BlocConsumer<LanguageCubit, LanguageState>(
      listener: (context, state) {
        if (langId != "" || (widget.isEdit && widget.model!.langId != null)) locationIndex = context.read<LanguageCubit>().getLanguageIndex(langName: langName);
        if (state is LanguageFetchSuccess) {
          context.read<BottomSheetCubit>().updateLanguageContent(state.language);
        }
      },
      builder: (context, state) {
        if (state is LanguageFetchSuccess && state.language.isNotEmpty) {
          return Padding(
            padding: const EdgeInsets.only(top: 18.0),
            child: InkWell(
                onTap: () => showLanguageModalBottomSheet(context),
                child: UiUtils.setRowWithContainer(
                    context: context,
                    firstChild: CustomTextLabel(
                        text: langName == "" ? 'chooseLanLbl' : langName,
                        textStyle: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(color: langName == "" ? UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.6) : UiUtils.getColorScheme(context).primaryContainer)),
                    isContentTypeUpload: false)),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget catSelectionName() {
    if (langId.isNotEmpty) {
      return BlocConsumer<CategoryCubit, CategoryState>(
        listener: (context, state) {
          if (catSel != "" || (widget.isEdit && widget.model!.categoryName != null)) catIndex = context.read<CategoryCubit>().getCategoryIndex(categoryName: catSel);
        },
        builder: (context, state) {
          if (state is CategoryFetchSuccess) {
            if (state.category.isNotEmpty && state.category.length == 1) catSelId = state.category.first.id;
            if (state.category.isNotEmpty && state.category.length == 1) catIndex = 0;
            if (widget.isEdit) catIndex = context.read<CategoryCubit>().getCatList().indexWhere((element) => element.id == widget.model!.categoryId!);

            return Padding(
              padding: const EdgeInsets.only(top: 18.0),
              child: InkWell(
                onTap: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (BuildContext context) {
                      return CustomBottomsheet(
                          context: context,
                          titleTxt: 'selCatLbl',
                          listLength: context.read<CategoryCubit>().getCatList().length,
                          listViewChild: (context, index) {
                            return catListItem(index, context.read<CategoryCubit>().getCatList());
                          });
                    }),
                child: UiUtils.setRowWithContainer(
                    context: context,
                    firstChild: CustomTextLabel(
                        text: (state.category.length == 1)
                            ? catSel = state.category.first.categoryName!
                            : (catSel == "")
                                ? 'catLbl'
                                : catSel,
                        textStyle: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(color: catSel == "" ? UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.6) : UiUtils.getColorScheme(context).primaryContainer)),
                    isContentTypeUpload: false),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget subCatSelectionName() {
    if ((subCatSel != "" && widget.isEdit) ||
        (catIndex != null) && (!catIndex!.isNegative && context.read<CategoryCubit>().getCatList().isNotEmpty) && (context.read<CategoryCubit>().getCatList()[catIndex!].subData!.isNotEmpty)) {
      return BlocBuilder<CategoryCubit, CategoryState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.only(top: 18.0),
            child: InkWell(
              onTap: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (BuildContext context) {
                    return CustomBottomsheet(
                        context: context,
                        titleTxt: 'selSubCatLbl',
                        listLength: context.read<CategoryCubit>().getCatList()[catIndex!].subData!.length,
                        listViewChild: (context, index) => subCatListItem(index, context.read<CategoryCubit>().getCatList()));
                  }),
              child: UiUtils.setRowWithContainer(
                  context: context,
                  firstChild: CustomTextLabel(
                      text: (subCatSel == "") ? 'subcatLbl' : subCatSel,
                      textStyle: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(color: subCatSel == "" ? UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.6) : UiUtils.getColorScheme(context).primaryContainer)),
                  isContentTypeUpload: false),
            ),
          );
        },
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget contentTypeSelName() {
    return Padding(
      padding: const EdgeInsets.only(top: 18.0),
      child: InkWell(
        onTap: () => contentTypeBottomSheet(),
        child: UiUtils.setRowWithContainer(
            context: context,
            firstChild: CustomTextLabel(
                text: conType == "" ? 'contentTypeLbl' : conType,
                textStyle: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(color: conType == "" ? UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.6) : UiUtils.getColorScheme(context).primaryContainer)),
            isContentTypeUpload: false),
      ),
    );
  }

  Widget contentVideoUpload() {
    return conType == UiUtils.getTranslatedLabel(context, 'videoUploadLbl')
        ? Padding(
            padding: const EdgeInsets.only(top: 18.0),
            child: InkWell(
                splashColor: Colors.transparent,
                onTap: () => _getFromGalleryVideo(),
                child: UiUtils.setRowWithContainer(
                    context: context,
                    firstChild: Expanded(
                        child: CustomTextLabel(
                            text: videoUpload == null ? 'uploadVideoLbl' : videoUpload!.path.split('/').last,
                            maxLines: 2,
                            softWrap: true,
                            textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                                overflow: TextOverflow.ellipsis,
                                color: videoUpload == null ? UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.6) : UiUtils.getColorScheme(context).primaryContainer))),
                    isContentTypeUpload: true)),
          )
        : const SizedBox.shrink();
  }

  Widget contentUrlForVideoUpload() {
    if (conTypeId == "video_upload" && videoUpload == null && urlC.text.isNotEmpty) {
      return Container(
          width: double.maxFinite,
          margin: const EdgeInsetsDirectional.only(top: 18),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0), color: UiUtils.getColorScheme(context).background),
          child: InkWell(
            onTap: () async {
              //open url in newsVideo screen
              Navigator.of(context).pushNamed(Routes.newsVideo, arguments: {"from": 1, "model": widget.model});
            },
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 25,
              children: [
                const Icon(Icons.play_circle_fill),
                CustomTextLabel(
                    text: 'previewLbl',
                    maxLines: 3,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer))
              ],
            ),
          ));
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget contentUrlSet() {
    if (conType == UiUtils.getTranslatedLabel(context, 'videoYoutubeLbl') || conType == UiUtils.getTranslatedLabel(context, 'videoOtherUrlLbl')) {
      return Container(
          width: double.maxFinite,
          margin: const EdgeInsetsDirectional.only(top: 18),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0), color: UiUtils.getColorScheme(context).background),
          child: TextFormField(
            textInputAction: TextInputAction.next,
            maxLines: 1,
            controller: urlC,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer),
            validator: (val) => conType == UiUtils.getTranslatedLabel(context, 'videoYoutubeLbl') ? Validators.youtubeUrlValidation(val!, context) : Validators.urlValidation(val!, context),
            onChanged: (String value) => setState(() => url = value),
            onTapOutside: (val) => FocusScope.of(context).unfocus(),
            decoration: InputDecoration(
                hintText: conType == UiUtils.getTranslatedLabel(context, 'videoYoutubeLbl') ? UiUtils.getTranslatedLabel(context, 'youtubeUrlLbl') : UiUtils.getTranslatedLabel(context, 'otherUrlLbl'),
                hintStyle: Theme.of(context).textTheme.titleMedium?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.6)),
                filled: true,
                fillColor: UiUtils.getColorScheme(context).background,
                contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 17),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(10.0)),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(10.0))),
          ));
    } else {
      return const SizedBox.shrink();
    }
  }

  contentTypeBottomSheet() {
    showModalBottomSheet<dynamic>(
        context: context,
        elevation: 3.0,
        isScrollControlled: true,
        //it will be closed only when user click On Save button & not by clicking anywhere else in screen
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30))),
        enableDrag: false,
        builder: (BuildContext context) => Container(
            padding: const EdgeInsetsDirectional.only(bottom: 15.0, top: 15.0, start: 20.0, end: 20.0),
            decoration: BoxDecoration(borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)), color: UiUtils.getColorScheme(context).background),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextLabel(
                    text: 'selContentTypeLbl', textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: UiUtils.getColorScheme(context).primaryContainer)),
                Padding(
                    padding: const EdgeInsetsDirectional.only(top: 10.0, bottom: 15.0),
                    child: Column(
                        children: contentType.entries.map((entry) {
                      return UiUtils.setTopPaddingParent(
                          childWidget: InkWell(
                              onTap: () {
                                if (conType != entry.value || conTypeId != entry.key) {
                                  urlC.clear();
                                  conType = entry.value;
                                  conTypeId = entry.key;
                                }
                                if (widget.isEdit && conTypeId == widget.model!.contentType) {
                                  urlC.text = widget.model!.contentValue!;
                                }
                                setState(() {});
                                Navigator.pop(context);
                              },
                              child: UiUtils.setBottomsheetContainer(listItem: entry.value, compareTo: conType, context: context)));
                    }).toList()))
              ],
            )));
  }

  Widget newsTitleName() {
    return Container(
        width: double.maxFinite,
        margin: const EdgeInsetsDirectional.only(top: 7),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0), color: UiUtils.getColorScheme(context).background),
        child: TextFormField(
            textInputAction: TextInputAction.next,
            maxLines: 1,
            controller: titleC,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer),
            validator: (val) => Validators.titleValidation(val!, context),
            onChanged: (String value) => setState(() => title = value),
            onTapOutside: (val) => FocusScope.of(context).unfocus(),
            decoration: InputDecoration(
                hintText: UiUtils.getTranslatedLabel(context, 'titleLbl'),
                hintStyle: Theme.of(context).textTheme.titleMedium?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.6)),
                filled: true,
                fillColor: UiUtils.getColorScheme(context).background,
                contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 17),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(10.0)),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(10.0)))));
  }

  Widget tagSelectionName() {
    return BlocConsumer<TagCubit, TagState>(listener: (context, state) {
      if (state is TagFetchSuccess) {
        context.read<BottomSheetCubit>().updateTagsContent(state.tag);
      }
    }, builder: (context, state) {
      if ((state is TagFetchSuccess && state.total > 0) || (widget.isEdit && tagsName.isNotEmpty)) {
        return Padding(
          padding: const EdgeInsets.only(top: 18.0),
          child: InkWell(
            onTap: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (BuildContext context) {
                  return CustomBottomsheet(
                      context: context, titleTxt: 'selTagLbl', listLength: (state as TagFetchSuccess).tag.length, listViewChild: (context, index) => tagListItem(index, state.tag));
                }),
            child: Container(
              width: double.maxFinite,
              constraints: const BoxConstraints(minHeight: 55),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 7),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0), color: UiUtils.getColorScheme(context).background),
              child: tagsId.isEmpty
                  ? CustomTextLabel(text: 'tagLbl', textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.6)))
                  : SizedBox(
                      height: MediaQuery.of(context).size.height * 0.06,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: tagsName.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsetsDirectional.only(start: index != 0 ? 10.0 : 0),
                            child: Stack(
                              children: [
                                Container(
                                  margin: const EdgeInsetsDirectional.only(end: 7.5, top: 7.5),
                                  padding: const EdgeInsetsDirectional.all(7.0),
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.0), color: UiUtils.getColorScheme(context).primaryContainer),
                                  alignment: Alignment.center,
                                  child: CustomTextLabel(text: tagsName[index], textStyle: Theme.of(context).textTheme.titleSmall!.copyWith(color: UiUtils.getColorScheme(context).background)),
                                ),
                                Positioned.directional(
                                    textDirection: Directionality.of(context),
                                    end: 0,
                                    child: Container(
                                        height: 15,
                                        width: 15,
                                        alignment: Alignment.center,
                                        margin: const EdgeInsets.all(3.0),
                                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(25.0), color: Theme.of(context).primaryColor),
                                        child: InkWell(
                                          child: Icon(Icons.close, size: 11, color: UiUtils.getColorScheme(context).background),
                                          onTap: () {
                                            setState(() {
                                              tagsName.remove(tagsName[index]);
                                              tagsId.remove(tagsId[index]);
                                            });
                                          },
                                        )))
                              ],
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ),
        );
      } else {
        return const SizedBox.shrink();
      }
    });
  }

  Widget locationCitySelectionName() {
    return BlocConsumer<LocationCityCubit, LocationCityState>(
      listener: (context, state) {
        if (locationSel != "" || (widget.isEdit && widget.model!.locationId != null)) locationIndex = context.read<LocationCityCubit>().getLocationIndex(locationName: locationSel);
        if (state is LocationCityFetchSuccess) {
          context.read<BottomSheetCubit>().updateLocationContent(state.locationCity);
        }
      },
      builder: (context, state) {
        if (state is LocationCityFetchSuccess) {
          if (state.locationCity.isNotEmpty && state.locationCity.length == 1) {
            locationSelId = state.locationCity.first.id;
            locationIndex = 0;
          }
          return Padding(
            padding: const EdgeInsets.only(top: 18.0),
            child: InkWell(
              onTap: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (BuildContext context) {
                    return CustomBottomsheet(
                        context: context,
                        titleTxt: 'selLocationLbl',
                        listLength: state.locationCity.length,
                        listViewChild: (context, index) {
                          return locationCityListItem(index, state.locationCity);
                        });
                  }),
              child: UiUtils.setRowWithContainer(
                  context: context,
                  firstChild: CustomTextLabel(
                      text: (state.locationCity.length == 1)
                          ? locationSel = state.locationCity.first.locationName
                          : (locationSel == "")
                              ? 'selLocationLbl'
                              : locationSel,
                      textStyle: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(color: locationSel == "" ? UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.6) : UiUtils.getColorScheme(context).primaryContainer)),
                  isContentTypeUpload: false),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget showTillSelDate() {
    return UiUtils.setTopPaddingParent(
      childWidget: InkWell(
        onTap: () async {
          DateTime? pickedDate =
              await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now().subtract(const Duration(days: 0)), lastDate: DateTime(DateTime.now().year + 1));
          if (pickedDate != null) {
            //pickedDate output format => 2021-03-10 00:00:00.000
            String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
            setState(() => showTill = formattedDate);
          }
        },
        child: Container(
          width: double.maxFinite,
          margin: const EdgeInsetsDirectional.only(top: 7),
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 17),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0), color: UiUtils.getColorScheme(context).background),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomTextLabel(
                  text: showTill == null ? 'showTilledDate' : showTill!,
                  textStyle: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(color: showTill == null ? UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.6) : UiUtils.getColorScheme(context).primaryContainer)),
              Align(alignment: Alignment.centerRight, child: Icon(Icons.calendar_month_outlined, color: UiUtils.getColorScheme(context).primaryContainer))
            ],
          ),
        ),
      ),
    );
  }

  void _showPicker() {
    showUploadImageBottomsheet(context: context, onCamera: _getFromCamera, onGallery: _getFromGallery);
  }

  _getFromCamera() async {
    try {
      XFile? pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() {
          image = File(pickedFile.path);
        });
        Navigator.of(context).pop(); //pop dialog
      }
    } catch (e) {
      debugPrint("camera-error-${e.toString()}");
    }
  }

  _getFromGallery() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);
        Navigator.of(context).pop();
      });
    }
  }

  _getFromGalleryOther() async {
    List<XFile>? pickedFileList = await ImagePicker().pickMultiImage(maxWidth: 1800, maxHeight: 1800);
    for (int i = 0; i < pickedFileList.length; i++) {
      otherImage.add(File(pickedFileList[i].path));
    }
    setState(() {});
  }

  _getFromGalleryVideo() async {
    final XFile? file = await ImagePicker().pickVideo(source: ImageSource.gallery, maxDuration: const Duration(seconds: 10));
    if (file != null) {
      setState(() => videoUpload = File(file.path));
    }
  }

  Widget uploadMainImage() {
    return InkWell(
      onTap: () => _showPicker(),
      child: (widget.isEdit || image != null)
          ? Padding(
              padding: const EdgeInsets.only(top: 25),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: (image == null)
                      ? CustomNetworkImage(networkImageUrl: widget.model!.image!, width: double.maxFinite, height: 125, fit: BoxFit.cover, isVideo: false)
                      : Image.file(image!, height: 125, width: double.maxFinite, fit: BoxFit.fill)),
            )
          : Container(
              height: 125,
              width: double.maxFinite,
              padding: const EdgeInsets.only(top: 25),
              child: UiUtils.dottedRRectBorder(
                  childWidget: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.image, color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.7)),
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 10),
                  child: CustomTextLabel(
                      text: 'uploadMainImageLbl', textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.5))),
                )
              ])),
            ),
    );
  }

  Widget uploadOtherImage() {
    return otherImage.isEmpty
        ? InkWell(
            onTap: () => _getFromGalleryOther(),
            child: Container(
                height: 125,
                width: double.maxFinite,
                padding: const EdgeInsets.only(top: 25),
                child: UiUtils.dottedRRectBorder(
                    childWidget: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.image, color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.7)),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(start: 10),
                    child: CustomTextLabel(
                        text: 'uploadOtherImageLbl',
                        textAlign: TextAlign.center,
                        textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.5))),
                  )
                ]))),
          )
        : Padding(
            padding: const EdgeInsets.only(top: 25),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () => _getFromGalleryOther(),
                  child: SizedBox(
                    height: 125,
                    width: 95,
                    child: UiUtils.dottedRRectBorder(
                        childWidget: Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.image, size: 15, color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.7)),
                      CustomTextLabel(
                        text: 'uploadOtherImageLbl',
                        textAlign: TextAlign.center,
                        textStyle: Theme.of(context).textTheme.bodySmall!.copyWith(color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.5)),
                      )
                    ])),
                  ),
                ),
                Expanded(
                  child: SizedBox(
                      height: 125,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: otherImage.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsetsDirectional.only(start: 10),
                            child: ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.file(otherImage[index], height: 125, width: 95, fit: BoxFit.fill)),
                          );
                        },
                      )),
                )
              ],
            ),
          );
  }

  Widget modelOtherImage() {
    return widget.model!.imageDataList!.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.only(top: 25),
            child: SizedBox(
                height: 125,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.model!.imageDataList!.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.zero,
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsetsDirectional.only(top: 10, end: 8),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: CustomNetworkImage(networkImageUrl: widget.model!.imageDataList![index].otherImage!, isVideo: false, fit: BoxFit.cover, height: 125, width: 95)),
                          ),
                          BlocConsumer<DeleteImageCubit, DeleteImageState>(
                              bloc: context.read<DeleteImageCubit>(),
                              listener: (context, state) {
                                if (state is DeleteImageSuccess) {
                                  context.read<GetUserNewsCubit>().deleteImageId(index);
                                  showSnackBar(state.message, context);
                                  setState(() {});
                                }
                              },
                              builder: (context, state) {
                                return Positioned.directional(
                                    textDirection: Directionality.of(context),
                                    end: 0,
                                    child: Container(
                                        height: 18,
                                        width: 18,
                                        alignment: Alignment.center,
                                        margin: const EdgeInsets.all(3.0),
                                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(25.0), color: Theme.of(context).primaryColor),
                                        child: InkWell(
                                          child: Icon(Icons.close, size: 13, color: UiUtils.getColorScheme(context).background),
                                          onTap: () {
                                            context.read<DeleteImageCubit>().setDeleteImage(imageId: widget.model!.imageDataList![index].id!);
                                            setState(() {});
                                          },
                                        )));
                              })
                        ],
                      ),
                    );
                  },
                )))
        : const SizedBox.shrink();
  }

  Widget nextBtn() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 10, bottom: 20, start: 20, end: 20),
      child: InkWell(
        splashColor: Colors.transparent,
        child: Container(
            height: 55.0,
            width: MediaQuery.of(context).size.width * 0.9,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: UiUtils.getColorScheme(context).primaryContainer, borderRadius: BorderRadius.circular(7.0)),
            child: CustomTextLabel(
                text: 'nxt',
                textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(color: UiUtils.getColorScheme(context).background, fontWeight: FontWeight.w600, fontSize: 21, letterSpacing: 0.6))),
        onTap: () async {
          FocusScope.of(context).unfocus();
          final form = _formkey.currentState;
          form!.save();
          if (form.validate()) {
            if (!widget.isEdit && context.read<SlugCheckCubit>().state is! SlugCheckFetchSuccess) {
              showSnackBar(UiUtils.getTranslatedLabel(context, 'slugUsedAlready'), context);
              return;
            }
            if (catSelId == null) {
              showSnackBar(UiUtils.getTranslatedLabel(context, 'plzSelCatLbl'), context);
              return;
            }
            if (langName == "") {
              showSnackBar(UiUtils.getTranslatedLabel(context, 'chooseLanLbl'), context);
              return;
            }
            if (conType == UiUtils.getTranslatedLabel(context, 'videoUploadLbl')) {
              if (!widget.isEdit && videoUpload == null) {
                showSnackBar(UiUtils.getTranslatedLabel(context, 'plzUploadVideoLbl'), context);
                return;
              }
            }
            if ((conType == UiUtils.getTranslatedLabel(context, 'videoYoutubeLbl') || conType == UiUtils.getTranslatedLabel(context, 'videoOtherUrlLbl')) && urlC.text.contains("/shorts")) {
              //do not allow to add link of Youtube shorts as of now
              showSnackBar(UiUtils.getTranslatedLabel(context, 'plzValidUrlLbl'), context);
              urlC.clear();
              return;
            }
            if (!widget.isEdit && image == null) {
              showSnackBar(UiUtils.getTranslatedLabel(context, 'plzAddMainImageLbl'), context);
              return;
            }
            //validate other or Youtube URL & set type accordingly
            if (conType == UiUtils.getTranslatedLabel(context, 'videoOtherUrlLbl') && (urlC.text.contains("youtube") || urlC.text.contains("youtu.be"))) {
              conType = UiUtils.getTranslatedLabel(context, 'videoYoutubeLbl');
              conTypeId = "video_youtube";
            } else if (conType == UiUtils.getTranslatedLabel(context, 'videoYoutubeLbl') && (!urlC.text.contains("youtube") && !urlC.text.contains("youtu.be"))) {
              conType = UiUtils.getTranslatedLabel(context, 'videoOtherUrlLbl');
              conTypeId = "video_other";
            }
            setState(() => isNext = true);
          }
        },
      ),
    );
  }

  validateFunc(String description) {
    desc = description;
    validateForm();
  }

  Widget tagListItem(int index, List<TagModel> tagList) {
    return UiUtils.setTopPaddingParent(
      childWidget: InkWell(
        onTap: () {
          if (!tagsId.contains(tagList[index].id!)) {
            setState(() {
              tagsName.add(tagList[index].tagName!);
              tagsId.add(tagList[index].id!);
            });
          } else {
            setState(() {
              tagsName.remove(tagList[index].tagName!);
              tagsId.remove(tagList[index].id!);
            });
          }
          Navigator.pop(context);
        },
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              color: tagsId.isNotEmpty
                  ? tagsId.contains(tagList[index].id!)
                      ? Theme.of(context).primaryColor
                      : UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.1)
                  : UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.1)),
          padding: const EdgeInsets.all(10.0),
          alignment: Alignment.center,
          child: CustomTextLabel(
              text: tagList[index].tagName!,
              textStyle: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(color: (tagsId.contains(tagList[index].id!)) ? UiUtils.getColorScheme(context).secondary : UiUtils.getColorScheme(context).primaryContainer)),
        ),
      ),
    );
  }

  Widget subCatListItem(int index, List<CategoryModel> catList) {
    return UiUtils.setTopPaddingParent(
      childWidget: InkWell(
          onTap: () {
            setState(() {
              subCatSel = catList[catIndex!].subData![index].subCatName!;
              subSelId = catList[catIndex!].subData![index].id!;
            });
            Navigator.pop(context);
          },
          child: UiUtils.setBottomsheetContainer(listItem: catList[catIndex!].subData![index].subCatName!, compareTo: subCatSel, context: context)),
    );
  }

  Widget langListItem(int index, List<LanguageModel> langList) {
    return UiUtils.setTopPaddingParent(
      childWidget: InkWell(
        onTap: () {
          langId = langList[index].id!;
          langName = langList[index].language!;
          catSel = "";
          //load categories according to language selected
          getCategory(languageId: langId);
          getTag(languageId: langId);
          setState(() {});
          Navigator.pop(context);
        },
        child: UiUtils.setBottomsheetContainer(listItem: langList[index].language!, compareTo: langName, context: context),
      ),
    );
  }

  Widget catListItem(int index, List<CategoryModel> catList) {
    return UiUtils.setTopPaddingParent(
      childWidget: InkWell(
        onTap: () {
          setState(() {
            subSelId = null;
            subCatSel = "";
            catSel = catList[index].categoryName!;
            catSelId = catList[index].id!;
            catIndex = index;
          });
          Navigator.pop(context);
        },
        child: UiUtils.setBottomsheetContainer(listItem: catList[index].categoryName!, compareTo: catSel, context: context),
      ),
    );
  }

  Widget locationCityListItem(int index, List<LocationCityModel> locationCityList) {
    return UiUtils.setTopPaddingParent(
      childWidget: InkWell(
        onTap: () {
          setState(() {
            locationSel = locationCityList[index].locationName;
            locationSelId = locationCityList[index].id;
            locationIndex = index;
          });
          Navigator.pop(context);
        },
        child: UiUtils.setBottomsheetContainer(listItem: locationCityList[index].locationName, compareTo: locationSel, context: context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    setContentType();
    return Scaffold(
      bottomNavigationBar: !isNext ? nextBtn() : null,
      key: _scaffoldKey,
      appBar: getAppBar(),
      body: BlocConsumer<AddNewsCubit, AddNewsState>(
          bloc: context.read<AddNewsCubit>(),
          listener: (context, state) async {
            if (state is AddNewsFetchFailure) showSnackBar(state.errorMessage, context);
            if (state is AddNewsFetchSuccess) {
              if (!widget.isEdit) {
                showSnackBar(state.addNews["message"], context);
                if (widget.from == "myNews") {
                  FocusScope.of(context).unfocus();
                  clearText();
                  Navigator.of(context).pop();
                } else {
                  Navigator.of(context).pushReplacementNamed(Routes.manageUserNews).whenComplete(() {
                    FocusScope.of(context).unfocus();
                    clearText();
                  });
                }
              } else {
                Future.delayed(Duration.zero, () {
                  context.read<GetUserNewsCubit>().getGetUserNews(
                      langId: context.read<AppLocalizationCubit>().state.id,
                      latitude: SettingsLocalDataRepository().getLocationCityValues().first,
                      longitude: SettingsLocalDataRepository().getLocationCityValues().last);
                }).then((value) {
                  showSnackBar(state.addNews["message"], context);
                  Navigator.of(context).pop();
                });
              }
            }
          },
          builder: (context, state) {
            return Form(
                key: _formkey,
                child: Stack(children: [
                  if (state is AddNewsFetchInProgress) Center(child: showCircularProgress(true, Theme.of(context).primaryColor)),
                  !isNext
                      ? PopScope(
                          canPop: (!isNext) ? true : false,
                          onPopInvoked: (bool isTrue) {
                            setState(() => isNext = false);
                          },
                          child: SingleChildScrollView(
                              padding: const EdgeInsetsDirectional.only(start: 20, end: 20, bottom: 20),
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  newsTitleName(),
                                  languageSelName(),
                                  catSelectionName(),
                                  subCatSelectionName(),
                                  contentTypeSelName(),
                                  if (widget.isEdit) contentUrlForVideoUpload(),
                                  contentVideoUpload(),
                                  contentUrlSet(),
                                  tagSelectionName(),
                                  locationCitySelectionName(),
                                  showTillSelDate(),
                                  uploadMainImage(),
                                  uploadOtherImage(),
                                  if (widget.isEdit) modelOtherImage(),
                                  webNewsDetails()
                                ],
                              )),
                        )
                      : NewsDescription(desc ?? "", updateParent, validateFunc, 1)
                ]));
          }),
    );
  }

  Widget customTextFormFieldWithWarningLabel({required TextEditingController controller, required String hintText, required String warningText, required int maxLines}) {
    return Column(
      children: [
        Container(
            width: double.maxFinite,
            margin: const EdgeInsetsDirectional.symmetric(vertical: 7),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0), color: UiUtils.getColorScheme(context).background),
            child: TextFormField(
                textInputAction: (maxLines > 1) ? TextInputAction.newline : TextInputAction.next,
                maxLines: maxLines,
                controller: controller,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer),
                validator: (val) {
                  switch (hintText) {
                    case 'metaTitleLbl':
                      return Validators.emptyFieldValidation(val!, 'metaTitleLbl', context);
                    case 'metaDescriptionLbl':
                      return Validators.emptyFieldValidation(val!, 'metaDescriptionLbl', context);
                    case 'metaKeywordLbl':
                      return Validators.emptyFieldValidation(val!, 'metaKeywordLbl', context);
                    case 'slugLbl':
                      return Validators.slugValidation(val!, context);
                  }
                  return null;
                },
                onChanged: (String value) => setState(() {
                      switch (hintText) {
                        case 'metaTitleLbl':
                          metaTitle = value;
                          break;
                        case 'metaDescriptionLbl':
                          metaDescription = value;
                          break;
                        case 'metaKeywordLbl':
                          metaKeyword = value;
                          break;
                        case 'slugLbl':
                          slugC.text = slugC.text.replaceAll(' ', '-');
                          slug = slugC.text;
                          //call APi to check Availability of Entered slug
                          if (slugC.text.trim().isNotEmpty) {
                            context.read<SlugCheckCubit>().checkSlugAvailability(slug: slugC.text, langId: context.read<AppLocalizationCubit>().state.id);
                          }
                          break;
                      }
                    }),
                onTapOutside: (val) => FocusScope.of(context).unfocus(),
                decoration: InputDecoration(
                    hintText: UiUtils.getTranslatedLabel(context, hintText),
                    hintStyle: Theme.of(context).textTheme.titleMedium?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.6)),
                    filled: true,
                    fillColor: UiUtils.getColorScheme(context).background,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 17),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(10.0)),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(10.0))))),
        ((!isMetaTitle && hintText == 'metaTitleLbl') ||
                (!isMetaDescription && hintText == 'metaDescriptionLbl') ||
                (!isMetaKeyword && hintText == 'metaKeywordLbl') ||
                (!isSlug && hintText == 'slugLbl'))
            ? Container(
                padding: const EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(border: Border.all(color: warningColor), borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    const Padding(padding: EdgeInsets.all(3.0), child: Icon(Icons.info_rounded, color: warningColor)),
                    Expanded(child: CustomTextLabel(text: warningText, textAlign: TextAlign.left)),
                    IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: (() {
                          switch (hintText) {
                            case 'metaTitleLbl':
                              setState(() => isMetaTitle = true);
                              break;
                            case 'metaDescriptionLbl':
                              setState(() => isMetaDescription = true);
                              break;
                            case 'metaKeywordLbl':
                              setState(() => isMetaKeyword = true);
                              break;
                            case 'slugLbl':
                              setState(() => isSlug = true);
                              break;
                          }
                        }),
                        icon: const Icon(Icons.close_rounded, color: borderColor, size: 18))
                  ],
                ),
              )
            : const SizedBox.shrink()
      ],
    );
  }

  Widget webNewsDetails() {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: Column(children: [
          customTextFormFieldWithWarningLabel(controller: metaTitleC, hintText: 'metaTitleLbl', warningText: 'metaTitleWarningLbl', maxLines: 1),
          customTextFormFieldWithWarningLabel(controller: metaDescriptionC, hintText: 'metaDescriptionLbl', warningText: 'metaDescriptionWarningLbl', maxLines: 2),
          customTextFormFieldWithWarningLabel(controller: metaKeywordC, hintText: 'metaKeywordLbl', warningText: 'metaKeywordWarningLbl', maxLines: 1),
          customTextFormFieldWithWarningLabel(controller: slugC, hintText: 'slugLbl', warningText: 'slugWarningLbl', maxLines: 1)
        ]));
  }

  updateParent(String description, bool next) {
    setState(() {
      desc = description;
      isNext = next;
    });
  }

  validateForm() async {
    if (await InternetConnectivity.isNetworkAvailable()) {
      context.read<AddNewsCubit>().addNews(
            context: context,
            newsId: (widget.isEdit) ? widget.model!.id! : null,
            actionType: (widget.isEdit) ? "2" : "1",
            catId: catSelId!,
            title: title!,
            conTypeId: conTypeId,
            conType: conType,
            image: image,
            langId: langId,
            subCatId: subSelId,
            showTill: showTill,
            desc: desc,
            otherImage: otherImage,
            tagId: tagsId.isNotEmpty ? tagsId.join(',') : null,
            url: urlC.text.isNotEmpty ? urlC.text : null,
            videoUpload: videoUpload,
            locationId: locationSelId,
            metaTitle: metaTitle!,
            metaDescription: metaDescription!,
            metaKeyword: metaKeyword!,
            slug: slug!,
          );
      getCategory(); //get default language categories again for Categories Tab
    } else {
      showSnackBar(UiUtils.getTranslatedLabel(context, 'internetmsg'), context);
    }
  }
}
