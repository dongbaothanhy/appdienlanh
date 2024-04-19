// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:news/ui/styles/colors.dart';
import 'package:news/ui/widgets/customTextBtn.dart';
import 'package:news/ui/widgets/customTextLabel.dart';
import 'package:news/utils/uiUtils.dart';
import 'package:news/app/routes.dart';
import 'package:news/cubits/settingCubit.dart';

class Slide {
  final String? imageUrl;
  final String? title;
  final String? description;

  Slide({@required this.imageUrl, @required this.title, @required this.description});
}

class IntroSliderScreen extends StatefulWidget {
  const IntroSliderScreen({super.key});

  @override
  GettingStartedScreenState createState() => GettingStartedScreenState();
}

class GettingStartedScreenState extends State<IntroSliderScreen> with TickerProviderStateMixin {
  PageController pageController = PageController();

  int currentIndex = 0;

  late List<Slide> slideList = [
    Slide(imageUrl: UiUtils.getSvgImagePath('onboarding1'), title: UiUtils.getTranslatedLabel(context, 'welTitle1'), description: UiUtils.getTranslatedLabel(context, 'welDes1')),
    Slide(imageUrl: UiUtils.getSvgImagePath('onboarding2'), title: UiUtils.getTranslatedLabel(context, 'welTitle2'), description: UiUtils.getTranslatedLabel(context, 'welDes2')),
    Slide(imageUrl: UiUtils.getSvgImagePath('onboarding3'), title: UiUtils.getTranslatedLabel(context, 'welTitle3'), description: UiUtils.getTranslatedLabel(context, 'welDes3')),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: nextButton(),
        appBar: AppBar(automaticallyImplyLeading: false, centerTitle: false, actions: [setSkipButton()], title: SvgPicture.asset(UiUtils.getSvgImagePath("intro_icon"), fit: BoxFit.cover)),
        body: _buildIntroSlider());
  }

  gotoNext() {
    context.read<SettingsCubit>().changeShowIntroSlider(false);
    Navigator.of(context).pushReplacementNamed(Routes.login);
  }

  void onPageChanged(int index) {
    setState(() {
      currentIndex = index; //update current index for Next button
    });
  }

  Widget _buildIntroSlider() {
    return PageView.builder(
        onPageChanged: onPageChanged,
        controller: pageController,
        itemBuilder: (context, index) {
          return Wrap(direction: Axis.vertical, children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.99,
              height: MediaQuery.of(context).size.height * 0.75,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateX(0.1),
                child: Stack(children: [
                  Positioned(
                      left: MediaQuery.of(context).size.width * 0.3,
                      right: MediaQuery.of(context).size.width * 0.3,
                      top: MediaQuery.of(context).size.height * 0.71,
                      child: Container(
                          decoration: BoxDecoration(
                              boxShadow: [BoxShadow(color: UiUtils.getColorScheme(context).primary.withOpacity(0.3), blurRadius: 20, spreadRadius: 5, offset: Offset.zero)], shape: BoxShape.rectangle),
                          height: 7)),
                  Card(
                    color: secondaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.0)),
                    elevation: 0,
                    margin: const EdgeInsets.fromLTRB(24, 30, 24, 20),
                    child: Column(
                      children: [
                        Expanded(child: Container(margin: const EdgeInsets.all(20), child: SvgPicture.asset(slideList[index].imageUrl!, fit: BoxFit.contain))),
                        titleText(index),
                        subtitleText(index),
                        progressIndicator(index),
                        const SizedBox(height: 25)
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          ]);
        },
        itemCount: slideList.length);
  }

  appbar() {
    return AppBar(automaticallyImplyLeading: false, centerTitle: false, actions: [setSkipButton()], title: SvgPicture.asset(UiUtils.getSvgImagePath("intro_icon"), fit: BoxFit.cover));
  }

  Widget setSkipButton() {
    return (currentIndex != slideList.length - 1)
        ? CustomTextButton(
            onTap: () {
              gotoNext();
            },
            color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.7),
            text: UiUtils.getTranslatedLabel(context, 'skip'))
        : const SizedBox.shrink();
  }

  Widget titleText(int index) {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 10),
      margin: const EdgeInsets.only(bottom: 20.0, left: 10, right: 10),
      alignment: Alignment.center,
      child: CustomTextLabel(text: slideList[index].title!, textStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(color: darkSecondaryColor, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
    );
  }

  Widget subtitleText(int index) {
    return Container(
        padding: const EdgeInsets.only(left: 10),
        margin: const EdgeInsets.only(bottom: 55.0, left: 10, right: 10),
        child: CustomTextLabel(
            text: slideList[index].description!,
            textAlign: TextAlign.left,
            textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(color: darkSecondaryColor.withOpacity(0.5), fontWeight: FontWeight.normal, letterSpacing: 0.5),
            maxLines: 3,
            overflow: TextOverflow.ellipsis));
  }

  Widget progressIndicator(int index) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List<Widget>.generate(
            slideList.length,
            (index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: InkWell(
                    onTap: () => pageController.animateToPage(index, duration: const Duration(seconds: 1), curve: Curves.fastLinearToSlowEaseIn),
                    child: (currentIndex == index)
                        ? ClipRRect(borderRadius: BorderRadius.circular(10.0), child: Container(height: 10, width: 40.0, color: darkSecondaryColor))
                        : CircleAvatar(radius: 5, backgroundColor: darkSecondaryColor.withOpacity(0.6))))));
  }

  Widget nextButton() {
    return MaterialButton(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.28, vertical: 20),
        onPressed: () {
          if (currentIndex == slideList.length - 1 && currentIndex != 0) {
            gotoNext();
          } else {
            currentIndex += 1;
            pageController.animateToPage(currentIndex, duration: const Duration(seconds: 1), curve: Curves.fastLinearToSlowEaseIn);
          }
        },
        child: Container(
            height: 50,
            width: 162,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(14)),
            child: CustomTextLabel(
                text: (currentIndex == (slideList.length - 1)) ? 'loginBtn' : 'nxt',
                textStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(color: secondaryColor, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center)));
  }
}
