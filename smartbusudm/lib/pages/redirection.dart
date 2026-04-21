import 'package:flutter/material.dart';

class _RedirectionState extends StatefulWidget {
  const _RedirectionState();

  @override
  State<_RedirectionState> createState() => __RedirectionStateState();
}

class __RedirectionStateState extends State<_RedirectionState> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar:AppBar(
        title: Text("redirection"),
      ),
      body: Center(
        child: Text("redirection page "),
      ),
    );
  }
}