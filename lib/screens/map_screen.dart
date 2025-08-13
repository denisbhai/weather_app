import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import '../cubits/weather_cubit.dart';

class MapScreen extends StatefulWidget {
  final double lat, lon;
  final double temp;
  final int humidity;
  final String city;

  const MapScreen({
    required this.lat,
    required this.lon,
    required this.temp,
    required this.humidity,
    required this.city,
    super.key,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;

  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _addInitialMarker();
  }

  void _addInitialMarker() {
    _markers.add(
      Marker(
        markerId: const MarkerId('tapped_marker'),
        position: LatLng(widget.lat, widget.lon),
        infoWindow: InfoWindow(
          title: widget.city,
          snippet:
          'Temp: ${widget.temp.toStringAsFixed(1)}°C • Humidity: ${widget.humidity}%',
        ),
      ),
    );
  }

  void _addMarkerOnTap(LatLng position) {
    context.read<WeatherCubit>().fetchByCoords(position.latitude, position.longitude);
  }

  TileOverlay _buildOwmTile(String layerId) {
    final apiKey = dotenv.env['OWM_API_KEY'] ?? '';

    return TileOverlay(
      tileOverlayId: TileOverlayId(layerId),
      tileProvider: _UrlTileProvider(
        'https://tile.openweathermap.org/map/$layerId/{z}/{x}/{y}.png?appid=$apiKey',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final initial = CameraPosition(
      target: LatLng(widget.lat, widget.lon),
      zoom: 8,
    );

    return Scaffold(
      body: BlocListener<WeatherCubit, WeatherState>(
        listener: (context, state) {
          if (state is WeatherLoaded) {
            setState(() {
              _markers.removeWhere((m) => m.markerId.value == 'tapped_marker');

              _markers.add(
                Marker(
                  markerId: const MarkerId('tapped_marker'),
                  position: LatLng(state.current?.lat??0.00, state.current?.lon??0.00), // you need to expose these in your state
                  infoWindow: InfoWindow(
                    title: state.current?.city ?? "",
                    snippet:
                    'Temp: ${state.current?.temp.toStringAsFixed(1)}°C • Humidity: ${state.current?.humidity}%',
                  ),
                ),
              );
            });
          }
        },
        child: GoogleMap(
          initialCameraPosition: initial,
          markers: _markers,
          onMapCreated: (controller) async {
            _mapController = controller;
          },
          onTap: _addMarkerOnTap, // ✅ Add marker on tap
          tileOverlays: {
            _buildOwmTile('temp_new'),
            _buildOwmTile('precipitation_new'),
          },
        ),
      ),
    );
  }
}

class _UrlTileProvider implements TileProvider {
  final String _urlPattern;

  _UrlTileProvider(this._urlPattern);

  @override
  Future<Tile> getTile(int x, int y, int? zoom) async {
    final url = _urlPattern
        .replaceAll('{x}', x.toString())
        .replaceAll('{y}', y.toString())
        .replaceAll('{z}', zoom.toString());

    final http.Response response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return Tile(256, 256, response.bodyBytes);
    } else {
      return Tile(256, 256, Uint8List(0));
    }
  }
}
