import 'package:flutter/material.dart';

class UserPage extends StatefulWidget {
  static const routeName = "/userPage";

  final int userId;

  const UserPage(this.userId, {Key? key}) : super(key: key);

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
