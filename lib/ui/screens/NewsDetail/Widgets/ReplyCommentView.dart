// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news/cubits/appLocalizationCubit.dart';
import 'package:news/data/models/CommentModel.dart';
import 'package:news/ui/screens/NewsDetail/Widgets/delAndReportCom.dart';
import 'package:news/ui/screens/NewsDetail/Widgets/delAndReportReplyComm.dart';
import 'package:news/ui/widgets/circularProgressIndicator.dart';
import 'package:news/ui/widgets/customTextLabel.dart';
import 'package:news/ui/widgets/loginRequired.dart';
import 'package:news/utils/uiUtils.dart';
import 'package:news/cubits/Auth/authCubit.dart';
import 'package:news/cubits/NewsComment/likeAndDislikeCommCubit.dart';
import 'package:news/cubits/NewsComment/setCommentCubit.dart';
import 'package:news/cubits/commentNewsCubit.dart';
import 'package:news/data/repositories/NewsComment/LikeAndDislikeComment/likeAndDislikeCommRepository.dart';

class ReplyCommentView extends StatefulWidget {
  final int replyComIndex;
  final Function replyComFun;
  final String newsId;

  const ReplyCommentView({super.key, required this.replyComIndex, required this.replyComFun, required this.newsId});

  @override
  ReplyCommentViewState createState() => ReplyCommentViewState();
}

class ReplyCommentViewState extends State<ReplyCommentView> {
  bool isReply = false, replyComEnabled = false, isSending = false;
  final TextEditingController _replyComC = TextEditingController();
  TextEditingController reportC = TextEditingController();

  Widget allReplyComView(CommentModel model) {
    return Row(children: [
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(children: [
            CustomTextLabel(
                text: 'allLbl',
                textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.6), fontSize: 12.0, fontWeight: FontWeight.w600)),
            CustomTextLabel(
                text: " ${model.replyComList!.length} ",
                textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.6), fontSize: 12.0, fontWeight: FontWeight.w600)),
            CustomTextLabel(
                text: 'replyLbl',
                textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.6), fontSize: 12.0, fontWeight: FontWeight.w600)),
          ])),
      const Spacer(),
      Align(
          alignment: Alignment.topRight,
          child: InkWell(
              child: const Icon(Icons.close),
              onTap: () {
                setState(() => isReply = false);
                widget.replyComFun(false, widget.replyComIndex);
              }))
    ]);
  }

  replyComProfileWithCom(CommentModel model) {
    DateTime replyTime = DateTime.parse(model.date!);
    return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          model.profile != null && model.profile != ""
              ? UiUtils.setFixedSizeboxForProfilePicture(childWidget: CircleAvatar(backgroundImage: NetworkImage(model.profile!), radius: 32))
              : UiUtils.setFixedSizeboxForProfilePicture(childWidget: const Icon(Icons.account_circle, size: 35)),
          Expanded(
              child: Padding(
                  padding: const EdgeInsetsDirectional.only(start: 15.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CustomTextLabel(
                              text: model.name!, textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.7), fontSize: 13)),
                          Padding(
                              padding: const EdgeInsetsDirectional.only(start: 10.0), child: Icon(Icons.circle, size: 4.0, color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.7))),
                          Padding(
                              padding: const EdgeInsetsDirectional.only(start: 10.0),
                              child: CustomTextLabel(
                                  text: UiUtils.convertToAgo(context, replyTime, 1)!,
                                  textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.7), fontSize: 10)))
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: CustomTextLabel(
                            text: model.message!, textStyle: Theme.of(context).textTheme.titleSmall?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer, fontWeight: FontWeight.normal)),
                      ),
                      BlocConsumer<LikeAndDislikeCommCubit, LikeAndDislikeCommState>(
                          bloc: context.read<LikeAndDislikeCommCubit>(),
                          listener: (context, state) {
                            if (state is LikeAndDislikeCommSuccess) {
                              if (state.fromLike) {
                                if (state.comment.like == "1") {
                                  model.like = "0";
                                  if (model.totalLikes!.isNotEmpty) model.totalLikes = (int.parse(model.totalLikes!) - 1).toString();
                                  setState(() {});
                                } else {
                                  if (state.comment.dislike == "1") model.dislike = "0";
                                  if (state.comment.dislike == "1" && model.totalDislikes!.isNotEmpty) model.totalDislikes = (int.parse(model.totalDislikes!) - 1).toString();
                                  model.like = "1";
                                  model.totalLikes = (int.parse(model.totalLikes!) + 1).toString();
                                  setState(() {});
                                }
                              } else {
                                if (state.comment.dislike == "1") {
                                  model.dislike = "0";
                                  if (model.totalDislikes!.isNotEmpty) model.totalDislikes = (int.parse(model.totalDislikes!) - 1).toString();
                                  setState(() {});
                                } else {
                                  if (state.comment.like == "1") model.like = "0";
                                  if (state.comment.like == "1" && model.totalLikes!.isNotEmpty) model.totalLikes = (int.parse(model.totalLikes!) - 1).toString();
                                  model.dislike = "1";
                                  model.totalDislikes = (int.parse(model.totalDislikes!) + 1).toString();
                                  setState(() {});
                                }
                              }
                            }
                          },
                          builder: (context, state) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 15.0),
                              child: Row(
                                children: [
                                  InkWell(
                                    child: const Icon(Icons.thumb_up_off_alt_rounded),
                                    onTap: () {
                                      if (context.read<AuthCubit>().getUserId() != "0") {
                                        context
                                            .read<LikeAndDislikeCommCubit>()
                                            .setLikeAndDislikeComm(langId: context.read<AppLocalizationCubit>().state.id, comment: model, status: (model.like == "1") ? "0" : "1", fromLike: true);
                                      } else {
                                        loginRequired(context);
                                      }
                                    },
                                  ),
                                  model.totalLikes! != "0"
                                      ? Padding(
                                          padding: const EdgeInsetsDirectional.only(start: 4.0),
                                          child: CustomTextLabel(
                                              text: model.totalLikes!, textStyle: Theme.of(context).textTheme.titleSmall?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer)))
                                      : const SizedBox(width: 12),
                                  Padding(
                                      padding: const EdgeInsetsDirectional.only(start: 35),
                                      child: InkWell(
                                        child: const Icon(Icons.thumb_down_alt_rounded),
                                        onTap: () {
                                          if (context.read<AuthCubit>().getUserId() != "0") {
                                            context.read<LikeAndDislikeCommCubit>().setLikeAndDislikeComm(
                                                langId: context.read<AppLocalizationCubit>().state.id, comment: model, status: (model.dislike == "1") ? "0" : "2", fromLike: false);
                                          } else {
                                            loginRequired(context);
                                          }
                                        },
                                      )),
                                  model.totalDislikes! != "0"
                                      ? Padding(
                                          padding: const EdgeInsetsDirectional.only(start: 4.0),
                                          child: CustomTextLabel(
                                              text: model.totalDislikes!, textStyle: Theme.of(context).textTheme.titleSmall?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer)),
                                        )
                                      : const SizedBox(width: 12),
                                  const Padding(padding: EdgeInsetsDirectional.only(start: 35), child: InkWell(child: Icon(Icons.quickreply_rounded))),
                                  if (model.replyComList!.isNotEmpty)
                                    Padding(
                                        padding: const EdgeInsetsDirectional.only(start: 5.0),
                                        child: CustomTextLabel(
                                            text: model.replyComList!.length.toString(),
                                            textStyle: Theme.of(context).textTheme.titleSmall?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer))),
                                  const Spacer(),
                                  if (context.read<AuthCubit>().getUserId() != "0")
                                    InkWell(
                                      child: Icon(Icons.more_vert_outlined, color: UiUtils.getColorScheme(context).primaryContainer, size: 17),
                                      onTap: () {
                                        delAndReportCom(
                                            index: widget.replyComIndex,
                                            model: model,
                                            context: context,
                                            reportC: reportC,
                                            newsId: widget.newsId,
                                            setState: setState,
                                            isReplyUpdate: widget.replyComFun);
                                      },
                                    )
                                ],
                              ),
                            );
                          })
                    ],
                  ))),
        ]));
  }

  replyComSendReplyView(CommentModel model) {
    return context.read<AuthCubit>().getUserId() != "0"
        ? Padding(
            padding: const EdgeInsetsDirectional.only(top: 10.0),
            child: Row(
              children: [
                Expanded(
                    flex: 1,
                    child: context.read<AuthCubit>().getProfile() != ""
                        ? CircleAvatar(backgroundImage: NetworkImage(context.read<AuthCubit>().getProfile()))
                        : UiUtils.setFixedSizeboxForProfilePicture(childWidget: const Icon(Icons.account_circle, size: 35))),
                BlocListener<SetCommentCubit, SetCommentState>(
                    bloc: context.read<SetCommentCubit>(),
                    listener: (context, state) {
                      if (state is SetCommentFetchSuccess) {
                        context.read<CommentNewsCubit>().commentUpdateList(state.setComment, state.total);
                        FocusScopeNode currentFocus = FocusScope.of(context);
                        if (!currentFocus.hasPrimaryFocus) {
                          currentFocus.unfocus();
                        }
                        _replyComC.clear();
                        isSending = false;
                        setState(() {});
                      }
                      if (state is SetCommentFetchInProgress) {
                        setState(() => isSending = true);
                      }
                    },
                    child: Expanded(
                        flex: 7,
                        child: Padding(
                            padding: const EdgeInsetsDirectional.only(start: 18.0),
                            child: TextField(
                              controller: _replyComC,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.7)),
                              onChanged: (String val) {
                                if (_replyComC.text.trim().isNotEmpty) {
                                  setState(() => replyComEnabled = true);
                                } else {
                                  setState(() => replyComEnabled = false);
                                }
                              },
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.only(top: 10.0, bottom: 2.0),
                                  isDense: true,
                                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.5), width: 1.5)),
                                  hintText: UiUtils.getTranslatedLabel(context, 'publicReply'),
                                  hintStyle: Theme.of(context).textTheme.titleSmall?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.7)),
                                  suffixIconConstraints: const BoxConstraints(maxHeight: 35, maxWidth: 30),
                                  suffixIcon: (!isSending)
                                      ? IconButton(
                                          icon: Icon(Icons.send, color: replyComEnabled ? UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.8) : Colors.transparent, size: 20.0),
                                          onPressed: () async {
                                            if (context.read<AuthCubit>().getUserId() != "0") {
                                              context.read<SetCommentCubit>().setComment(parentId: model.id!, newsId: widget.newsId, message: _replyComC.text);
                                            } else {
                                              loginRequired(context);
                                            }
                                          },
                                        )
                                      : SizedBox(height: 12, width: 12, child: showCircularProgress(true, Theme.of(context).primaryColor))),
                            ))))
              ],
            ))
        : const SizedBox.shrink();
  }

  replyAllComListView(CommentModel model) {
    return Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: SingleChildScrollView(
            child: ListView.separated(
                separatorBuilder: (BuildContext context, int index) => Divider(color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.5)),
                shrinkWrap: true,
                reverse: true,
                padding: const EdgeInsets.only(top: 20.0),
                physics: const NeverScrollableScrollPhysics(),
                itemCount: model.replyComList!.length,
                itemBuilder: (context, index) {
                  DateTime time1 = DateTime.parse(model.replyComList![index].date!);
                  return BlocProvider<LikeAndDislikeCommCubit>(
                      create: (context) => LikeAndDislikeCommCubit(LikeAndDislikeCommRepository()),
                      child: Builder(builder: (context) {
                        return Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                          model.replyComList![index].profile != null && model.replyComList![index].profile != ""
                              ? UiUtils.setFixedSizeboxForProfilePicture(childWidget: CircleAvatar(backgroundImage: NetworkImage(model.replyComList![index].profile!), radius: 32))
                              : UiUtils.setFixedSizeboxForProfilePicture(childWidget: const Icon(Icons.account_circle, size: 35)),
                          Expanded(
                              child: Padding(
                                  padding: const EdgeInsetsDirectional.only(start: 15.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CustomTextLabel(
                                              text: model.replyComList![index].name!,
                                              textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.7), fontSize: 13)),
                                          Padding(
                                              padding: const EdgeInsetsDirectional.only(start: 10.0),
                                              child: Icon(Icons.circle, size: 4.0, color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.7))),
                                          Padding(
                                              padding: const EdgeInsetsDirectional.only(start: 10.0),
                                              child: CustomTextLabel(
                                                text: UiUtils.convertToAgo(context, time1, 1)!,
                                                textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.7), fontSize: 10),
                                              )),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: CustomTextLabel(
                                          text: model.replyComList![index].message!,
                                          textStyle: Theme.of(context).textTheme.titleSmall?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer, fontWeight: FontWeight.normal),
                                        ),
                                      ),
                                      BlocConsumer<LikeAndDislikeCommCubit, LikeAndDislikeCommState>(
                                          bloc: context.read<LikeAndDislikeCommCubit>(),
                                          listener: (context, state) {
                                            if (state is LikeAndDislikeCommSuccess) {
                                              if (state.fromLike) {
                                                if (state.comment.replyComList![index].like == "1") {
                                                  model.replyComList![index].like = "0";
                                                  model.replyComList![index].totalLikes = (int.parse(model.replyComList![index].totalLikes!) - 1).toString();
                                                  setState(() {});
                                                } else {
                                                  if (state.comment.replyComList![index].dislike == "1") model.replyComList![index].dislike = "0";
                                                  if (state.comment.replyComList![index].dislike == "1") {
                                                    model.replyComList![index].totalDislikes = (int.parse(model.replyComList![index].totalDislikes!) - 1).toString();
                                                  }
                                                  model.replyComList![index].like = "1";
                                                  model.replyComList![index].totalLikes = (int.parse(model.replyComList![index].totalLikes!) + 1).toString();
                                                  setState(() {});
                                                }
                                              } else {
                                                if (state.comment.replyComList![index].dislike == "1") {
                                                  model.replyComList![index].dislike = "0";
                                                  model.replyComList![index].totalDislikes = (int.parse(model.replyComList![index].totalDislikes!) - 1).toString();
                                                  setState(() {});
                                                } else {
                                                  if (state.comment.replyComList![index].like == "1") model.replyComList![index].like = "0";
                                                  if (state.comment.replyComList![index].like == "1") {
                                                    model.replyComList![index].totalLikes = (int.parse(model.replyComList![index].totalLikes!) - 1).toString();
                                                  }
                                                  model.replyComList![index].dislike = "1";
                                                  model.replyComList![index].totalDislikes = (int.parse(model.replyComList![index].totalDislikes!) + 1).toString();
                                                  setState(() {});
                                                }
                                              }
                                            }
                                          },
                                          builder: (context, state) {
                                            return Padding(
                                              padding: const EdgeInsets.only(top: 15.0),
                                              child: Row(
                                                children: [
                                                  InkWell(
                                                    child: const Icon(Icons.thumb_up_off_alt_rounded),
                                                    onTap: () {
                                                      (context.read<AuthCubit>().getUserId() != "0")
                                                          ? context.read<LikeAndDislikeCommCubit>().setLikeAndDislikeComm(
                                                              langId: context.read<AppLocalizationCubit>().state.id,
                                                              comment: model,
                                                              status: (model.replyComList![index].like == "1") ? "0" : "1",
                                                              fromLike: true)
                                                          : loginRequired(context);
                                                    },
                                                  ),
                                                  model.replyComList![index].totalLikes! != "0"
                                                      ? Padding(
                                                          padding: const EdgeInsetsDirectional.only(start: 4.0),
                                                          child: CustomTextLabel(
                                                              text: model.replyComList![index].totalLikes!,
                                                              textStyle: Theme.of(context).textTheme.titleSmall?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer)))
                                                      : const SizedBox(width: 12),
                                                  Padding(
                                                      padding: const EdgeInsetsDirectional.only(start: 35),
                                                      child: InkWell(
                                                        child: const Icon(Icons.thumb_down_alt_rounded),
                                                        onTap: () {
                                                          (context.read<AuthCubit>().getUserId() != "0")
                                                              ? context.read<LikeAndDislikeCommCubit>().setLikeAndDislikeComm(
                                                                  langId: context.read<AppLocalizationCubit>().state.id,
                                                                  comment: model,
                                                                  status: (model.replyComList![index].dislike == "1") ? "0" : "2",
                                                                  fromLike: false)
                                                              : loginRequired(context);
                                                        },
                                                      )),
                                                  model.replyComList![index].totalDislikes! != "0"
                                                      ? Padding(
                                                          padding: const EdgeInsetsDirectional.only(start: 4.0),
                                                          child: CustomTextLabel(
                                                              text: model.replyComList![index].totalDislikes!,
                                                              textStyle: Theme.of(context).textTheme.titleSmall?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer)))
                                                      : const SizedBox.shrink(),
                                                  const Spacer(),
                                                  if (context.read<AuthCubit>().getUserId() != "0")
                                                    InkWell(
                                                        child: Icon(Icons.more_vert_outlined, color: UiUtils.getColorScheme(context).primaryContainer, size: 17),
                                                        onTap: () =>
                                                            delAndReportReplyComm(model: model, context: context, reportC: reportC, newsId: widget.newsId, setState: setState, replyIndex: index))
                                                ],
                                              ),
                                            );
                                          })
                                    ],
                                  ))),
                        ]);
                      }));
                })));
  }

  Widget replyCommentView() {
    return BlocBuilder<CommentNewsCubit, CommentNewsState>(builder: (context, state) {
      if (state is CommentNewsFetchSuccess && state.commentNews.isNotEmpty) {
        return Padding(
            padding: const EdgeInsetsDirectional.only(top: 10.0, bottom: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                allReplyComView(state.commentNews[widget.replyComIndex]),
                replyComProfileWithCom(state.commentNews[widget.replyComIndex]),
                replyComSendReplyView(state.commentNews[widget.replyComIndex]),
                replyAllComListView(state.commentNews[widget.replyComIndex])
              ],
            ));
      }
      if (state is CommentNewsFetchFailure) {
        return Center(child: CustomTextLabel(text: state.errorMessage, textAlign: TextAlign.center));
      }
      //state is CommentNewsFetchInProgress || state is CommentNewsInitial
      return const Padding(padding: EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0), child: SizedBox.shrink());
    });
  }

  @override
  Widget build(BuildContext context) {
    return replyCommentView();
  }
}
