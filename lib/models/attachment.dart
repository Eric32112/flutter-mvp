class Attachment {
  Attachment({
    this.type,
    this.url,
  });

  final String type;
  final String url;

  Attachment copyWith({
    String type,
    String url,
  }) =>
      Attachment(
        type: type ?? this.type,
        url: url ?? this.url,
      );

  factory Attachment.fromJson(Map<String, dynamic> json) => Attachment(
        type: json["type"] == null ? null : json["type"],
        url: json["url"] == null ? null : json["url"],
      );

  Map<String, dynamic> toJson() => {
        "type": type == null ? null : type,
        "url": url == null ? null : url,
      };
}
