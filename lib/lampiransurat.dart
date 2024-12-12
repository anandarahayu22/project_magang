import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class LampiranSuratPage extends StatelessWidget {
  final String nomorSurat;

  LampiranSuratPage({Key? key, required this.nomorSurat}) : super(key: key);

  Future<void> _downloadAndOpenPDF(BuildContext context) async {
    try {
      final String pdfUrl =
          'http://192.168.30.238:8000/uploads/surat_masuk/$nomorSurat.pdf';

      // Mendapatkan direktori sementara
      final dir = await getTemporaryDirectory();
      final filePath = "${dir.path}/lampiran_surat_$nomorSurat.pdf";

      // Cek apakah URL dapat dijangkau dengan menggunakan Dio
      Dio dio = Dio();
      Response response = await dio.get(pdfUrl);

      if (response.statusCode == 200) {
        // Mengunduh file PDF
        await dio.download(pdfUrl, filePath);
        // Membuka file PDF yang sudah diunduh
        await OpenFile.open(filePath);
      } else {
        throw Exception('File PDF tidak ditemukan di server.');
      }
    } catch (e) {
      // Menampilkan error yang lebih detail
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lampiran Surat',
          style: TextStyle(color: Colors.white, fontSize: 25),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nomor Surat: $nomorSurat',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16.0),
            Text(
              'Ini adalah halaman untuk menampilkan lampiran surat.',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _downloadAndOpenPDF(
                    context); // Panggil fungsi untuk download dan membuka PDF
              },
              child: Text('Lihat Lampiran PDF'),
            ),
          ],
        ),
      ),
    );
  }
}
