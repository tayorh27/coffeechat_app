
import 'package:coffeechat_app/ListItem/CoffeeUsers.dart';

class SavedUsers {
  String id, created_date;
  dynamic timestamp;
  CoffeeUsers user;

  SavedUsers(this.id, this.created_date, this.timestamp, this.user);

  Map<String, dynamic> toJSON() {
    return {
      'id': id,
      'created_date': created_date,
      'timestamp': timestamp,
      'user': user.toJSON()
    };
  }

  SavedUsers.fromSnapshot(dynamic data) {
    id = data['id'];
    created_date = data['created_date'];
    timestamp = data['timestamp'];
    user = CoffeeUsers.fromSnapshot(data['user']);
  }
}