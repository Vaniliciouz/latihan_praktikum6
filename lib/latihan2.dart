// ignore_for_file: override_on_non_overriding_member

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daftar Universitas di ASEAN',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider(
        create: (context) => CountryBloc(),
        child: Scaffold(
          appBar: AppBar(
            title: Text('Daftar Universitas di ASEAN'),
          ),
          body: Column(
            children: [
              CountrySelector(),
              Expanded(
                child: UniversitiesList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CountryEvent {}

class CountryChanged extends CountryEvent {
  final String selectedCountry;
  CountryChanged(this.selectedCountry);
}

class CountryState {
  final String selectedCountry;
  CountryState(this.selectedCountry);
}

class CountryBloc extends Bloc<CountryEvent, CountryState> {
  CountryBloc() : super(CountryState('Indonesia'));

  @override
  Stream<CountryState> mapEventToState(CountryEvent event) async* {
    if (event is CountryChanged) {
      yield CountryState(event.selectedCountry);
    }
  }
}

class CountrySelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CountryBloc, CountryState>(
      builder: (context, state) {
        return DropdownButton<String>(
          value: state.selectedCountry,
          onChanged: (String? newValue) {
            if (newValue != null) {
              context.read<CountryBloc>().add(CountryChanged(newValue));
            }
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
            'Laos'
          ].map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        );
      },
    );
  }
}

class UniversitiesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CountryBloc, CountryState>(
      builder: (context, state) {
        return FutureBuilder<List<dynamic>>(
          future: _fetchUniversities(state.selectedCountry),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              List<dynamic> universities = snapshot.data ?? [];
              return ListView.builder(
                itemCount: universities.length,
                itemBuilder: (BuildContext context, int index) {
                  final university = universities[index];
                  return GestureDetector(
                    onTap: () {
                      _launchURL(university['web_pages'][0]);
                    },
                    child: Card(
                      elevation: 3,
                      margin:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ListTile(
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        title: Text(
                          university['name'],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(university['web_pages'][0]),
                      ),
                    ),
                  );
                },
              );
            }
          },
        );
      },
    );
  }

  Future<List<dynamic>> _fetchUniversities(String country) async {
    final response = await http.get(
        Uri.parse('http://universities.hipolabs.com/search?country=$country'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load universities');
    }
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
