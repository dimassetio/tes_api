// To parse this JSON data, do
//
//     final dailyCase = dailyCaseFromJson(jsonString);

import 'dart:convert';

List<DailyCase> listdailyCaseFromJson(String str) =>
    List<DailyCase>.from(json.decode(str).map((x) => DailyCase.fromJson(x)));

String listdailyCaseToJson(List<DailyCase> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

DailyCase dailyCaseFromJson(String str) => DailyCase.fromJson(json.decode(str));

String dailyCaseToJson(DailyCase data) => json.encode(data.toJson());

class DailyCase {
  DailyCase({
    this.positif,
    this.dirawat,
    this.sembuh,
    this.meninggal,
    this.positifKumulatif,
    this.dirawatKumulatif,
    this.sembuhKumulatif,
    this.meninggalKumulatif,
    this.lastUpdate,
    this.tanggal,
  });

  int? positif;
  int? dirawat;
  int? sembuh;
  int? meninggal;
  int? positifKumulatif;
  int? dirawatKumulatif;
  int? sembuhKumulatif;
  int? meninggalKumulatif;
  int? lastUpdate;
  DateTime? tanggal;

  factory DailyCase.fromJson(Map<String, dynamic> json) => DailyCase(
        positif: json["positif"],
        dirawat: json["dirawat"],
        sembuh: json["sembuh"],
        meninggal: json["meninggal"],
        positifKumulatif: json["positif_kumulatif"],
        dirawatKumulatif: json["dirawat_kumulatif"],
        sembuhKumulatif: json["sembuh_kumulatif"],
        meninggalKumulatif: json["meninggal_kumulatif"],
        lastUpdate: json["lastUpdate"],
        tanggal: DateTime.parse(json["tanggal"]),
      );

  Map<String, dynamic> toJson() => {
        "positif": positif,
        "dirawat": dirawat,
        "sembuh": sembuh,
        "meninggal": meninggal,
        "positif_kumulatif": positifKumulatif,
        "dirawat_kumulatif": dirawatKumulatif,
        "sembuh_kumulatif": sembuhKumulatif,
        "meninggal_kumulatif": meninggalKumulatif,
        "lastUpdate": lastUpdate,
        "tanggal": tanggal?.toIso8601String(),
      };
}
