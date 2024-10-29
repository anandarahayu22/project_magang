import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

class EditSuratPage extends StatefulWidget {
  final String nomorSurat;
  final String pengirim;
  final String tujuan;
  final String perihal;
  final String tanggalSurat;
  final String tanggalTerima;
  final String? filePath;

  EditSuratPage({
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
  _EditSuratPageState createState() => _EditSuratPageState();
}

class _EditSuratPageState extends State<EditSuratPage> {
  final TextEditingController _nomorSuratController = TextEditingController();
  final TextEditingController _pengirimController = TextEditingController();
  final TextEditingController _tujuanController = TextEditingController();
  final TextEditingController _perihalController = TextEditingController();
  final TextEditingController _tanggalSuratController = TextEditingController();
  final TextEditingController _tanggalTerimaController =
      TextEditingController();
  File? _selectedFile;

  @override
  void initState() {
    super.initState();
    _nomorSuratController.text = widget.nomorSurat;
    _pengirimController.text = widget.pengirim;
    _tujuanController.text = widget.tujuan;
    _perihalController.text = widget.perihal;
    _tanggalSuratController.text = widget.tanggalSurat;
    _tanggalTerimaController.text = widget.tanggalTerima;
  }

  Future<void> _editSurat() async {
    var request = http.MultipartRequest(
      'POST', // Menggunakan POST sebagai pengganti PUT
      Uri.parse(
          'http://192.168.102.246:8000/api/surat_masuks/${widget.nomorSurat}'),
    );

    request.headers['X-HTTP-Method-Override'] = 'PUT';

    request.fields['nomor_surat'] = _nomorSuratController.text;
    request.fields['pengirim'] = _pengirimController.text;
    request.fields['tujuan'] = _tujuanController.text;
    request.fields['perihal'] = _perihalController.text;
    request.fields['tanggal_surat'] = _tanggalSuratController.text;
    request.fields['tanggal_terima'] = _tanggalTerimaController.text;

    if (_selectedFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('file_surat', _selectedFile!.path),
      );
    }

    var response = await request.send();

    if (response.statusCode == 200) {
      print("Surat berhasil diperbarui.");
      Navigator.pop(context, true);
    } else {
      print("Gagal memperbarui surat: ${response.statusCode}");
    }
  }

  void _batal() {
    Navigator.pop(context);
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

  Future<void> _pickFileFromDevice() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
      print("File dipilih: ${_selectedFile!.path}");
    } else {
      print("Pengguna tidak memilih file.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Surat Masuk',
            style: TextStyle(color: Colors.white, fontSize: 25)),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField(_nomorSuratController, 'Nomor Surat'),
            _buildTextField(_pengirimController, 'Pengirim'),
            _buildTextField(_tujuanController, 'Tujuan'),
            _buildTextField(_perihalController, 'Perihal'),
            _buildDateField(_tanggalSuratController, 'Tanggal Surat'),
            _buildDateField(_tanggalTerimaController, 'Tanggal Terima'),
            SizedBox(height: 10),
            _buildFileUploadField(),
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
                  onPressed: _editSurat,
                  child: Text('Simpan'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
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
        ),
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
          suffixIcon: IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () {
              _selectDate(context, controller);
            },
          ),
          border: InputBorder.none,
        ),
        readOnly: true,
      ),
    );
  }

  Widget _buildFileUploadField() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        readOnly: true,
        onTap: _pickFileFromDevice,
        decoration: InputDecoration(
          labelText: 'Upload File',
          hintText: _selectedFile != null
              ? 'File: ${_selectedFile!.path.split('/').last}'
              : 'Pilih file dari perangkat',
          border: InputBorder.none,
          suffixIcon: Icon(Icons.attach_file),
        ),
      ),
    );
  }
}
