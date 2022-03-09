// To parse this JSON data, do
//
//     final provData = provDataFromJson(jsonString);

import 'dart:convert';

List<ProvData> provDataFromJson(String str) =>
    List<ProvData>.from(json.decode(str).map((x) => ProvData.fromJson(x)));

// String provDataToJson(List<ProvData> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ProvData {
  ProvData({
    this.provinsi,
    this.kasus,
    this.dirawat,
    this.sembuh,
    this.meninggal,
    this.lastDate,
    this.penambahan,
  });

  String? provinsi;
  int? kasus;
  int? dirawat;
  int? sembuh;
  int? meninggal;
  DateTime? lastDate;
  Penambahan? penambahan;

  factory ProvData.fromJson(Map<String, dynamic> json) => ProvData(
        provinsi: json["provinsi"],
        kasus: json["kasus"],
        dirawat: json["dirawat"],
        sembuh: json["sembuh"],
        meninggal: json["meninggal"],
        lastDate: DateTime.parse(json["last_date"]),
        penambahan: Penambahan.fromJson(json["penambahan"]),
      );

  // Map<String, dynamic> toJson() => {
  //     "provinsi": provinsi,
  //     "kasus": kasus,
  //     "dirawat": dirawat,
  //     "sembuh": sembuh,
  //     "meninggal": meninggal,
  //     "last_date": "${lastDate.year.toString().padLeft(4, '0')}-${lastDate.month.toString().padLeft(2, '0')}-${lastDate.day.toString().padLeft(2, '0')}",
  //     "penambahan": penambahan.toJson(),
  // };
}

class Penambahan {
  Penambahan({
    this.positif,
    this.sembuh,
    this.meninggal,
  });

  int? positif;
  int? sembuh;
  int? meninggal;

  factory Penambahan.fromJson(Map<String, dynamic> json) => Penambahan(
        positif: json["positif"],
        sembuh: json["sembuh"],
        meninggal: json["meninggal"],
      );

  Map<String, dynamic> toJson() => {
        "positif": positif,
        "sembuh": sembuh,
        "meninggal": meninggal,
      };
}
