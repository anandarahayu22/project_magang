import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? profileData;

  Future<void> fetchProfileData() async {
    var url = Uri.parse('http://192.168.102.246:8000/api/profiles/1');
    // alamat url akan dinamis sesuai dengan id token yang disimpan

    // Ambil token dari SharedPreferences
    String? token = await _getToken();
    if (token == null) {
      print('Token tidak ditemukan');
      return;
    }

    try {
      var response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Menggunakan token yang diambil
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          profileData = jsonDecode(response.body);
        });
      } else {
        print(
            'Gagal mendapatkan data profil. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Terjadi kesalahan: $e');
    }
  }

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  @override
  void initState() {
    super.initState();
    fetchProfileData(); // Memuat data profil saat halaman terbuka
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: profileData == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Username: ${profileData?['username']}'),
                  Text('Name: ${profileData?['name']}'),
                  Text('Email: ${profileData?['email']}'),
                  Text('Phone: ${profileData?['phone']}'),
                  Text('Address: ${profileData?['address']}'),
                ],
              ),
            ),
    );
  }
}
