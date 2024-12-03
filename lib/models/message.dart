class Message {
  Message({
    required this.read,
    required this.told,
    required this.message,
    required this.type,
    required this.sent,
    required this.fromId,
  });
  late final String read;
  late final String told;
  late final String message;
  late final Type type;
  late final String sent;
  late final String fromId;

  Message.fromJson(Map<String, dynamic> json){
    read = json['read'].toString();
    told = json['told'].toString();
    message = json['message'].toString();
    type = json['type'].toString() == Type.image.name ? Type.image : Type.text ;
    sent = json['sent'].toString();
    fromId = json['fromId'].toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['read'] = read;
    data['told'] = told;
    data['message'] = message;
    data['type'] = type.name;
    data['sent'] = sent;
    data['fromId'] = fromId;
    return data;
  }


}
enum Type{text , image}