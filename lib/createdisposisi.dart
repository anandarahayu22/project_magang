import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CreateDisposisi extends StatefulWidget {
  @override
  _CreateDisposisiState createState() => _CreateDisposisiState();
}

class _CreateDisposisiState extends State<CreateDisposisi> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController suratIdController = TextEditingController();
  TextEditingController pengirimIdController = TextEditingController();
  TextEditingController penerimaIdController = TextEditingController();
  TextEditingController disposisiController = TextEditingController();
  TextEditingController keteranganController = TextEditingController();
  TextEditingController statusController = TextEditingController();
  TextEditingController tglVerifikasiController = TextEditingController();

  Future<void> createDisposisi() async {
    final response = await http.post(
      Uri.parse('http://192.168.102.246:8000/api/disposisis'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'surat_id': suratIdController.text,
        'pengirim_id': pengirimIdController.text,
        'penerima_id': penerimaIdController.text,
        'disposisi': disposisiController.text,
        'keterangan': keteranganController.text,
        'status': statusController.text,
        'tgl_verifikasi': tglVerifikasiController.text,
        'Read': 0,
      }),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Disposisi berhasil dibuat')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuat disposisi')),
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
    // Navigasi kembali tanpa menyimpan
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
              _buildTextField(keteranganController, 'Keterangan', false,
                  maxLines: 2),
              _buildTextField(statusController, 'Status', true),
              _buildDateField(tglVerifikasiController, 'Tanggal Verifikasi'),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: _batal,
                    child: Text('Batal'),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        createDisposisi();
                      }
                    },
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
