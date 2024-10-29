import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class UploadPdfPage extends StatefulWidget {
  final String? filePath; // Menerima file path dari halaman lain jika ada

  const UploadPdfPage({Key? key, this.filePath}) : super(key: key);

  @override
  _UploadPdfPageState createState() => _UploadPdfPageState();
}

class _UploadPdfPageState extends State<UploadPdfPage> {
  String? localPath;

  @override
  void initState() {
    super.initState();
    if (widget.filePath != null && widget.filePath!.isNotEmpty) {
      // Jika file path disediakan dari luar, gunakan itu.
      setState(() {
        localPath = widget.filePath;
      });
    } else {
      // Jika tidak ada file path yang diberikan, gunakan PDF dari folder assets.
      preparePdf();
    }
  }

  // Fungsi untuk menyalin file PDF dari folder assets ke direktori sementara agar bisa dibaca
  Future<void> preparePdf() async {
    try {
      final ByteData data = await rootBundle.load('assets/sertif2.pdf');
      final Directory tempDir = await getTemporaryDirectory();
      final File tempFile = File('${tempDir.path}/sertif.pdf');
      await tempFile.writeAsBytes(data.buffer.asUint8List(), flush: true);

      setState(() {
        localPath = tempFile.path;
      });
    } catch (e) {
      // Menangani kesalahan jika terjadi saat menyalin file
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyiapkan PDF: $e')),
      );
    }
  }

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
      body: localPath != null
          ? PDFView(
              filePath: localPath!,
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
