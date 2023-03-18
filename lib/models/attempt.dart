class Attempt {
  String? csiId;
  String? passcode;

  Attempt({this.csiId, this.passcode});

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = <String, dynamic>{};

    json["csiId"] = csiId;
    json["passcode"] = passcode;

    return json;
  }
}
