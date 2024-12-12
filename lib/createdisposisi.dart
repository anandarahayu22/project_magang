import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CreateDisposisi extends StatefulWidget {
  final String nomorSurat;
  final String pengirim;
  final String tujuan;
  final String perihal;
  final int idSurat;

  CreateDisposisi({
    required this.nomorSurat,
    required this.pengirim,
    required this.tujuan,
    required this.perihal,
    required this.idSurat,
  });

  @override
  _CreateDisposisiState createState() => _CreateDisposisiState();
}

class _CreateDisposisiState extends State<CreateDisposisi> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController suratIdController;
  late TextEditingController penerimaIdController;
  late TextEditingController disposisiController;
  TextEditingController keteranganController = TextEditingController();
  TextEditingController statusController = TextEditingController();
  TextEditingController tglVerifikasiController = TextEditingController();
  TextEditingController pengirimIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    suratIdController = TextEditingController(text: widget.nomorSurat);
    penerimaIdController = TextEditingController(text: widget.tujuan);
    disposisiController = TextEditingController(text: widget.perihal);
    pengirimIdController = TextEditingController(text: widget.pengirim);
  }

  Future<void> createDisposisi() async {
    final body = jsonEncode({
      'surat_id': suratIdController.text,
      'pengirim_id': pengirimIdController.text,
      'penerima_id': penerimaIdController.text,
      'disposisi': disposisiController.text,
      'keterangan': keteranganController.text,
      'status': statusController.text,
      'tgl_verifikasi': tglVerifikasiController.text,
      'Read': 0,
    });

    print("Data dikirim: $body"); // Debug print untuk memeriksa data

    final response = await http.post(
      Uri.parse('http://192.168.167.246:8000/api/disposisis'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: body,
    );

    log("Response add disposisi $response");

    if (response.statusCode == 201) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Berhasil"),
            content: Text("Disposisi berhasil dibuat."),
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
            content: Text("Gagal membuat disposisi."),
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

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selectedDate != null) {
      setState(() {
        controller.text = "${selectedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  void _batal() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Disposisi',
          style: TextStyle(color: Colors.white, fontSize: 25),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(suratIdController, 'Surat ID', true),
              _buildTextField(pengirimIdController, 'Pengirim ID', true),
              _buildTextField(penerimaIdController, 'Penerima ID', true),
              _buildTextField(disposisiController, 'Disposisi', true),
              _buildTextField(keteranganController, 'Keterangan', false),
              _buildTextField(statusController, 'Status', true),
              _buildDateField(tglVerifikasiController, 'Tanggal Verifikasi'),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: _batal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Batal'),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        createDisposisi();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Simpan'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, bool isRequired,
      {int maxLines = 1}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
        ),
        maxLines: maxLines,
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return '$label tidak boleh kosong';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDateField(TextEditingController controller, String label) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          suffixIcon: IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () {
              _selectDate(context, controller);
            },
          ),
        ),
        readOnly: true,
      ),
    );
  }
}
