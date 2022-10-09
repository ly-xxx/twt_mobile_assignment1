import 'package:flutter/material.dart';
import 'package:twt_mobile_assignment1/you_can_edit_here/post.dart';

class PostCard extends StatefulWidget {
  final Post post;

  const PostCard(this.post, {Key? key}) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: 100,
        width: double.infinity,
        color: Colors.red,
        child: Text(widget.post.id.toString()));
  }
}
