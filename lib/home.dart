// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:tes_api/model/dailyCase.dart';
import 'package:tes_api/model/model.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:tes_api/model/provModel.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:get/get.dart';

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
  List<DailyCase> listDailyCase = [];
  List<ProvData> listProvinsi = [];

  Future getProv() async {
    try {
      var response = await http.get(Uri.parse(
          "https://apicovid19indonesia-v2.vercel.app/api/indonesia/provinsi/more"));
      listProvinsi = provDataFromJson(response.body);
      listProvinsi.sort((a, b) => a.provinsi!.compareTo(b.provinsi!));
    } catch (e) {
      toast(e.toString());
    }
  }

  Future getDaily() async {
    try {
      var response = await http.get(Uri.parse(
          "https://apicovid19indonesia-v2.vercel.app/api/indonesia/harian"));
      listDailyCase = listdailyCaseFromJson(response.body);

      await getProv();
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
                  getDaily();
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
            FutureBuilder(
              future: getDaily(),
              builder: (context, snapshot) =>
                  snapshot.connectionState == ConnectionState.waiting
                      // ? Center(child: CircularProgressIndicator())
                      ? ListView.builder(
                          itemCount: 10,
                          shrinkWrap: true,
                          physics: ScrollPhysics(),
                          itemBuilder: (c, i) => Shimmer.fromColors(
                              child: Card(
                                margin: EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                              ).withHeight(i == 0 ? 200 : 100),
                              baseColor: Colors.grey[400]!,
                              highlightColor: Colors.grey[100]!))
                      : Column(
                          children: [
                            SizedBox(height: 16),
                            NationalCard(
                              listDailyCase: listDailyCase,
                            ),
                            ProvinsiBody(listProvinsi: listProvinsi)
                          ],
                        ),
            ),
          ],
        ),
      )),
    );
  }
}

class ProvinsiBody extends StatefulWidget {
  ProvinsiBody({required this.listProvinsi});
  List<ProvData> listProvinsi;
  @override
  State<ProvinsiBody> createState() => _ProvinsiBodyState();
}

class _ProvinsiBodyState extends State<ProvinsiBody> {
  ProvData? selectedProvinsi;

  @override
  Widget build(BuildContext context) {
    List<ProvData> listProvinsi = widget.listProvinsi;
    return Column(
      children: [
        SizedBox(height: 16),
        DropdownSearch<ProvData>(
          showClearButton: true,
          dropdownSearchDecoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(8),
              labelText: "Select Province"),
          selectedItem: selectedProvinsi,
          onChanged: (value) => setState(() {
            selectedProvinsi = value;
          }),
          items: listProvinsi,
          itemAsString: (item) => item?.provinsi! ?? '',
        ),
        SizedBox(height: 16),
        selectedProvinsi == null
            ? ListView.builder(
                shrinkWrap: true,
                physics: ScrollPhysics(),
                itemCount: listProvinsi.length,
                itemBuilder: (context, index) {
                  return ProvCard(provData: listProvinsi[index]);
                })
            : ProvCard(provData: selectedProvinsi!),
      ],
    );
  }
}

class ProvCard extends StatelessWidget {
  ProvCard({required this.provData});
  ProvData provData;
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
            provData.provinsi ?? '',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
          ),
        ),
        children: [
          Divider(),
          Align(
            alignment: Alignment.centerLeft,
            child: Text("Case Detail"),
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
              "${formatDecimal(provData.kasus)} ",
              style: TextStyle(
                fontSize: 14,
              ),
            ),
            trailing: Card(
              color: (provData.penambahan!.positif ?? 0) > 0
                  ? Colors.redAccent[100]
                  : Colors.greenAccent,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  "${formatDecimal(provData.penambahan!.positif, plusMinus: true)} ",
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
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
              "${formatDecimal(provData.dirawat)} ",
              style: TextStyle(
                fontSize: 14,
              ),
            ),
            trailing: Card(
              color: (provData.penambahan!.positif ?? 0) -
                          (provData.penambahan!.sembuh ?? 0) >
                      0
                  ? Colors.redAccent[100]
                  : Colors.greenAccent,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  "${formatDecimal((provData.penambahan!.positif ?? 0) - (provData.penambahan!.sembuh ?? 0), plusMinus: true)} ",
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
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
              "${formatDecimal(provData.sembuh)} ",
              style: TextStyle(
                fontSize: 14,
              ),
            ),
            trailing: Card(
              color: (provData.penambahan!.sembuh ?? 0) < 0
                  ? Colors.redAccent[100]
                  : Colors.greenAccent,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  "${formatDecimal(provData.penambahan!.sembuh, plusMinus: true)} ",
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
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
              "${formatDecimal(provData.meninggal)} ",
              style: TextStyle(
                fontSize: 14,
              ),
            ),
            trailing: Card(
              color: (provData.penambahan!.meninggal ?? 0) > 0
                  ? Colors.redAccent[100]
                  : Colors.greenAccent,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  "${formatDecimal(provData.penambahan!.meninggal, plusMinus: true)} ",
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
          Divider(
            height: 8,
          ),
          Container(
            padding: EdgeInsets.all(16),
            alignment: Alignment.centerRight,
            child: Text(
              "Last updated : ${DateFormat("EEEEEE, d MMM y").format(provData.lastDate ?? DateTime.now())}",
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          )
        ],
      ),
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
