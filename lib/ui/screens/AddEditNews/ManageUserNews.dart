// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:news/data/repositories/Settings/settingsLocalDataRepository.dart';
import 'package:news/ui/widgets/customTextBtn.dart';
import 'package:news/ui/widgets/customTextLabel.dart';
import 'package:news/ui/widgets/errorContainerWidget.dart';
import 'package:news/utils/ErrorMessageKeys.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news/cubits/appLocalizationCubit.dart';
import 'package:news/cubits/deleteUserNewsCubit.dart';
import 'package:news/cubits/getUserNewsCubit.dart';
import 'package:news/data/models/NewsModel.dart';
import 'package:news/app/routes.dart';
import 'package:news/utils/uiUtils.dart';
import 'package:news/ui/widgets/networkImage.dart';
import 'package:news/ui/widgets/SnackBarWidget.dart';
import 'package:news/ui/widgets/circularProgressIndicator.dart';

class ManageUserNews extends StatefulWidget {
  const ManageUserNews({super.key});

  @override
  ManageUserNewsState createState() => ManageUserNewsState();
}

class ManageUserNewsState extends State<ManageUserNews> {
  final bool _isButtonExtended = true;
  late final ScrollController controller = ScrollController()..addListener(hasMoreNewsScrollListener);

  @override
  void initState() {
    getNews();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void getNews() {
    context.read<GetUserNewsCubit>().getGetUserNews(
        langId: context.read<AppLocalizationCubit>().state.id,
        latitude: SettingsLocalDataRepository().getLocationCityValues().first,
        longitude: SettingsLocalDataRepository().getLocationCityValues().last);
  }

  void getMoreNews() {
    context.read<GetUserNewsCubit>().getMoreGetUserNews(
        langId: context.read<AppLocalizationCubit>().state.id,
        latitude: SettingsLocalDataRepository().getLocationCityValues().first,
        longitude: SettingsLocalDataRepository().getLocationCityValues().last);
  }

  void hasMoreNewsScrollListener() {
    if (controller.position.maxScrollExtent == controller.offset) {
      if (context.read<GetUserNewsCubit>().hasMoreGetUserNews()) {
        getMoreNews();
      } else {
        debugPrint("No more News for this user");
      }
    }
  }

  getAppBar() {
    return PreferredSize(
        preferredSize: const Size(double.infinity, 45),
        child: AppBar(
            centerTitle: false,
            backgroundColor: Colors.transparent,
            title: Transform(
                transform: Matrix4.translationValues(-20.0, 0.0, 0.0),
                child: CustomTextLabel(
                    text: 'manageNewsLbl',
                    textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer, fontWeight: FontWeight.w600, letterSpacing: 0.5))),
            leading: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: Icon(Icons.arrow_back, color: UiUtils.getColorScheme(context).primaryContainer)),
            )));
  }

  newsAddBtn() {
    return Column(mainAxisAlignment: MainAxisAlignment.end, children: [
      FloatingActionButton(
          isExtended: _isButtonExtended,
          backgroundColor: UiUtils.getColorScheme(context).background,
          child: Icon(Icons.add, size: 32, color: UiUtils.getColorScheme(context).primaryContainer),
          onPressed: () {
            Navigator.of(context).pushNamed(Routes.addNews, arguments: {"isEdit": false, "from": "myNews"});
          }),
      const SizedBox(height: 10)
    ]);
  }

  _buildNewsContainer({required NewsModel model, required int index, required int totalCurrentNews, required bool hasMoreNewsFetchError, required bool hasMore}) {
    if (index == totalCurrentNews - 1 && index != 0) {
      if (hasMore) {
        if (hasMoreNewsFetchError) {
          return Center(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
            child: IconButton(onPressed: () => getMoreNews(), icon: Icon(Icons.error, color: Theme.of(context).primaryColor)),
          ));
        } else {
          return Center(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0), child: showCircularProgress(true, Theme.of(context).primaryColor)));
        }
      }
    }

    return InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(Routes.newsDetails, arguments: {"model": model, "isFromBreak": false, "fromShowMore": false});
        },
        child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0), color: UiUtils.getColorScheme(context).background),
            padding: const EdgeInsetsDirectional.all(15),
            margin: const EdgeInsets.only(top: 20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisSize: MainAxisSize.min, children: [
                SizedBox(
                    width: MediaQuery.of(context).size.width * 0.24,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [newsImage(imageURL: model.image!), categoryName(categoryName: (model.categoryName != null && model.categoryName!.trim().isNotEmpty) ? model.categoryName! : "")],
                    )),
                Expanded(
                    child: Padding(
                        padding: const EdgeInsetsDirectional.only(start: 15),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          CustomTextLabel(
                              text: model.title!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                              textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(color: UiUtils.getColorScheme(context).primaryContainer)),
                          contentTypeAndSubcategoryView(model: model),
                          model.tagName! != "" ? tagsView(model: model) : const SizedBox.shrink(),
                          Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                                deleteAndEditButton(isEdit: true, onTap: () => Navigator.of(context).pushNamed(Routes.addNews, arguments: {"model": model, "isEdit": true, "from": "myNews"})),
                                deleteAndEditButton(isEdit: false, onTap: () => deleteNewsDialogue(model.id!, index)),
                              ]))
                        ])))
              ]),
              setDate(dateValue: model.date!)
            ])));
  }

  Widget newsImage({required String imageURL}) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: CustomNetworkImage(networkImageUrl: imageURL, fit: BoxFit.cover, height: MediaQuery.of(context).size.width * 0.23, isVideo: false, width: MediaQuery.of(context).size.width * 0.23));
  }

  Widget categoryName({required String categoryName}) {
    return (categoryName.trim().isNotEmpty)
        ? Padding(
            padding: const EdgeInsets.only(top: 4),
            child: CustomTextLabel(
                text: categoryName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                textStyle: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.8), fontWeight: FontWeight.w600, fontStyle: FontStyle.normal)),
          )
        : const SizedBox.shrink();
  }

  Widget contentTypeAndSubcategoryView({required NewsModel model}) {
    String contType = "";
    if (model.contentType == "standard_post") {
      contType = UiUtils.getTranslatedLabel(context, 'stdPostLbl');
    } else if (model.contentType == "video_youtube") {
      contType = UiUtils.getTranslatedLabel(context, 'videoYoutubeLbl');
    } else if (model.contentType == "video_other") {
      contType = UiUtils.getTranslatedLabel(context, 'videoOtherUrlLbl');
    } else if (model.contentType == "video_upload") {
      contType = UiUtils.getTranslatedLabel(context, 'videoUploadLbl');
    }
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (model.subCatName != null && model.subCatName != "")
          Padding(
            padding: const EdgeInsets.only(top: 7),
            child: CustomTextLabel(
                text: 'subcatLbl',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                textStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.8))),
          ),
        if (model.contentType != "")
          Padding(
            padding: const EdgeInsets.only(top: 7),
            child: CustomTextLabel(
                text: 'contentTypeLbl',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                textStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(color: UiUtils.getColorScheme(context).primaryContainer)),
          )
      ])),
      Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (model.subCatName != null && model.subCatName != "")
          Padding(
            padding: const EdgeInsets.only(top: 7),
            child: CustomTextLabel(
                text: model.subCatName!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.7))),
          ),
        if (model.contentType != "")
          Padding(
            padding: const EdgeInsets.only(top: 7),
            child: CustomTextLabel(
                text: contType,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.7))),
          )
      ]))
    ]);
  }

  Widget tagsView({required NewsModel model}) {
    List<String> tagList = [];

    if (model.tagName! != "") {
      final tagName = model.tagName!;
      tagList = tagName.split(',');
    }

    List<String> tagId = [];
    if (model.tagId! != "") tagId = model.tagId!.split(",");
    return Container(
        margin: const EdgeInsets.only(top: 7),
        height: 18.0,
        child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemCount: tagList.length,
            itemBuilder: (context, index) {
              return Padding(
                  padding: EdgeInsetsDirectional.only(start: index == 0 ? 0 : 5.5),
                  child: InkWell(
                    child: Container(
                        height: 20.0,
                        width: 65,
                        alignment: Alignment.center,
                        padding: const EdgeInsetsDirectional.only(start: 3.0, end: 3.0),
                        decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(10.0), bottomRight: Radius.circular(10.0)),
                            color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.2)),
                        child: CustomTextLabel(
                            text: tagList[index],
                            textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer, fontSize: 9.5),
                            overflow: TextOverflow.ellipsis,
                            softWrap: true)),
                    onTap: () {
                      Navigator.of(context).pushNamed(Routes.tagScreen, arguments: {"tagId": tagId[index], "tagName": tagList[index]});
                    },
                  ));
            }));
  }

  Widget deleteAndEditButton({required bool isEdit, required void Function()? onTap}) {
    return InkWell(
        onTap: onTap,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.20,
          height: 25,
          padding: const EdgeInsetsDirectional.only(top: 3, bottom: 3),
          alignment: Alignment.center,
          decoration: BoxDecoration(color: UiUtils.getColorScheme(context).primaryContainer, borderRadius: BorderRadius.circular(3)),
          child: CustomTextLabel(
              text: (isEdit) ? 'editLbl' : 'deleteTxt',
              overflow: TextOverflow.ellipsis,
              softWrap: true,
              textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: UiUtils.getColorScheme(context).background, fontWeight: FontWeight.w600)),
        ));
  }

  Widget setDate({required String dateValue}) {
    DateTime time = DateTime.parse(dateValue);
    return CustomTextLabel(
        text: UiUtils.convertToAgo(context, time, 0)!,
        overflow: TextOverflow.ellipsis,
        softWrap: true,
        textStyle: Theme.of(context).textTheme.bodySmall!.copyWith(color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.8)));
  }

  deleteNewsDialogue(String id, int index) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (BuildContext context, StateSetter setStater) {
            return AlertDialog(
              backgroundColor: UiUtils.getColorScheme(context).background,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0))),
              content: CustomTextLabel(text: 'doYouReallyNewsLbl', textStyle: Theme.of(this.context).textTheme.titleMedium),
              title: const CustomTextLabel(text: 'delNewsLbl'),
              titleTextStyle: Theme.of(this.context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              actions: <Widget>[
                CustomTextButton(
                    textWidget: CustomTextLabel(
                        text: 'noLbl', textStyle: Theme.of(this.context).textTheme.titleSmall?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer, fontWeight: FontWeight.bold)),
                    onTap: () {
                      Navigator.of(context).pop(false);
                    }),
                BlocConsumer<DeleteUserNewsCubit, DeleteUserNewsState>(
                    bloc: context.read<DeleteUserNewsCubit>(),
                    listener: (context, state) {
                      if (state is DeleteUserNewsSuccess) {
                        context.read<GetUserNewsCubit>().deleteNews(index);
                        showSnackBar(state.message, context);
                        Navigator.pop(context);
                      }
                    },
                    builder: (context, state) {
                      return CustomTextButton(
                          textWidget: CustomTextLabel(
                              text: 'yesLbl', textStyle: Theme.of(this.context).textTheme.titleSmall?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer, fontWeight: FontWeight.bold)),
                          onTap: () async {
                            context.read<DeleteUserNewsCubit>().setDeleteUserNews(newsId: id);
                          });
                    })
              ],
            );
          });
        });
  }

  contentShimmer(BuildContext context) {
    return Shimmer.fromColors(
        baseColor: Colors.grey.withOpacity(0.6),
        highlightColor: Colors.grey,
        child: ListView.builder(
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsetsDirectional.only(start: 20, end: 20),
            itemBuilder: (_, i) =>
                Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0), color: Colors.grey.withOpacity(0.6)), margin: const EdgeInsets.only(top: 20), height: 170.0),
            itemCount: 6));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: getAppBar(),
        floatingActionButton: newsAddBtn(),
        body: BlocBuilder<GetUserNewsCubit, GetUserNewsState>(
          builder: (context, state) {
            if (state is GetUserNewsFetchSuccess) {
              return Padding(
                padding: const EdgeInsetsDirectional.all(10),
                child: RefreshIndicator(
                  onRefresh: () async {
                    getNews();
                  },
                  child: ListView.builder(
                      controller: controller,
                      physics: const AlwaysScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: state.getUserNews.length,
                      itemBuilder: (context, index) {
                        return _buildNewsContainer(
                            model: state.getUserNews[index], hasMore: state.hasMore, hasMoreNewsFetchError: state.hasMoreFetchError, index: index, totalCurrentNews: state.getUserNews.length);
                      }),
                ),
              );
            }
            if (state is GetUserNewsFetchFailure) {
              return ErrorContainerWidget(
                  errorMsg: (state.errorMessage.contains(ErrorMessageKeys.noInternet)) ? UiUtils.getTranslatedLabel(context, 'internetmsg') : state.errorMessage, onRetry: getNews);
            }
            return contentShimmer(context);
          },
        ));
  }
}
