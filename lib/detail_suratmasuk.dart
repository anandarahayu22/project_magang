import 'dart:io';
import 'dart:convert';
import 'editsurat.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class DetailSuratMasukPage extends StatefulWidget {
  final String nomorSurat;
  final String pengirim;
  final String tujuan;
  final String perihal;
  final String tanggalSurat;
  final String tanggalTerima;
  final String? filePath;

  DetailSuratMasukPage({
    Key? key,
    required this.nomorSurat,
    required this.pengirim,
    required this.tujuan,
    required this.perihal,
    required this.tanggalSurat,
    required this.tanggalTerima,
    this.filePath,
  }) : super(key: key);

  @override
  _DetailSuratMasukPageState createState() => _DetailSuratMasukPageState();
}

class _DetailSuratMasukPageState extends State<DetailSuratMasukPage> {
  late String nomorSurat;
  late String pengirim;
  late String tujuan;
  late String perihal;
  late String tanggalSurat;
  late String tanggalTerima;
  String? filePath;

  @override
  void initState() {
    super.initState();
    nomorSurat = widget.nomorSurat;
    pengirim = widget.pengirim;
    tujuan = widget.tujuan;
    perihal = widget.perihal;
    tanggalSurat = widget.tanggalSurat;
    tanggalTerima = widget.tanggalTerima;
    filePath = widget.filePath;
  }

  Future<void> _openPDF(BuildContext context) async {
    if (filePath != null && filePath!.isNotEmpty) {
      String fullFileUrl =
          'http://192.168.102.246:8000/storage/uploads/surat/$filePath';
      print('Mengakses URL: $fullFileUrl');

      try {
        var response = await http.get(Uri.parse(fullFileUrl));
        if (response.statusCode == 200) {
          final dir = await getApplicationDocumentsDirectory();
          final file = File('${dir.path}/document.pdf');
          await file.writeAsBytes(response.bodyBytes);

          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PDFViewer(filePath: file.path)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Gagal mengunduh file PDF, status: ${response.statusCode}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuka file PDF: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tidak ada file PDF yang diunggah')),
      );
    }
  }

  void _editSurat(BuildContext context) async {
    var updatedData = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditSuratPage(
          nomorSurat: nomorSurat,
          pengirim: pengirim,
          tujuan: tujuan,
          perihal: perihal,
          tanggalSurat: tanggalSurat,
          tanggalTerima: tanggalTerima,
          filePath: filePath,
        ),
      ),
    );

    if (updatedData != null) {
      setState(() {
        // Update data surat yang ditampilkan
        nomorSurat = updatedData['nomor_surat'];
        pengirim = updatedData['pengirim'];
        tujuan = updatedData['tujuan'];
        perihal = updatedData['perihal'];
        tanggalSurat = updatedData['tanggal_surat'];
        tanggalTerima = updatedData['tanggal_terima'];
        filePath = updatedData['file_surat'];
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Surat berhasil diperbarui')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detail Surat Masuk',
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
            Text('Nomor Surat: $nomorSurat', style: TextStyle(fontSize: 18)),
            SizedBox(height: 16.0),
            Text('Pengirim: $pengirim', style: TextStyle(fontSize: 18)),
            SizedBox(height: 16.0),
            Text('Tujuan: $tujuan', style: TextStyle(fontSize: 18)),
            SizedBox(height: 16.0),
            Text('Perihal: $perihal', style: TextStyle(fontSize: 18)),
            SizedBox(height: 16.0),
            Text('Tanggal Surat: $tanggalSurat',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 16.0),
            Text('Tanggal Terima: $tanggalTerima',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 16.0),
            Text(
              'File Surat: ${filePath?.isNotEmpty == true ? filePath!.split('/').last : "Tidak ada file yang diunggah"}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => _openPDF(context),
              child: Text('Lihat File PDF'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => _editSurat(context),
              child: Text('Edit Surat'),
            ),
          ],
        ),
      ),
    );
  }
}

class PDFViewer extends StatelessWidget {
  final String filePath;

  const PDFViewer({Key? key, required this.filePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lihat PDF',
          style: TextStyle(color: Colors.white, fontSize: 25),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.blueGrey,
      ),
      body: PDFView(
        filePath: filePath,
      ),
    );
  }
}
