
class CoffeeUsers {
  String id,created_date,email,firstname,lastname,picture,bio,zoomID,zoomPassword,status;
  bool blocked;
  dynamic msgId, timestamp, prefs;

  Map<String, dynamic> toJSON() {
    return {
      'id': id,
      'created_date': created_date,
      'email': email,
      'firstname': firstname,
      'lastname': lastname,
      'picture': picture,
      'bio': bio,
      'zoomID': zoomID,
      'zoomPassword': zoomPassword,
      'blocked': blocked,
      'msgId': msgId,
      'timestamp': timestamp,
      'prefs': prefs,
      'status': status
    };
  }

  CoffeeUsers.fromSnapshot(dynamic data) {
    id = data['id'];
    created_date = data['created_date'];
    email = data['email'];
    firstname = data['firstname'];
    lastname = data['lastname'];
    picture = data['picture'];
    bio = data['bio'];
    zoomID = data['zoomID'];
    zoomPassword = data['zoomPassword'];
    blocked = data['blocked'];
    msgId = data['msgId'];
    timestamp = data['timestamp'];
    prefs = data['prefs'];
    status = data['status'];
  }
}