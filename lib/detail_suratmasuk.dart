import 'dart:io';
import 'dart:convert';
import 'dart:developer';
import 'editsurat.dart';
import 'editdisposisi.dart';
import 'createdisposisi.dart';
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
  final int idSurat;
  final String? filePath;

  DetailSuratMasukPage({
    Key? key,
    required this.nomorSurat,
    required this.pengirim,
    required this.tujuan,
    required this.perihal,
    required this.tanggalSurat,
    required this.tanggalTerima,
    required this.idSurat,
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

  List disposisiList = [];

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

    log("idSurat = ${widget.idSurat}");

    fetchDisposisi(); // Ambil disposisi saat halaman diinisialisasi
  }

  Future<void> fetchDisposisi() async {
    final response =
        await http.get(Uri.parse('http://192.168.167.246:8000/api/disposisis'));

    if (response.statusCode == 200) {
      final List<dynamic> allDisposisi = jsonDecode(response.body);
      setState(() {
        // Filter disposisi berdasarkan surat_id yang sesuai
        disposisiList = allDisposisi
            .where((disposisi) => disposisi['surat_id'] == nomorSurat)
            .toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil data disposisi')),
      );
    }
  }

  Future<void> _openPDF(BuildContext context) async {
    if (filePath != null && filePath!.isNotEmpty) {
      String fullFileUrl =
          'http://192.168.167.246:8000/storage/uploads/surat/$filePath';
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

  void _createDisposisi(BuildContext context) async {
    // Navigasi ke halaman CreateDisposisi
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateDisposisi(
          nomorSurat: nomorSurat,
          pengirim: pengirim,
          tujuan: tujuan,
          perihal: perihal,
          idSurat: widget.idSurat,
        ),
      ),
    );

    Future<void> _updateStatus() async {
      final response = await http.patch(
        Uri.parse(
            'http://192.168.167.246:8000/api/surat_masuks/${widget.idSurat}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status surat berhasil diperbarui')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui status surat')),
        );
      }
    }

    // Fetch disposisi setelah kembali
    fetchDisposisi();
  }

  Future<void> _deleteDisposisi(int disposisiId) async {
    final response = await http.delete(
      Uri.parse('http://192.168.167.246:8000/api/disposisis/$disposisiId'),
    );

    if (response.statusCode == 200) {
      setState(() {
        disposisiList
            .removeWhere((disposisi) => disposisi['id'] == disposisiId);
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Berhasil"),
            content: Text("Disposisi berhasil dihapus."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Tutup dialog
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Gagal"),
            content: Text("Gagal menghapus disposisi."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Tutup dialog
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _updateStatus() async {
    final response = await http.patch(
      Uri.parse(
          'http://192.168.167.246:8000/api/surat_masuks/${widget.idSurat}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': 2}),
    );

    if (response.statusCode == 200) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Selesai"),
            content: Text("Ok sudah selesai."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Tutup dialog
                  Navigator.pop(context); // Kembali ke halaman sebelumnya
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Gagal"),
            content: Text("Gagal, belum selesai."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Tutup dialog
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _editDisposisi(int disposisiId) async {
    var updatedData = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditDisposisi(
          disposisiId: disposisiId,
          nomorSurat: nomorSurat,
          pengirim: pengirim,
          tujuan: tujuan,
          perihal: perihal,
        ),
      ),
    );

    if (updatedData != null) {
      fetchDisposisi(); // Refresh list disposisi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Disposisi berhasil diperbarui')),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: [
              Text(
                'Surat Masuk :',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Nomor Surat : $nomorSurat',
                          style: TextStyle(fontSize: 16)),
                      SizedBox(height: 8.0),
                      Text('Pengirim : $pengirim',
                          style: TextStyle(fontSize: 16)),
                      SizedBox(height: 8.0),
                      Text('Tujuan : $tujuan', style: TextStyle(fontSize: 16)),
                      SizedBox(height: 8.0),
                      Text('Perihal : $perihal',
                          style: TextStyle(fontSize: 16)),
                      SizedBox(height: 8.0),
                      Text('Tanggal Surat : $tanggalSurat',
                          style: TextStyle(fontSize: 16)),
                      SizedBox(height: 8.0),
                      Text('Tanggal Terima : $tanggalTerima',
                          style: TextStyle(fontSize: 16)),
                      SizedBox(height: 8.0),
                      Text(
                        'File Surat : ${filePath?.isNotEmpty == true ? filePath!.split('/').last : "Tidak ada file yang diunggah"}',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 16.0),
                      Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisAlignment: MainAxisAlignment.end,

                        children: [
                          ElevatedButton(
                            onPressed: () => _openPDF(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            child: Text('Lihat File PDF'),
                          ),
                          SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => _editSurat(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                            child: Text('Edit'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => _createDisposisi(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Buat Disposisi'),
                      ),
                    ],
                  ),
                ],
              ),

              // Menambahkan daftar disposisi
              Text(
                'Daftar Disposisi :',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: disposisiList.length,
                itemBuilder: (context, index) {
                  final disposisi = disposisiList[index];
                  return Card(
                    child: ListTile(
                      title: Text('Disposisi ID : ${disposisi['id']}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Surat ID : ${disposisi['surat_id']}'),
                          Text('Pengirim ID : ${disposisi['pengirim_id']}'),
                          Text('Penerima ID : ${disposisi['penerima_id']}'),
                          Text('Disposisi : ${disposisi['disposisi']}'),
                          Text('Keterangan : ${disposisi['keterangan']}'),
                          Text('Status : ${disposisi['status']}'),
                          Text(
                              'Tanggal Verifikasi : ${disposisi['tgl_verifikasi']}'),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      _deleteDisposisi(disposisi['id']);
                                    },
                                    child: Text('Hapus'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      _editDisposisi(disposisi['id']);
                                    },
                                    child: Text('Edit'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              if (disposisiList.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _updateStatus();
                      },
                      child: Text('Selesai'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class PDFViewer extends StatelessWidget {
  final String filePath;

  PDFViewer({required this.filePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'View PDF',
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
