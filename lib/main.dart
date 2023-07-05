import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'header_content.dart';
import 'list_jadwal.dart';
import 'model/jadwal.dart';
import 'model/lokasi.dart';

// dap baru ngerti gww/ itu salah karena package model beserta isinya gw copy bukan dari json/ok// ajarin gw cara dapetin jsonnya daff

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Jadwal Sholat',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomeScreen(),
    );
  }
}

class MyHomeScreen extends StatefulWidget {
  @override
  _MyHomeScreenState createState() => _MyHomeScreenState();
}

class _MyHomeScreenState extends State<MyHomeScreen> {
  String? lokasiPilihan;

  Future<JadwalShalat> getJadwal({String? idLokasi}) async {
    // idLokasi ??= "1208";
    Uri url =
        Uri.parse('https://api.myquran.com/v1/sholat/jadwal/$idLokasi/2023/06');

    print(url);
    final response = await http.get(url);
    Map<String, dynamic> jsonResponse = json.decode(response.body)['data'];
    JadwalShalat result = JadwalShalat.fromJson(jsonResponse);

    return result;
  }

  Future<List<Lokasi>> getLokasi() async {
    Uri url = Uri.parse('https://api.myquran.com/v1/sholat/kota/semua');
    final response = await http.get(url);
    List jsonResponse = json.decode(response.body);
    List<Lokasi> result = jsonResponse.map((e) => Lokasi.fromJson(e)).toList();

    return result;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var header = Stack(
      children: <Widget>[
        Container(
          height: MediaQuery.of(context).size.width - 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30.0),
                bottomRight: Radius.circular(30.0)),
            boxShadow: [
              BoxShadow(
                blurRadius: 6,
                offset: Offset(0.0, 2.0),
                color: Colors.black26,
              ),
            ],
            image: DecorationImage(
              fit: BoxFit.cover,
              image: NetworkImage(
                  'https://cdn.pixabay.com/photo/2019/07/30/08/44/mosque-4372296_1280.jpg'),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Tooltip(
                message: 'Ubah Lokasi',
                child: CircleAvatar(
                  child: IconButton(
                      color: Colors.white,
                      icon: Icon(Icons.location_on),
                      onPressed: () {
                        _showDialogLocation(context);
                      }),
                ),
              ),
            ],
          ),
        ),
        FutureBuilder(
          future: getJadwal(idLokasi: lokasiPilihan),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasData) {
              return HeaderContent(snapshot.data);
            } else {
              return HeaderContent(
                JadwalShalat(lokasi: "Cari Lokasi", daerah: "Cari Daerah"),
              );
            }
          },
        )
      ],
    );
    return Scaffold(
      body: Column(
        children: <Widget>[
          header,
          FutureBuilder(
            future: getJadwal(idLokasi: lokasiPilihan),
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasData) {
                return Expanded(child: ListJadwal(snapshot.data));
              }
              return Container(
                height: 400,
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.gps_fixed,
                      size: 40,
                    ),
                    Text(
                      "Silahkan cari lokasi",
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              );
            },
          )
        ],
      ),
    );
  }

  _showDialogLocation(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Ubah Lokasi'),
            content: FutureBuilder<List<Lokasi>>(
                future: getLokasi(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return DropdownButton<String>(items: [], onChanged: (v) {});
                  }
                  return DropdownButton<String>(
                    value: lokasiPilihan,
                    items: snapshot.data!
                        .map((e) => DropdownMenuItem<String>(
                              value: e.id,
                              child: Text(e.lokasi!),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        lokasiPilihan = value;
                        getJadwal(idLokasi: value);
                      });
                      print(lokasiPilihan);
                    },
                  );
                }),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
          );
        });
  }
}
