class ChatUser {
  ChatUser({
    required this.email,
    required this.image,
    required this.name,
    required this.id,
    required this.about,
    required this.isOnline,
    required this.lastActive,
    required this.pushToken,
    required this.createdAt,
  });
  late  String email;
  late  String image;
  late  String name;
  late  String id;
  late  String about;
  late  bool isOnline;
  late  String lastActive;
  late  String pushToken;
  late  String createdAt;

  ChatUser.fromJson(Map<String, dynamic> json){
    email = json['email'] ?? '';
    image = json['image'] ?? '';
    name = json['name'] ?? '';
    id = json['id'] ?? '';
    about = json['about'] ?? '';
    isOnline = json['is_online'] ?? false;
    lastActive = json['last_active'] ?? '';
    pushToken = json['push_token'] ?? '';
    createdAt = json['created_at'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['email'] = email;
    _data['image'] = image;
    _data['name'] = name;
    _data['id'] = id;
    _data['about'] = about;
    _data['is_online'] = isOnline;
    _data['last_active'] = lastActive;
    _data['push_token'] = pushToken;
    _data['created_at'] = createdAt;
    return _data;
  }
}