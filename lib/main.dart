import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'models/station.dart';
import 'services/api_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Polskie Radio Flutter',
      theme: ThemeData(primarySwatch: Colors.blue, brightness: Brightness.dark),
      home: RadioScreen(),
    );
  }
}

class RadioScreen extends StatefulWidget {
  @override
  _RadioScreenState createState() => _RadioScreenState();
}

class _RadioScreenState extends State<RadioScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<RadioStation> _stations = [];
  String _status = 'Wpisz nazwę stacji i wyszukaj';
  final AudioPlayer _player = AudioPlayer();
  RadioStation? _currentStation;
  bool _isPlaying = false;

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() => _status = 'Wyszukuję...');
    try {
      _stations = await ApiService.searchStations(query);
      setState(() => _status = 'Znaleziono ${_stations.length} stacji');
    } catch (e) {
      setState(() => _status = 'Błąd: $e');
    }
  }

  Future<void> _playStation(RadioStation station) async {
    await _stop();  // Zatrzymaj poprzedni stream
    try {
      await _player.setUrl(station.url);
      await _player.play();
      setState(() {
        _currentStation = station;
        _isPlaying = true;
        _status = 'Gram: ${station.name}';
      });
    } catch (e) {
      setState(() => _status = 'Błąd odtwarzania: $e');
    }
  }

  Future<void> _togglePlay() async {
    if (_isPlaying) {
      await _player.pause();
      setState(() {
        _isPlaying = false;
        _status = 'Pauza';
      });
    } else if (_currentStation != null) {
      await _player.play();
      setState(() {
        _isPlaying = true;
        _status = 'Gram: ${_currentStation!.name}';
      });
    }
  }

  Future<void> _stop() async {
    await _player.stop();
    setState(() {
      _isPlaying = false;
      _currentStation = null;
      _status = 'Zatrzymano';
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Polskie Radio')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(hintText: 'Szukaj (np. RMF, Eska)'),
                  ),
                ),
                ElevatedButton(onPressed: _search, child: Text('Szukaj')),
              ],
            ),
          ),
          Text(_status, style: TextStyle(fontSize: 16)),
          Expanded(
            child: ListView.builder(
              itemCount: _stations.length,
              itemBuilder: (context, index) {
                final station = _stations[index];
                return ListTile(
                  title: Text(station.name),
                  subtitle: Text('${station.bitrate} kbps'),
                  onTap: () => _playStation(station),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
              onPressed: _togglePlay,
            ),
            IconButton(icon: Icon(Icons.stop), onPressed: _stop),
            Text(_status),
          ],
        ),
      ),
    );
  }
}
