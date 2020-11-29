class CoffeeJoin {
  String id,
      coffee_id,
      user_id,
      name,
      email,
      picture;
  dynamic msgId;
  dynamic timestamp;

  CoffeeJoin(this.id, this.coffee_id, this.user_id, this.name, this.email, this.picture, this.msgId, this.timestamp);

  Map<String, dynamic> toJSON() {
    return {
      'id':id,
      'coffee_id':coffee_id,
      'user_id':user_id,
      'name':name,
      'email':email,
      'picture':picture,
      'msgId':msgId,
      'timestamp':timestamp,
    };
  }
}


