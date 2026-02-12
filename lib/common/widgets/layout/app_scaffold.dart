import 'package:flutter/material.dart';

import '../../styles/app_sizes.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.body, super.key,
    this.title,
    this.actions = const <Widget>[],
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.padding,
    this.useSafeArea = true,
    this.resizeToAvoidBottomInset,
  });

  final String? title;
  final Widget body;
  final List<Widget> actions;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final EdgeInsetsGeometry? padding;
  final bool useSafeArea;
  final bool? resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    final Widget content = Padding(
      padding: padding ?? const EdgeInsets.all(AppSizes.spacingMd),
      child: body,
    );

    final Widget wrappedContent = useSafeArea
        ? SafeArea(child: content)
        : content;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: title == null
          ? null
          : AppBar(title: Text(title!), actions: actions),
      body: wrappedContent,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
