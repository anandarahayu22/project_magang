import 'dart:convert';
import 'detail_suratmasuk.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SuratMasukList extends StatefulWidget {
  @override
  _SuratMasukListState createState() => _SuratMasukListState();
}

class _SuratMasukListState extends State<SuratMasukList> {
  List<dynamic> _suratMasukList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSuratMasuk();
  }

  Future<void> _fetchSuratMasuk() async {
    try {
      final response = await http
          .get(Uri.parse('http://192.168.62.246:8000/api/surat_masuks'));
      // .get(Uri.parse('http://192.168.0.104:8000/api/surat_masuks'));

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Daftar Surat Masuk',
          style: TextStyle(color: Colors.white, fontSize: 25),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.blueGrey,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _suratMasukList.length,
              itemBuilder: (context, index) {
                final surat = _suratMasukList[index];
                return ListTile(
                  title: Text(surat['nomor_surat']),
                  subtitle: Text(surat['pengirim']),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/detail_suratmasuk',
                      arguments: {
                        'nomorSurat': surat['nomor_surat'],
                        'pengirim':
                            surat['pengirim'], // Menambahkan argumen pengirim
                        'tujuan': surat['tujuan'], // Menambahkan argumen tujuan
                        'perihal':
                            surat['perihal'], // Menambahkan argumen perihal
                        'tanggalSurat': surat[
                            'tanggal_surat'], // Menambahkan argumen tanggal surat
                        'tanggalTerima': surat[
                            'tanggal_terima'], // Menambahkan argumen tanggal terima
                        'filePath': surat[
                            'file_surat'], // Menambahkan argumen file surat
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}
