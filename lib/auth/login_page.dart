import 'package:flutter/material.dart';
import 'package:get_it_mixin/get_it_mixin.dart';

class LoginPage extends StatefulWidget with GetItStatefulWidgetMixin {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with GetItStateMixin<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}