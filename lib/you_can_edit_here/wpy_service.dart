import 'package:dio/dio.dart';
import 'package:twt_mobile_assignment1/things_you_do_not_need_understand/wpy_network.dart';
import 'package:twt_mobile_assignment1/things_you_do_not_need_understand/wpy_storage.dart';
import 'package:twt_mobile_assignment1/you_can_edit_here/post.dart';

/// 我们使用 Dio —— 一个网络请求库来进行网络请求。
/// 要想查看我们都使用了哪些库，可以打开 lib 文件夹下的 pubspec.yaml
final feedbackDio = FeedbackDio(); //可以点进去看看

class FeedbackService with AsyncTimer {
  /// 这个是用账号密码获取 token 的接口
  ///
  /// 接口就是前端和后端进行联系的通道,
  /// token 则是用来识别用户身份的凭证。
  /// 在微北洋里，一切的请求都需要携带 token，
  /// 不过我们已经在 DioAbstract() 类中帮你提前写好了。
  /// 所以你无需单独传入 token 就可以与微北洋的服务器通信！
  ///
  /// 不过在调用之前请在下面填入你的微北洋账号和密码
  static getTokenByPassword({
    required OnSuccess onSuccess,
    required OnFailure onFailure,
  }) async {
    var user = '这里写下你的学号';
    var passwd = '这里写下你的微北洋密码';
    try {
      // response 就是 dio 库 从服务器获得的数据，我们就可以从里面拿到服务器返回的 token 了
      var response =
          // 我们要在这里做请求，请求类型是 get。具体 http 的请求类型大家可以自行搜索
          await feedbackDio.get('auth/passwd', queryParameters: {
        // 这里就是我们的请求参数，就是把你的账号和密码提供给服务器
        'user': user,
        'password': passwd,
      });
      // 我们请求到的一串东西（response.data）其实是 json 字符串。
      // 请务必了解 json 是什么再接着看！！！
      // 请务必了解 json 是什么再接着看！！！
      // 请务必了解 json 是什么再接着看！！！
      // 请务必了解 json 是什么再接着看！！！
      // 请务必了解 json 是什么再接着看！！！
      // 请务必了解 json 是什么再接着看！！！
      // 请务必了解 json 是什么再接着看！！！
      // 请务必了解 json 是什么再接着看！！！
      // 请务必了解 json 是什么再接着看！！！
      // 请务必了解 json 是什么再接着看！！！

      // 我们可以简单地使用 json['条目名称'] 来访问 json 中存放的数值
      // 我们可以简单地使用 json['条目名称'] 来访问 json 中存放的数值
      // 我们可以简单地使用 json['条目名称'] 来访问 json 中存放的数值
      if (response.data['data']['token'] != null)
        // 这里的 CommonPreference 是 flutter 应用持久化保存数据的主要方式
        // 这里我们把 lakeToken 的值替换成了请求到的 token 值，可以尝试 print 一下
        // 请按住 Ctrl 并点击 CommonPreferences 继续查看
        CommonPreferences.lakeToken.value = response.data['data']['token'];
      onSuccess();
    } on DioError catch (e) {
      if (onFailure != null) onFailure(e);
    }
  }

  // 请确保你已经完成上面的阅读后再继续编辑！！！
  // 请确保你已经完成上面的阅读后再继续编辑！！！
  // 请确保你已经完成上面的阅读后再继续编辑！！！
  // 请确保你已经完成上面的阅读后再继续编辑！！！
  // 请确保你已经完成上面的阅读后再继续编辑！！！
  // 请确保你已经完成上面的阅读后再继续编辑！！！
  // 请确保你已经完成上面的阅读后再继续编辑！！！
  // 请确保你已经完成上面的阅读后再继续编辑！！！
  // 请确保你已经完成上面的阅读后再继续编辑！！！
  // 请确保你已经完成上面的阅读后再继续编辑！！！
  // 请确保你已经完成上面的阅读后再继续编辑！！！
  // 请确保你已经完成上面的阅读后再继续编辑！！！

  // 接下来我们要获取微北洋论坛的帖子
  // 请调用这个函数，并查看服务器返回了什么
  // [!] 在调用这个之前请先请求 token！！！
  static getPosts() async {
    var response = await feedbackDio.get(
      'posts',
      queryParameters: {
        // 里面的参数先这么填，你可以修改一下看看返回是否会不一样

        // 这个是返回什么种类的帖子，目前是返回【湖底】部分的帖子
        // 0 代表精华帖，1 代表校务帖子
        'type': '2',
        'search_mode': 0,
        'etag': '',
        'content': '',
        'tag_id': '',
        'department_id': '',

        // 我们采取分页获取帖子，现在是一次获取十条。
        'page_size': '10',

        // 这个是获取第几页的帖子，第一次填 0 就可以了，后续我们要在每次调用的时候给他加一
        'page': '0',
      },
    );

    // 这个 Post 是一个对于每个帖子各种数据的半成品的模板类，我们通过他来处理比较复杂的 json 数据。
    // 在大家之前阅读返回的 json 的时候应该已经发现返回的东西非常多，
    // 所以像上一个请求一样解析字符串就会十分麻烦且不优雅。
    // 通过 Post, 我们就可以通过 Post.id 类似的方式调用帖子的属性。

    // 这是一个由 Post 组成的列表，这个函数的目的就是向服务器请求帖子并返回他们，
    // 所以我们将从返回的 json 数据中获取 Post 组成的列表并返回他
    // 但是我们的 Post 是不完整的，请按住 Ctrl 并点击 Post 去完善它
    List<Post> list = [];
    for (Map<String, dynamic> json in response.data['data']['list']) {
      list.add(Post.fromJson(json));
    }
    return list;
  }
}
