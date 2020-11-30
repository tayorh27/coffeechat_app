class CoffeeComment {
  String id,
      coffee_id,
      user_id,
      name,
      email,
      picture,
      message, created_date;
  dynamic msgId;
  dynamic timestamp;

  CoffeeComment(this.id, this.coffee_id, this.user_id, this.name, this.email, this.picture, this.message, this.created_date, this.msgId, this.timestamp);

  Map<String, dynamic> toJSON() {
    return {
      'id':id,
      'coffee_id':coffee_id,
      'user_id':user_id,
      'name':name,
      'email':email,
      'picture':picture,
      'message':message,
      'created_date':created_date,
      'msgId':msgId,
      'timestamp':timestamp,
    };
  }

  CoffeeComment.fromSnapshot(dynamic data) {
    id = data['id'];
    coffee_id = data['coffee_id'];
    user_id = data['user_id'];
    name = data['name'];
    email = data['email'];
    picture = data['picture'];
    message = data['message'];
    created_date = data['created_date'];
    msgId = data['msgId'];
    timestamp = data['timestamp'];
  }
}


