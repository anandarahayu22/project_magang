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
        await http.get(Uri.parse('http://192.168.30.249:8000/api/disposisis'));

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
          'http://192.168.30.249:8000/storage/uploads/surat/$filePath';
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

    // Fetch disposisi setelah kembali
    fetchDisposisi();
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

  Future<void> _updateStatusDisposisi(int id) async {
    final url = Uri.parse(
        'http://192.168.30.249:8000/api/disposisis/$id'); // Ganti dengan URL API Anda

    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"status": "2", "disposisi": "done"}),
      );

      if (response.statusCode == 200) {
        setState(() {
          // Memperbarui tampilan UI setelah perubahan status
          disposisiList = disposisiList.map((disposisi) {
            if (disposisi['id'] == id) {
              disposisi['status'] = "2";
              disposisi['disposisi'] = "done";
            }
            return disposisi;
          }).toList();
        });
      } else {
        print("Failed to update disposisi");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  // Fungsi untuk menghapus disposisi
  Future<void> _deleteDisposisi(int id) async {
    final url = Uri.parse(
        'http://192.168.30.249:8000/api/disposisis/$id'); // Ganti dengan URL API Anda
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        setState(() {
          disposisiList.removeWhere((disposisi) => disposisi['id'] == id);
        });
      } else {
        print("Failed to delete disposisi");
      }
    } catch (e) {
      print("Error: $e");
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
        // Menambahkan scroll view
        child: Padding(
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: Text('Lihat File PDF'),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () => _editSurat(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: Text('Edit Surat'),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () => _createDisposisi(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: Text('Buat Disposisi'),
              ),
              SizedBox(height: 16.0),

              // Menambahkan daftar disposisi
              Text(
                'Daftar Disposisi:',
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
                      title: Text('Disposisi ID: ${disposisi['id']}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Surat ID: ${disposisi['surat_id']}'),
                          Text('Pengirim ID: ${disposisi['pengirim_id']}'),
                          Text('Penerima ID: ${disposisi['penerima_id']}'),
                          Text('Disposisi: ${disposisi['disposisi']}'),
                          Text('Keterangan: ${disposisi['keterangan']}'),
                          Text('Status: ${disposisi['status']}'),
                          Text(
                              'Tanggal Verifikasi: ${disposisi['tgl_verifikasi']}'),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  _updateStatusDisposisi(disposisi['id']);
                                },
                                child: Text('Simpan'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                              ),
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
                                      // Fungsi edit bisa ditambahkan di sini
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
