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
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var userId = prefs.getString('id');
    var token = prefs.getString('token');
    var url = Uri.parse('http://192.168.102.246:8000/api/profiles/$userId');

    try {
      var response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          profileData = jsonDecode(response.body);
        });
      } else {
        print(
            'Gagal mendapatkan data profil. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Terjadi kesalahan: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(color: Colors.white, fontSize: 25),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.blueGrey,
      ),
      body: profileData == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  Icon(
                    Icons.person,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 10),
                  Text(
                    '${profileData?['username'] ?? 'Username'}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    '${profileData?['name'] ?? 'Name'}',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[700],
                    ),
                  ),
                  Divider(height: 40, thickness: 1.5),
                  ListTile(
                    leading: Icon(Icons.email, color: Colors.blueGrey),
                    title: Text(
                      '${profileData?['email'] ?? 'Email'}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.phone, color: Colors.blueGrey),
                    title: Text(
                      '${profileData?['phone'] ?? 'Phone'}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.home, color: Colors.blueGrey),
                    title: Text(
                      '${profileData?['address'] ?? 'Address'}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
