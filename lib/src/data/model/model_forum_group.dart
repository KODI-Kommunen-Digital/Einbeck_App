class ForumGroupModel {
  int? id;
  String? forumName;
  String? createdAt;
  String? description;
  String? image;
  int? isPrivate;
  bool? isJoined;

  ForumGroupModel(
      {this.id,
        this.forumName,
        this.createdAt,
        this.description,
        this.image,
        this.isPrivate,
      this.isJoined,});

  ForumGroupModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    forumName = json['forumName'];
    createdAt = json['createdAt'];
    description = json['description'];
    image = json['image'];
    isPrivate = json['isPrivate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id ?? '';
    data['forumName'] = forumName ?? '';
    data['createdAt'] = createdAt ?? '';
    data['description'] = description ?? '';
    data['image'] = image ?? '';
    data['isPrivate'] = isPrivate ?? 0;
    return data;
  }
}
