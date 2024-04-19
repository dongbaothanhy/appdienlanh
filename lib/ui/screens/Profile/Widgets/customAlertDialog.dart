// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:news/ui/widgets/customTextLabel.dart';
import 'package:news/utils/uiUtils.dart';

class CustomAlertDialog extends StatelessWidget {
  final BuildContext context;
  final String yesButtonText;
  final String yesButtonTextPostfix;
  final String noButtonText;
  final String imageName;
  final Widget titleWidget;
  final String messageText;
  final Function() onYESButtonPressed;
  const CustomAlertDialog(
      {super.key,
      required this.context,
      required this.yesButtonText,
      required this.yesButtonTextPostfix,
      required this.noButtonText,
      required this.imageName,
      required this.titleWidget,
      required this.messageText,
      required this.onYESButtonPressed});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(20),
      backgroundColor: UiUtils.getColorScheme(context).background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(UiUtils.getSvgImagePath(imageName)),
          const SizedBox(height: 15),
          titleWidget,
          const SizedBox(height: 5),
          CustomTextLabel(text: messageText, textAlign: TextAlign.center, textStyle: Theme.of(this.context).textTheme.titleMedium?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer)),
        ],
      ),
      actionsAlignment: MainAxisAlignment.spaceAround,
      actions: <Widget>[
        MaterialButton(
          minWidth: MediaQuery.of(context).size.width / 3.5,
          elevation: 0.0,
          color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.4),
          splashColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          onPressed: () => Navigator.of(context).pop(false),
          child: CustomTextLabel(text: noButtonText, textStyle: Theme.of(this.context).textTheme.titleSmall?.copyWith(color: UiUtils.getColorScheme(context).background, fontWeight: FontWeight.w500)),
        ),
        MaterialButton(
            minWidth: MediaQuery.of(context).size.width / 3.5,
            elevation: 0.0,
            color: UiUtils.getColorScheme(context).primaryContainer,
            splashColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            onPressed: onYESButtonPressed,
            child: RichText(
              text: TextSpan(
                  text: UiUtils.getTranslatedLabel(context, yesButtonText),
                  style: Theme.of(this.context).textTheme.titleSmall?.copyWith(color: UiUtils.getColorScheme(context).background, fontWeight: FontWeight.w500),
                  children: [
                    const TextSpan(text: " , "),
                    TextSpan(
                        text: UiUtils.getTranslatedLabel(context, yesButtonTextPostfix),
                        style: Theme.of(this.context).textTheme.titleSmall?.copyWith(color: UiUtils.getColorScheme(context).background, fontWeight: FontWeight.w500))
                  ]),
            )),
      ],
    );
  }
}
