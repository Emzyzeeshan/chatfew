import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class FullPhoto extends StatelessWidget {
final String url;
FullPhoto({required this.url});
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('hi'),
    );
  }
}

class FullPhotoScreen extends StatefulWidget {
  @override
  State createState() => FullPhotoScreenState();
}

class FullPhotoScreenState extends State<FullPhotoScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('hi'),
    );
  }
}
