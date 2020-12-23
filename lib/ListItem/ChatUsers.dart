
import 'package:coffeechat_app/ListItem/CoffeeUsers.dart';

class ChatUsers {
  String id, uid, email, name, created_date;
  dynamic msgId;
  dynamic timestamp;
  dynamic dates;
  String selected_date;
  String request_to;
  String status;//pending,accepted(chat now button)
  CoffeeUsers user;

  ChatUsers(this.id, this.uid, this.email, this.name, this.msgId, this.created_date, this.timestamp, this.dates, this.selected_date, this.status, this.user, this.request_to);

  Map<String, dynamic> toJSON() {
    return {
      'id': id,
      'uid': uid,
      'email': email,
      'name': name,
      'msgId': msgId,
      'created_date': created_date,
      'timestamp': timestamp,
      'dates': dates,
      'selected_date': selected_date,
      'status': status,
      'user': user.toJSON(),
      'request_to': request_to
    };
  }

  ChatUsers.fromSnapshot(dynamic data) {
    id = data['id'];
    uid = data['uid'];
    email = data['email'];
    name = data['name'];
    msgId = data['msgId'];
    created_date = data['created_date'];
    timestamp = data['timestamp'];
    dates = data['dates'];
    selected_date = data['selected_date'];
    status = data['status'];
    user = CoffeeUsers.fromSnapshot(data['user']);
    request_to = data['request_to'];
  }
}