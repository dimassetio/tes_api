// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tes_api/model.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  RawData raw = RawData();
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
              future: getData(),
              builder: (context, snapshot) =>
                  snapshot.connectionState == ConnectionState.waiting
                      ? Center(child: CircularProgressIndicator())
                      : Column(
                          children: [
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
            provData.key!,
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
              "${provData.docCount} (+${provData.penambahan?.positif ?? 0})",
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
              provData.status!.buckets!
                  .firstWhere(
                      (element) => element.key == StatusKey.DALAM_PERAWATAN,
                      orElse: () =>
                          Bucket(key: StatusKey.DALAM_PERAWATAN, docCount: 0))
                  .docCount
                  .toString(),
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
              "${provData.status!.buckets!.firstWhere((element) => element.key == StatusKey.SEMBUH, orElse: () => Bucket(key: StatusKey.SEMBUH, docCount: 0)).docCount} (+${provData.penambahan?.sembuh ?? 0})",
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
              "${provData.status!.buckets!.firstWhere((element) => element.key == StatusKey.MENINGGAL, orElse: () => Bucket(key: StatusKey.MENINGGAL, docCount: 0)).docCount} (+${provData.penambahan!.meninggal ?? 0})",
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
