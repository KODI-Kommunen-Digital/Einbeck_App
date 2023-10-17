class ForumGroupModel {
  int? id;
  String? forumName;
  String? createdAt;
  String? description;
  String? image;
  int? isPrivate;
  int? cityId;
  bool? isJoined;
  bool? isRequested;

  ForumGroupModel(
      {this.id,
      this.forumName,
      this.createdAt,
      this.description,
      this.image,
      this.isPrivate,
      this.cityId,
      this.isJoined,
      this.isRequested});

  ForumGroupModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    forumName = json['forumName'];
    createdAt = json['createdAt'];
    description = json['description'];
    image = json['image'] ?? 'admin/DefaultForum.jpeg';
    isPrivate = json['isPrivate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id ?? '';
    data['forumName'] = forumName ?? '';
    data['createdAt'] = createdAt ?? '';
    data['description'] = description ?? '';
    data['image'] = image ?? 'admin/DefaultForum.jpeg';
    data['isPrivate'] = isPrivate ?? 0;
    return data;
  }
}
