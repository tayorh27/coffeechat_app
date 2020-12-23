
import 'package:coffeechat_app/ListItem/CoffeeUsers.dart';

class SavedUsers {
  String id, uid, email, name, created_date;
  dynamic msgId;
  dynamic timestamp;
  CoffeeUsers user;

  SavedUsers(this.id, this.uid, this.email, this.name, this.msgId, this.created_date, this.timestamp, this.user);

  Map<String, dynamic> toJSON() {
    return {
      'id': id,
      'uid': uid,
      'email': email,
      'name': name,
      'msgId': msgId,
      'created_date': created_date,
      'timestamp': timestamp,
      'user': user.toJSON()
    };
  }

  SavedUsers.fromSnapshot(dynamic data) {
    id = data['id'];
    uid = data['uid'];
    email = data['email'];
    name = data['name'];
    msgId = data['msgId'];
    created_date = data['created_date'];
    timestamp = data['timestamp'];
    user = CoffeeUsers.fromSnapshot(data['user']);
  }
}