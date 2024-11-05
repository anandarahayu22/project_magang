import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditDisposisi extends StatefulWidget {
  final int disposisiId;

  EditDisposisi({required this.disposisiId});

  @override
  _EditDisposisiState createState() => _EditDisposisiState();
}

class _EditDisposisiState extends State<EditDisposisi> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController suratIdController = TextEditingController();
  TextEditingController pengirimIdController = TextEditingController();
  TextEditingController penerimaIdController = TextEditingController();
  TextEditingController disposisiController = TextEditingController();
  TextEditingController keteranganController = TextEditingController();
  TextEditingController statusController = TextEditingController();
  TextEditingController tglVerifikasiController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchDisposisiData(); // Load data disposisi saat halaman dibuka
  }

  Future<void> fetchDisposisiData() async {
    final response = await http.get(
      Uri.parse('http://localhost:8000/api/disposisis/${widget.disposisiId}'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        suratIdController.text = data['surat_id'];
        pengirimIdController.text = data['pengirim_id'];
        penerimaIdController.text = data['penerima_id'];
        disposisiController.text = data['disposisi'];
        keteranganController.text = data['Keterangan'] ?? '';
        statusController.text = data['status'];
        tglVerifikasiController.text = data['tgl_verifikasi'];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data disposisi')),
      );
    }
  }

  Future<void> updateDisposisi() async {
    final response = await http.post(
      Uri.parse('http://localhost:8000/api/disposisis/${widget.disposisiId}'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'surat_id': suratIdController.text,
        'pengirim_id': pengirimIdController.text,
        'penerima_id': penerimaIdController.text,
        'disposisi': disposisiController.text,
        'Keterangan': keteranganController.text,
        'status': statusController.text,
        'tgl_verifikasi': tglVerifikasiController.text,
        'Read': 0,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Disposisi berhasil diperbarui')),
      );
      Navigator.pop(context); // Kembali ke halaman sebelumnya
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui disposisi')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Disposisi'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: suratIdController,
                decoration: InputDecoration(labelText: 'Surat ID'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Surat ID tidak boleh kosong';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: pengirimIdController,
                decoration: InputDecoration(labelText: 'Pengirim ID'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Pengirim ID tidak boleh kosong';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: penerimaIdController,
                decoration: InputDecoration(labelText: 'Penerima ID'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Penerima ID tidak boleh kosong';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: disposisiController,
                decoration: InputDecoration(labelText: 'Disposisi'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Disposisi tidak boleh kosong';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: keteranganController,
                decoration: InputDecoration(labelText: 'Keterangan'),
                maxLines: 3,
              ),
              TextFormField(
                controller: statusController,
                decoration: InputDecoration(labelText: 'Status'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Status tidak boleh kosong';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: tglVerifikasiController,
                decoration: InputDecoration(labelText: 'Tanggal Verifikasi'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tanggal Verifikasi tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    updateDisposisi();
                  }
                },
                child: Text('Perbarui Disposisi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
