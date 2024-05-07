// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daftar Universitas',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChangeNotifierProvider(
        create: (_) => UniversityProvider(),
        child: HomePage(),
      ),
    );
  }
}

class University {
  final String name;
  final String webPage;

  University({required this.name, required this.webPage});
}

class UniversityProvider with ChangeNotifier {
  List<University> universities = [];

  Future<void> fetchUniversities(String country) async {
    final response = await http.get(
        Uri.parse('http://universities.hipolabs.com/search?country=$country'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      universities = data
          .map((json) => University(name: json['name'], webPage: json['web_pages'][0]))
          .toList();
      notifyListeners();
    } else {
      throw Exception('Failed to load universities');
    }
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    UniversityProvider universityProvider = Provider.of<UniversityProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Universitas'),
      ),
      body: Column(
        children: [
          CountryDropdown(),
          Expanded(
            child: UniversityList(),
          ),
        ],
      ),
    );
  }
}

class CountryDropdown extends StatefulWidget {
  @override
  _CountryDropdownState createState() => _CountryDropdownState();
}

class _CountryDropdownState extends State<CountryDropdown> {
  String selectedCountry = 'Indonesia';

  @override
  Widget build(BuildContext context) {
    UniversityProvider universityProvider = Provider.of<UniversityProvider>(context, listen: false);
    return DropdownButton<String>(
      value: selectedCountry,
      onChanged: (String? newValue) {
        setState(() {
          selectedCountry = newValue!;
          universityProvider.fetchUniversities(selectedCountry);
        });
      },
      items: <String>[
        'Indonesia', 
        'Singapore', 
        'Malaysia', 
        'Thailand', 
        'Vietnam', 
        'Philippines', 
        'Brunei Darussalam', 
        'Myanmar', 
        'Cambodia', 
        'Laos']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}

class UniversityList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    UniversityProvider universityProvider = Provider.of<UniversityProvider>(context);
    return ListView.builder(
      itemCount: universityProvider.universities.length,
      itemBuilder: (BuildContext context, int index) {
        University university = universityProvider.universities[index];
        return GestureDetector(
          onTap: () {
            _launchURL(university.webPage);
          },
          child: Card(
            elevation: 3,
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Text(
                university.name,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(university.webPage),
            ),
          ),
        );
      },
    );
  }
}

void _launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
