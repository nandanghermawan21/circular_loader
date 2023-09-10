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
  final Color color = Colors.blue;
  final TextStyle? loadingMessageStyle;
  final Alignment laodingAlign = Alignment.bottomCenter;
  final EdgeInsetsGeometry? laodingMargin;
  final Decoration? loadingDecoration;
  final Widget? loadingWidget;
  final Color? laodingBackgroundColor;
  final Alignment errorMessageAlign = Alignment.center;
  final double? errorMessageWidth;
  final ObjectBuilder<Widget>? errorMessageWidget;
  final Decoration? errorMessageDecoration;
  final Alignment successMessageAlign = Alignment.center;
  final double? successMessageWidth;
  final ObjectBuilder<Widget>? successMessageWidget;
  final Decoration? successMessageDecoration;

  const CircularLoaderComponent({
    Key? key,
    required this.controller,
    this.child,
    this.cover = true,
    this.loadingBuilder,
    this.loadingDecoration,
    this.loadingWidget,
    this.laodingBackgroundColor,
    this.errorMessageDecoration,
    this.errorMessageWidget,
    this.loadingMessageStyle = const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
    ),
    this.successMessageWidget,
    this.successMessageDecoration,
    this.successMessageWidth = 400,
    this.errorMessageWidth = 400,
    this.laodingMargin =
        const EdgeInsets.only(bottom: 100, left: 10, right: 10, top: 10),
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
      alignment: successMessageAlign,
      child: Container(
        margin: const EdgeInsets.only(left: 40, right: 40),
        padding: const EdgeInsets.all(15),
        width: 400,
        decoration: successMessageDecoration ??
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
          child: successMessageWidget != null
              ? successMessageWidget?.call()
              : centerStyleMessageMode(controller),
        ),
      ),
    );
  }

  Widget messageError(BuildContext context) {
    controller.value.message ?? "Error";
    return Align(
      alignment: errorMessageAlign,
      child: Container(
        margin: const EdgeInsets.only(left: 40, right: 40),
        padding: const EdgeInsets.all(15),
        width: errorMessageWidth,
        decoration: errorMessageDecoration ??
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
        child: Material(
          child: IntrinsicHeight(
            child: errorMessageWidget != null
                ? errorMessageWidget?.call()
                : centerStyleErrorMode(controller),
          ),
        ),
      ),
    );
  }

  static centerStyleErrorMode(CircularLoaderController controller) {
    return Column(
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
    );
  }

  static centerStyleMessageMode(CircularLoaderController controller) {
    return Column(
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
    Icon? icon,
    Duration? duration,
    VoidCallback? onCloseCallBack,
    Widget? messageWidget,
  }) {
    value.onclosed = false;
    onCloseCallback = onCloseCallBack;
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
}

enum CircularLoaderState {
  idle,
  onLoading,
  showError,
  showMessage,
}

typedef ObjectBuilder<T> = T Function();
