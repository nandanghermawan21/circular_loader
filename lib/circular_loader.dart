library circular_loader;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_super_html_viewer/flutter_super_html_viewer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CircularLoaderComponent extends StatelessWidget {
  final CircularLoaderController controller;
  final Widget? child;
  final bool cover;
  final ObjectBuilder<Widget>? loadingBuilder;
  final Color color;
  final TextStyle loadingMessageStyle;
  final Alignment laodingAlign;
  final EdgeInsetsGeometry laodingMargin;
  final Decoration? loadingDecoration;
  final Widget? loadingWidget;
  final Color? laodingBackgroundColor;
  //mode message success
  final Alignment? successMessageAlign;
  final WidgetFromDataBuilder<CircularLoaderController>? successMessageBuilder;
  //mode messae error
  final Alignment? errorMessageAlign;
  final WidgetFromDataBuilder<CircularLoaderController>? errorMessageBuilder;

  const CircularLoaderComponent({
    Key? key,
    required this.controller,
    this.child,
    this.cover = true,
    this.laodingMargin = const EdgeInsets.all(20),
    this.loadingBuilder,
    this.loadingDecoration,
    this.loadingWidget,
    this.laodingBackgroundColor,
    this.loadingMessageStyle = const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    this.laodingAlign = Alignment.center,
    this.color = Colors.blue,
    this.successMessageAlign,
    this.successMessageBuilder =
        CircularLoaderComponent.messageSuccessModalMode,
    this.errorMessageAlign,
    this.errorMessageBuilder = CircularLoaderComponent.messageErrorModalMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<CircularLoaderValue>(
      valueListenable: controller,
      builder: (ctx, value, widget) {
        return GestureDetector(
          onTap: () {
            controller.close();
          },
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.transparent,
            child: Stack(
              children: [
                child ?? const SizedBox(),
                Container(
                  color: (cover && value.state != CircularLoaderState.idle) ==
                          false
                      ? null
                      : Colors.grey.shade400.withOpacity(0.6),
                  child: childBuilder(context, value.state),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget childBuilder(BuildContext context, CircularLoaderState state) {
    switch (state) {
      case CircularLoaderState.idle:
        return const SizedBox();
      case CircularLoaderState.onLoading:
        return loadingBuilder == null ? onLoading() : loadingBuilder!();
      case CircularLoaderState.showError:
        return messageError(context);
      case CircularLoaderState.showMessage:
        return message(context);
    }
  }

  Widget onLoading() {
    return Center(
      child: Align(
        alignment: laodingAlign,
        child: Container(
          margin: laodingMargin,
          decoration: loadingDecoration ??
              BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(5)),
                border: Border.all(
                  color: Colors.grey,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade400,
                    blurRadius: 5,
                    offset: const Offset(2, 2),
                  )
                ],
              ),
          child: IntrinsicHeight(
            child: Material(
              color: laodingBackgroundColor ?? Colors.transparent,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  loadingWidget ??
                      Container(
                        height: 50,
                        width: 50,
                        padding: const EdgeInsets.all(10),
                        color: Colors.transparent,
                        child: CircularProgressIndicator(
                          color: color,
                          strokeWidth: 4,
                        ),
                      ),
                  controller.value.loadingMessage != null &&
                          controller.value.loadingMessage != ""
                      ? Container(
                          margin: const EdgeInsets.all(10),
                          child: Text(
                            controller.value.loadingMessage ?? "",
                            style: loadingMessageStyle,
                          ),
                        )
                      : const SizedBox()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget message(BuildContext context) {
    return Align(
      alignment: successMessageAlign ?? Alignment.center,
      child: SafeArea(
          child: successMessageBuilder?.call(controller) ?? const SizedBox()),
    );
  }

  static Widget messageSuccessModalMode(CircularLoaderController controller) {
    return Container(
      margin: const EdgeInsets.only(left: 40, right: 40),
      padding: const EdgeInsets.all(15),
      width: 400,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        border: Border.all(
          color: Colors.grey,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade400,
            blurRadius: 5,
            offset: const Offset(2, 2),
          )
        ],
      ),
      child: IntrinsicHeight(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            controller.value.icon ??
                const Icon(
                  FontAwesomeIcons.checkCircle,
                  color: Colors.green,
                  size: 50,
                ),
            const SizedBox(
              height: 20,
            ),
            !controller.value.message!.contains("<div")
                ? Material(
                    child: Text(
                      controller.value.message ?? "Error",
                      textAlign: TextAlign.center,
                    ),
                  )
                : Material(
                    child: Container(
                      height: 300,
                      color: Colors.transparent,
                      child: SingleChildScrollView(
                        child: HtmlContentViewer(
                          htmlContent: controller.value.message ?? "",
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  static Widget messageSuccessNotifMode(
    CircularLoaderController controller, {
    Color? backgroundColor,
    TextStyle? textStyle,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      width: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color.fromARGB(255, 15, 130, 3),
      ),
      child: IntrinsicHeight(
        child: !controller.value.message!.contains("<div")
            ? Material(
                color: Colors.transparent,
                child: Text(
                  controller.value.message ?? "Error",
                  textAlign: TextAlign.center,
                  style: textStyle ??
                      const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.normal),
                ),
              )
            : Material(
                color: Colors.transparent,
                child: Container(
                  height: 300,
                  color: Colors.transparent,
                  child: SingleChildScrollView(
                    child: HtmlContentViewer(
                      htmlContent: controller.value.message ?? "",
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget messageError(BuildContext context) {
    controller.value.message ?? "Error";
    return Align(
      alignment: errorMessageAlign ?? Alignment.center,
      child: SafeArea(
          child: errorMessageBuilder?.call(controller) ?? const SizedBox()),
    );
  }

  static Widget messageErrorModalMode(CircularLoaderController controller) {
    return Container(
      margin: const EdgeInsets.only(left: 40, right: 40),
      padding: const EdgeInsets.all(15),
      width: 400,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        border: Border.all(
          color: Colors.grey,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade400,
            blurRadius: 5,
            offset: const Offset(2, 2),
          )
        ],
      ),
      child: Material(
        child: IntrinsicHeight(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              controller.value.icon ??
                  const Icon(
                    FontAwesomeIcons.timesCircle,
                    color: Colors.red,
                    size: 50,
                  ),
              const SizedBox(
                height: 20,
              ),
              controller.value.messageWidget != null
                  ? controller.value.messageWidget!
                  : !controller.value.message!.contains("<div")
                      ? Text(
                          controller.value.message ?? "Error",
                          textAlign: TextAlign.center,
                        )
                      : Material(
                          child: Container(
                            height: 300,
                            color: Colors.transparent,
                            child: SingleChildScrollView(
                              child: HtmlContentViewer(
                                htmlContent: controller.value.message ?? "",
                              ),
                            ),
                          ),
                        ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget messageErrorNotifMode(
    CircularLoaderController controller, {
    Color? backgroundColor,
    TextStyle? textStyle,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      width: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color.fromARGB(255, 243, 5, 5),
      ),
      child: IntrinsicHeight(
        child: !controller.value.message!.contains("<div")
            ? Material(
                color: Colors.transparent,
                child: Text(
                  controller.value.message ?? "Error",
                  textAlign: TextAlign.center,
                  style: textStyle ??
                      const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.normal),
                ),
              )
            : Material(
                color: Colors.transparent,
                child: Container(
                  height: 300,
                  color: Colors.transparent,
                  child: SingleChildScrollView(
                    child: HtmlContentViewer(
                      htmlContent: controller.value.message ?? "",
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class CircularLoaderController extends ValueNotifier<CircularLoaderValue> {
  CircularLoaderController({CircularLoaderValue? value})
      : super(value ?? CircularLoaderValue());

  VoidCallback? onCloseCallback;

  void startLoading({
    String? message,
  }) {
    value.onclosed = false;
    value.state = CircularLoaderState.onLoading;
    value.loadingMessage = message;
    commit();
  }

  void stopLoading({
    String? message,
    bool isError = false,
    bool? cover,
    Icon? icon,
    Duration? duration,
    VoidCallback? onCloseCallBack,
    Widget? messageWidget,
  }) {
    value.onclosed = false;
    value.onCloseCallback = onCloseCallBack;
    value.state = isError == true
        ? CircularLoaderState.showError
        : CircularLoaderState.showMessage;

    if (duration != null) {
      Timer.periodic(duration, (timer) {
        timer.cancel();
        if (onCloseCallback != null) {
          onCloseCallback!();
        }
        close();
      });
    }

    value.message = message;
    value.icon = icon;
    value.messageWidget = messageWidget;

    commit();
  }

  void forceStop({String? message}) {
    value.message = message;
    value.messageWidget = null;
    value.onclosed = true;
    value.state = CircularLoaderState.idle;
    commit();
  }

  void close() {
    if (value.state == CircularLoaderState.onLoading) return;
    value.state = CircularLoaderState.idle;
    if (onCloseCallback != null && value.onclosed == false) {
      value.onclosed = true;
      onCloseCallback!();
    }
    value.onclosed = true;
    commit();
  }

  bool get onLoading {
    if (value.state == CircularLoaderState.onLoading) {
      return true;
    } else {
      return false;
    }
  }

  void commit() {
    notifyListeners();
  }
}

class CircularLoaderValue {
  CircularLoaderState state = CircularLoaderState.idle;
  String? message;
  Icon? icon;
  Widget? messageWidget;
  String? loadingMessage;
  bool onclosed = true;
  VoidCallback? onCloseCallback;
}

enum CircularLoaderState {
  idle,
  onLoading,
  showError,
  showMessage,
}

typedef ObjectBuilder<T> = T Function();
typedef WidgetFromDataBuilder<T> = Widget Function(T value);
