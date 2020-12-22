class Coffee {
  String id,
      user_id,
      name,
      avatar,
      title,
      description,
      zoom_invite,
      access_type,
      meeting_id,
      meeting_pwd,
      interest;
  dynamic msgIds;
  dynamic images;
  String created_date;
  dynamic timestamp;
  int total_users, total_comments;
  dynamic link;


  Coffee(this.id, this.user_id, this.name, this.avatar, this.title, this.description, this.zoom_invite,
      this.access_type, this.interest, this.meeting_id, this.meeting_pwd, this.msgIds, this.images, this.created_date, this.timestamp, this.total_users, this.total_comments, this.link);

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
      'start_date': interest,
      'start_date': meeting_id,
      'start_date': meeting_pwd,
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
    interest = data['interest'];
    meeting_id = data['meeting_id'];
    meeting_pwd = data['meeting_pwd'];
    msgIds = data['msgIds'];
    images = data['images'];
    created_date = data['created_date'];
    timestamp = data['timestamp'];
    total_users = data['total_users'];
    total_comments = data['total_comments'];
    link = data['link'];
  }

}