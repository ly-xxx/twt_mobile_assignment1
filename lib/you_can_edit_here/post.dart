import 'dart:convert';

Post postFromJson(String str) => Post.fromJson(json.decode(str));

String postToJson(Post data) => json.encode(data.toJson());

// 请根据 json 数据里面的项目完善它
class Post {
  Post({
    required this.id,
    required this.title,
    required this.content
  });

  int id;
  String title;
  String content;

  bool operator ==(Object other) => other is Post && other.id == id;

  factory Post.fromJson(Map<String, dynamic> json) => Post(
        id: json["id"],
        title: json["title"],
        content: json["content"]
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "content": content,
      };
}
