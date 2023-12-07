// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

import 'chatgpt.dart';

class ChatGptSheetBottomSheet extends StatefulWidget {
  final ScrollController scrollController;
  List<String> recentList;
  ChatGptSheetBottomSheet({super.key, required this.recentList, required this.scrollController});

  @override
  State<ChatGptSheetBottomSheet> createState() => _ChatGptSheetBottomSheetState();
}

class _ChatGptSheetBottomSheetState extends State<ChatGptSheetBottomSheet> {
  TextEditingController promptCont = TextEditingController();
  TextEditingController answerCont = TextEditingController();

  bool displayGeneratedText = false;
  bool isTextAnimationCompleted = false;
  bool isLoading = false;

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: context.height() * 0.04),
            decoration: boxDecorationWithRoundedCorners(borderRadius: radiusOnly(topLeft: defaultRadius, topRight: defaultRadius), backgroundColor: context.scaffoldBackgroundColor),
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                SingleChildScrollView(
                  controller: widget.scrollController,
                  physics: NeverScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Generate using AI", style: boldTextStyle(color: context.primaryColor, size: 16)).expand(),
                          CloseButton(color: context.primaryColor),
                        ],
                      ),
                      AppTextField(
                        textFieldType: TextFieldType.MULTILINE,
                        controller: promptCont,
                        decoration: defaultInputDecoration(hint: "write text here..."),
                      ),
                      32.height,
                      Column(
                        children: [
                          AppButton(
                            text: answerCont.text.isNotEmpty ? "Re-generate" : "Generate",
                            color: context.primaryColor,
                            textStyle: boldTextStyle(color: white),
                            width: context.width(),
                            onTap: () {
                              handleGenerateClick(context);
                            },
                          ),
                          16.height,
                          if (isTextAnimationCompleted)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(context.primaryColor.withOpacity(0.1)), padding: MaterialStatePropertyAll(EdgeInsets.symmetric(horizontal: 12, vertical: 2))),
                                  onPressed: () {
                                    finish(context, answerCont.text);
                                  },
                                  child: Text(
                                    "Use This",
                                    style: boldTextStyle(color: context.primaryColor),
                                  ),
                                ),
                                TextButton(
                                  style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(context.primaryColor.withOpacity(0.1)), padding: MaterialStatePropertyAll(EdgeInsets.symmetric(horizontal: 12, vertical: 2))),
                                  onPressed: () {
                                    finish(context, promptCont.text);
                                  },
                                  child: Text(
                                    "Use my text",
                                    style: boldTextStyle(color: context.primaryColor),
                                  ),
                                ),
                              ],
                            ),
                          16.height,
                          isLoading
                              ? autoTypingView(context)
                              : Container(
                                  padding: EdgeInsets.all(8),
                                  width: context.width(),
                                  decoration: boxDecorationWithRoundedCorners(borderRadius: radius(defaultRadius), backgroundColor: displayGeneratedText ? context.primaryColor.withOpacity(0.1) : transparentColor),
                                  child: DefaultTextStyle(
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                    child: AnimatedTextKit(
                                      repeatForever: false,
                                      totalRepeatCount: 1,
                                      isRepeatingAnimation: false,
                                      onFinished: () {
                                        if (!isTextAnimationCompleted) {
                                          widget.recentList.insert(0, answerCont.text);
                                        }
                                        isTextAnimationCompleted = true;
                                        setState(() {});
                                      },
                                      animatedTexts: [
                                        TypewriterAnimatedText(answerCont.text, speed: Duration(milliseconds: isTextAnimationCompleted ? 0 : 30)),
                                      ],
                                    ),
                                  ).visible(displayGeneratedText),
                                ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              16.height,
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Recents", style: boldTextStyle(color: context.primaryColor, size: 16)),
                                  IconButton(
                                    icon: Icon(Icons.clear_all_rounded, color: context.primaryColor),
                                    onPressed: () async {
                                      showConfirmDialogCustom(
                                        context,
                                        onAccept: (_) async {
                                          widget.recentList.clear();
                                          setState(() {});
                                        },
                                        primaryColor: context.primaryColor,
                                        negativeText: "No",
                                        positiveText: "Yes",
                                        title: "Do you want to clear recents?",
                                      );
                                    },
                                  ),
                                ],
                              ),
                              Container(
                                height: context.height() * 0.42,
                                child: AnimatedListView(
                                  shrinkWrap: true,
                                  itemCount: widget.recentList.take(6).length,
                                  physics: AlwaysScrollableScrollPhysics(),
                                  listAnimationType: ListAnimationType.FadeIn,
                                  itemBuilder: (BuildContext context, int index) {
                                    return GestureDetector(
                                      onTap: () {
                                        finish(context, widget.recentList[index]);
                                      },
                                      behavior: HitTestBehavior.translucent,
                                      child: Container(
                                        margin: EdgeInsets.only(bottom: 12),
                                        padding: EdgeInsets.all(8),
                                        decoration: boxDecorationWithRoundedCorners(borderRadius: radius(defaultRadius), backgroundColor: context.primaryColor.withOpacity(0.05)),
                                        child: ReadMoreText(
                                          widget.recentList[index],
                                          trimLines: 3,
                                          textAlign: TextAlign.left,
                                          style: secondaryTextStyle(size: 14),
                                          colorClickableText: context.primaryColor,
                                          trimMode: TrimMode.Line,
                                          locale: Localizations.localeOf(context),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ).visible(widget.recentList.isNotEmpty)
                        ],
                      )
                    ],
                  ),
                ).expand(),
              ],
            ),
          ).expand(),
        ],
      ),
    );
  }

  void handleGenerateClick(BuildContext context) async {
    if (isLoading || (answerCont.text.isNotEmpty && !isTextAnimationCompleted)) {
      toast("Please wait while it's generating content!");
      return;
    }
    if (promptCont.text.isEmpty) {
      toast("Please enter some text about, which type of content you want to generate!");
      return;
    }
    hideKeyboard(context);
    isLoading = true;
    displayGeneratedText = false;
    isTextAnimationCompleted = false;
    setState(() {});

    generateWithChatGpt("${promptCont.text} \n Make this proper ", showDebugLogs: true).then((value) async {
      isLoading = false;
      if (value.$2) {
        answerCont.text = value.$1.trim();
        await 350.milliseconds.delay;
        displayGeneratedText = true;
        setState(() {});
      } else {
        toast(value.$1);
      }
    });
  }
}
