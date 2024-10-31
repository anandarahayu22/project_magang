import 'login.dart';
import 'dart:convert';
import 'profile.dart';
import 'tambahsurat.dart';
import 'detail_suratmasuk.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DashboardPage extends StatefulWidget {
  final Function onLogout;

  DashboardPage({required this.onLogout});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<dynamic> _suratMasukList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSuratMasuk();
  }

  Future<void> _fetchSuratMasuk() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.102.246:8000/api/surat_masuks'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _suratMasukList = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      print('Error fetching data: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    int totalSurat = _suratMasukList.length;
    int suratBelumDibuka = _suratMasukList
        .where((surat) => surat['status'] == 'Belum Dibuka')
        .length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SURAT DISPOSISI',
          style: TextStyle(color: Colors.white, fontSize: 25),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
        automaticallyImplyLeading: false,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                SizedBox(height: 16.0),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(right: 4.0),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          height: 100.0,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Surat Masuk',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                                SizedBox(height: 8.0),
                                Text(
                                  '$totalSurat',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 23),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(left: 4.0),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          height: 100.0,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Surat belum dibuka',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                                SizedBox(height: 8.0),
                                Text(
                                  '$suratBelumDibuka',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 23),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _suratMasukList.length,
                    itemBuilder: (context, index) {
                      final surat = _suratMasukList[index];
                      return Column(
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailSuratMasukPage(
                                    nomorSurat: surat['nomor_surat'],
                                    pengirim: surat['pengirim'],
                                    tujuan: surat['tujuan'],
                                    perihal: surat['perihal'],
                                    tanggalSurat: surat['tanggal_surat'],
                                    tanggalTerima: surat['tanggal_terima'],
                                    filePath: surat['file_surat'],
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              color: Colors.white,
                              padding: EdgeInsets.symmetric(
                                  vertical: 12.0, horizontal: 16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.grey,
                                    child: Icon(
                                      Icons.email,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 16.0),
                                  Expanded(
                                    child: Text(
                                      surat['tujuan'],
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          surat['perihal'],
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                        SizedBox(height: 4.0),
                                        Text(
                                          surat['pengirim'],
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Divider(
                            color: Colors.grey, // Warna garis pemisah
                            thickness: 1.0, // Ketebalan garis pemisah
                            indent: 16.0, // Jarak dari kiri
                            endIndent: 16.0, // Jarak dari kanan
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  TambahSuratPage(onDataAdded: _fetchSuratMasuk),
            ),
          );
        },
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.blueGrey,
      ),
    );
  }
}
