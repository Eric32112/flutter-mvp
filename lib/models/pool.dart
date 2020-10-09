class Pool {
  Pool({
    this.question,
    this.id,
    this.endsAt,
    this.answers,
  });

  final String question;
  final String id;
  final String endsAt;
  final List<Answer> answers;

  Pool copyWith({
    String question,
    String id,
    String endsAt,
    List<Answer> answers,
  }) =>
      Pool(
        question: question ?? this.question,
        id: id ?? this.id,
        endsAt: endsAt ?? this.endsAt,
        answers: answers ?? this.answers,
      );

  factory Pool.fromJson(Map<String, dynamic> json) => Pool(
        question: json["question"] == null ? null : json["question"],
        id: json["id"] == null ? null : json["id"],
        endsAt: json["endsAt"] == null ? null : json["endsAt"],
        answers: json["answers"] == null
            ? []
            : List<Answer>.from(json["answers"].map((x) => Answer.fromJson(x))),
      );

  dynamic toJson() => {
        "question": question == null ? null : question,
        "id": id == null ? null : id,
        "endsAt": endsAt == null ? null : endsAt,
        "answers": answers == null ? null : List<dynamic>.from(answers.map((e) => e.toJson())),
      };

  List<String> get vattedUsers =>
      answers.map((a) => a.selectedBy).toList().reduce((value, element) => [...value, ...element]);
}

class Answer {
  Answer({
    this.selectedBy,
    this.value,
    this.id,
  });

  final List<String> selectedBy;
  final String value;
  final int id;

  Answer copyWith({
    List<String> selectedBy,
    String value,
    int id,
  }) =>
      Answer(
        selectedBy: selectedBy ?? this.selectedBy,
        value: value ?? this.value,
        id: id ?? this.id,
      );

  factory Answer.fromJson(dynamic json) => Answer(
        selectedBy:
            json["selectedBy"] == null ? [] : List<String>.from(json["selectedBy"].map((x) => x)),
        value: json["value"] == null ? null : json["value"],
        id: json["id"] == null ? null : json["id"],
      );

  Map<String, dynamic> toJson() => {
        "selectedBy": selectedBy == null ? [] : List<dynamic>.from(selectedBy.map((x) => x)),
        "value": value == null ? null : value,
        "id": id == null ? null : id,
      };
}
