class Coffee {
  String id,
      user_id,
      name,
      avatar,
      title,
      description,
      zoom_invite,
      access_type,
      start_date,
      end_date;
  dynamic msgIds;
  dynamic images;
  String created_date;
  dynamic timestamp;
  int total_users, total_comments;
  dynamic link;


  Coffee(this.id, this.user_id, this.name, this.avatar, this.title, this.description, this.zoom_invite,
      this.access_type, this.start_date, this.end_date, this.msgIds, this.images, this.created_date, this.timestamp, this.total_users, this.total_comments, this.link);

  Map<String, dynamic> toJSON() {
    return {
      'id': id,
      'user_id': user_id,
      'name': name,
      'avatar': avatar,
      'title': title,
      'description': description,
      'zoom_invite': zoom_invite,
      'access_type': access_type,
      'start_date': start_date,
      'end_date': end_date,
      'msgIds': msgIds,
      'images': images,
      // 'profile_image_url': profile_image_url,
      // 'entry_mode': entry_mode,
      'created_date': created_date,
      'timestamp': timestamp,
      'total_users': total_users,
      'total_comments': total_comments,
      'link': link
    };
  }

  Coffee.fromSnapshot(dynamic data) {
    id = data['id'];
    user_id = data['user_id'];
    name = data['name'];
    avatar = data['avatar'];
    title = data['title'];
    description = data['description'];
    zoom_invite = data['zoom_invite'];
    access_type = data['access_type'];
    start_date = data['start_date'];
    end_date = data['end_date'];
    msgIds = data['msgIds'];
    images = data['images'];
    created_date = data['created_date'];
    timestamp = data['timestamp'];
    total_users = data['total_users'];
    total_comments = data['total_comments'];
    link = data['link'];
  }

}