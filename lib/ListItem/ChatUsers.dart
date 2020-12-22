
import 'package:coffeechat_app/ListItem/CoffeeUsers.dart';

class ChatUsers {
  String id, created_date;
  dynamic timestamp;
  dynamic dates;
  String selected_date;
  String status;//pending,accepted(chat now button)
  CoffeeUsers user;

  ChatUsers(this.id, this.created_date, this.timestamp, this.dates, this.selected_date, this.status, this.user);

  Map<String, dynamic> toJSON() {
    return {
      'id': id,
      'created_date': created_date,
      'timestamp': timestamp,
      'dates': dates,
      'selected_date': selected_date,
      'status': status,
      'user': user.toJSON()
    };
  }

  ChatUsers.fromSnapshot(dynamic data) {
    id = data['id'];
    created_date = data['created_date'];
    timestamp = data['timestamp'];
    dates = data['dates'];
    selected_date = data['selected_date'];
    status = data['status'];
    user = CoffeeUsers.fromSnapshot(data['user']);
  }
}