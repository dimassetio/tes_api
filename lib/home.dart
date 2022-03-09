// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:tes_api/dailyCase.dart';
import 'package:tes_api/model.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

String formatDecimal(var number, {bool plusMinus = false}) {
  String res = NumberFormat.decimalPattern('id').format(number);
  if (number is num && plusMinus) {
    return number < 0 ? res : "+$res";
  }
  return res;
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  RawData raw = RawData();
  List<DailyCase> listDailyCase = [];

  // listDailyCase.firstWhere((element) => element.tanggal == today,
  //     orElse: () => DailyCase());
  Future getData() async {
    var res = await http
        .get(Uri.parse("https://data.covid19.go.id/public/api/prov_list.json"));
    raw = RawData.fromJson(jsonDecode(res.body));
    if (raw.listData != null) {
      raw.listData!.sort((a, b) => a.key!.compareTo(b.key!));
    }
    // setState(() {});
    return raw;
  }

  int active() {
    int total = 0;
    int total1 = 0;
    raw.listData?.forEach((element) {
      total = total + (element.docCount ?? 0);
      total1 = total1 + (element.status?.buckets?[0].docCount ?? 0);
    });
    print("Total = $total");
    print("Total1 = $total1");
    return total;
  }

  Future getDaily() async {
    try {
      var response = await http.get(Uri.parse(
          "https://apicovid19indonesia-v2.vercel.app/api/indonesia/harian"));
      listDailyCase = listdailyCaseFromJson(response.body);
      await getData();
    } on Exception catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("INFO COVID INDONESIA"),
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  getData();
                  getDaily();
                  print("total = ${active()}");
                });
              },
              icon: Icon(Icons.refresh))
        ],
      ),
      body: SingleChildScrollView(
          child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // FutureBuilder(
            //   future: getDaily(),
            //   builder: (context, s) =>
            //       s.connectionState == ConnectionState.waiting
            //           ? Shimmer.fromColors(
            //               baseColor: Colors.grey[400]!,
            //               highlightColor: Colors.grey[100]!,
            //               child: NationalCard(dailyCase: dailyCase),
            //             )
            //           : NationalCard(dailyCase: dailyCase),
            // ),
            FutureBuilder(
              future: getDaily(),
              builder: (context, snapshot) =>
                  snapshot.connectionState == ConnectionState.waiting
                      // ? Center(child: CircularProgressIndicator())
                      ? ListView.builder(
                          itemCount: 10,
                          shrinkWrap: true,
                          itemBuilder: (c, i) => Shimmer.fromColors(
                              child: ItemCard(ListDatum()),
                              baseColor: Colors.grey[400]!,
                              highlightColor: Colors.grey[100]!))
                      : Column(
                          children: [
                            SizedBox(height: 16),
                            NationalCard(
                              listDailyCase: listDailyCase,
                            ),
                            SizedBox(height: 16),
                            Container(
                              alignment: Alignment.centerLeft,
                              margin: EdgeInsets.all(8),
                              child: Text(
                                "Last Updated : ${raw.lastDate != null ? DateFormat('EEEEEE, d MMM y').format(raw.lastDate!) : ''}",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                            ListView.builder(
                                shrinkWrap: true,
                                physics: ScrollPhysics(),
                                itemCount: raw.listData?.length ?? 0,
                                itemBuilder: (context, index) {
                                  ListDatum provData = raw.listData![index];
                                  return ItemCard(provData);
                                }),
                          ],
                        ),
            ),
          ],
        ),
      )),
    );
  }
}

class NationalCard extends StatefulWidget {
  NationalCard({required this.listDailyCase});
  final List<DailyCase> listDailyCase;

  @override
  _NationalCardState createState() => _NationalCardState();
}

class _NationalCardState extends State<NationalCard> {
  // final DailyCase dailyCase;
  DateTime now = DateTime.now();
  DateTime get today => DateTime(now.year, now.month, now.day);
  DailyCase get dailyCase => widget.listDailyCase.isNotEmpty
      ? widget.listDailyCase.firstWhere(
          (element) =>
              DateFormat("EEEEEE, d MMM y").format(element.tanggal!) ==
              DateFormat("EEEEEE, d MMM y").format(today),
          orElse: () => widget.listDailyCase.last)
      : DailyCase();
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        margin: EdgeInsets.all(16),
        child: Column(
          children: [
            Text("National Case"),
            Divider(),
            ListTile(
              onTap: () async {
                now = await showDatePicker(
                        context: context,
                        initialDate: dailyCase.tanggal ??
                            widget.listDailyCase.last.tanggal ??
                            DateTime.now(),
                        firstDate: widget.listDailyCase.first.tanggal ??
                            DateTime.now(),
                        lastDate: widget.listDailyCase.last.tanggal ??
                            DateTime.now()) ??
                    now;
                setState(() {});
              },
              leading: IconButton(
                  onPressed: () => setState(() {
                        DateTime res = now.add(Duration(days: -1));
                        if (!res.isBefore(widget.listDailyCase.first.tanggal ??
                            DateTime.now())) now = res;
                      }),
                  icon: Icon(Icons.chevron_left)),
              trailing: IconButton(
                  onPressed: () => setState(() {
                        DateTime res = now.add(Duration(days: 1));
                        if (!res.isAfter(widget.listDailyCase.last.tanggal ??
                            DateTime.now())) now = res;
                      }),
                  icon: Icon(Icons.chevron_right)),
              title: Align(
                alignment: Alignment.center,
                child: Text(
                  dailyCase.tanggal != null
                      ? DateFormat("EEEEEE, d MMM y").format(dailyCase.tanggal!)
                      : '',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.coronavirus,
                color: Colors.blue,
              ),
              title: Text(
                "All Case",
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
              subtitle: Text(
                "${formatDecimal(dailyCase.positifKumulatif)} ",
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
              trailing: Card(
                color: (dailyCase.positif ?? 0) > 0
                    ? Colors.redAccent[100]
                    : Colors.greenAccent,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    "${formatDecimal(dailyCase.positif, plusMinus: true)} ",
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
            Divider(height: 0),
            ListTile(
              leading: Icon(
                Icons.add_circle_outline,
                color: Colors.amber,
              ),
              title: Text(
                "Active Case",
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
              subtitle: Text(
                "${formatDecimal(dailyCase.dirawatKumulatif)} ",
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
              trailing: Card(
                color: (dailyCase.dirawat ?? 0) > 0
                    ? Colors.redAccent[100]
                    : Colors.greenAccent,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    "${formatDecimal(dailyCase.dirawat, plusMinus: true)} ",
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
            Divider(height: 0),
            ListTile(
              leading: Icon(
                Icons.arrow_circle_up_outlined,
                color: Colors.green,
              ),
              title: Text(
                "Cured",
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
              subtitle: Text(
                "${formatDecimal(dailyCase.sembuhKumulatif)} ",
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
              trailing: Card(
                color: (dailyCase.sembuh ?? 0) <= 0
                    ? Colors.redAccent[100]
                    : Colors.greenAccent,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    "${formatDecimal(dailyCase.sembuh, plusMinus: true)} ",
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
            Divider(height: 0),
            ListTile(
              leading: Icon(
                Icons.coronavirus,
                color: Colors.red,
              ),
              title: Text(
                "Death",
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
              subtitle: Text(
                "${formatDecimal(dailyCase.meninggalKumulatif)} ",
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
              trailing: Card(
                color: (dailyCase.meninggal ?? 0) > 0
                    ? Colors.redAccent[100]
                    : Colors.greenAccent,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    "${formatDecimal(dailyCase.meninggal, plusMinus: true)} ",
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ItemCard extends StatelessWidget {
  ItemCard(this.provData);

  ListDatum provData;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        tilePadding: EdgeInsets.all(16),
        childrenPadding: EdgeInsets.symmetric(horizontal: 16),
        title: Center(
          child: Text(
            provData.key ?? '',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
          ),
        ),
        // SizedBox(
        //   height: 8,
        // ),
        // Text(
        //   "${provData.docCount} (+${provData.penambahan?.positif})",
        //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        // ),

        children: [
          Divider(),
          Align(
            alignment: Alignment.centerLeft,
            child: Text("Case Detail"),
          ),
          ListTile(
            leading: Icon(
              Icons.coronavirus_outlined,
              color: Colors.blue,
            ),
            title: Text(
              "All Case",
              style: TextStyle(
                fontSize: 12,
              ),
            ),
            subtitle: Text(
              "${provData.docCount}",
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.add_circle_outline,
              color: Colors.amber,
            ),
            title: Text(
              "Active Case",
              style: TextStyle(
                fontSize: 12,
              ),
            ),
            subtitle: Text(
              "${provData.status?.buckets?.firstWhere((element) => element.key == StatusKey.DALAM_PERAWATAN, orElse: () => Bucket(key: StatusKey.DALAM_PERAWATAN, docCount: 0)).docCount}  (+${provData.penambahan?.positif ?? 0})",
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.arrow_circle_up_outlined,
              color: Colors.green,
            ),
            title: Text(
              "Cured",
              style: TextStyle(
                fontSize: 12,
              ),
            ),
            subtitle: Text(
              "${provData.status?.buckets?.firstWhere((element) => element.key == StatusKey.SEMBUH, orElse: () => Bucket(key: StatusKey.SEMBUH, docCount: 0)).docCount} (+${provData.penambahan?.sembuh ?? 0})",
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.coronavirus,
              color: Colors.red,
            ),
            title: Text(
              "Death",
              style: TextStyle(
                fontSize: 12,
              ),
            ),
            subtitle: Text(
              "${provData.status?.buckets?.firstWhere((element) => element.key == StatusKey.MENINGGAL, orElse: () => Bucket(key: StatusKey.MENINGGAL, docCount: 0)).docCount} (+${provData.penambahan?.meninggal ?? 0})",
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
