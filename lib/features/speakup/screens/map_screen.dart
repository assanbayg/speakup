import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/svg.dart';
import 'package:latlong2/latlong.dart';
import 'package:speakup/common/widgets/app_bar.dart';
import 'package:speakup/util/data/marker_coords.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key, required this.text});

  final String text;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const LatLng _almaty = LatLng(43.270447, 76.887133);
  static const LatLng _astana = LatLng(51.140712, 71.427101);
  static const double _defaultZoom = 12.0;
  static const double _minZoom = 3.0;
  static const double _maxZoom = 18.0;

  late final MapController mapController;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
  }

  String dropdownValue = 'Алматы';

  void _onDropDownChanged(String? city) {
    setState(() {
      dropdownValue = city!;
      final target = _cityToLatLng(city);
      mapController.move(target, _defaultZoom);
    });
  }

  LatLng _cityToLatLng(String city) {
    return city == 'Алматы' ? _almaty : _astana;
  }

  void _zoomBy(double delta) {
    final camera = mapController.camera;
    final nextZoom = (camera.zoom + delta).clamp(_minZoom, _maxZoom);
    mapController.move(camera.center, nextZoom);
  }

  void _resetView() {
    final target = _cityToLatLng(dropdownValue);
    mapController.move(target, _defaultZoom);
    mapController.rotate(0.0); // Reset to North/South orientation
  }

  void _resetOrientation() {
    mapController.rotate(0.0);
  }

  @override
  Widget build(BuildContext context) {
    final markers = markerCoords
        .map((point) => Marker(
              point: point,
              width: 40,
              height: 40,
              child: SvgPicture.asset(
                'assets/icons/Location_fill.svg',
                width: 30,
                height: 30,
                colorFilter: const ColorFilter.mode(
                  Colors.red,
                  BlendMode.srcIn,
                ),
              ),
            ))
        .toList();

    return Scaffold(
      appBar: const SAppBar(
        page: "Map",
        title: "Логопедические центры",
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: const MapOptions(
              initialCenter: LatLng(43.270447, 76.887133),
              initialZoom: 12.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName: 'com.devoasis.speakup',
              ),
              MarkerLayer(markers: markers),
            ],
          ),
          Positioned(
            bottom: 50.0,
            left: 15.0,
            child: Text(widget.text),
          ),
          Positioned(
            top: 10.0,
            right: 10.0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 5,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
              child: DropdownButton<String>(
                value: dropdownValue,
                onChanged: _onDropDownChanged,
                underline: const SizedBox(),
                icon: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: SvgPicture.asset(
                    'assets/icons/Arrow_down.svg',
                    width: 16,
                    height: 16,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                dropdownColor: Colors.white,
                items: <String>['Алматы', 'Астана']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        value,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Positioned(
            bottom: 20.0,
            right: 15.0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    spreadRadius: 2,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    spreadRadius: 1,
                    offset: const Offset(0, 3),
                  ),
                ],
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _MapActionButton(
                    icon: Icons.add,
                    tooltip: 'Приблизить',
                    onTap: () => _zoomBy(0.8),
                  ),
                  _MapActionButton(
                    icon: Icons.remove,
                    tooltip: 'Отдалить',
                    onTap: () => _zoomBy(-0.8),
                  ),
                  _MapActionButton(
                    icon: Icons.home_rounded,
                    tooltip: 'Вернуть на выбранный город',
                    onTap: _resetView,
                  ),
                  _MapActionButton(
                    icon: Icons.explore,
                    tooltip: 'Вернуть ориентацию на Север',
                    onTap: _resetOrientation,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapActionButton extends StatelessWidget {
  const _MapActionButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Tooltip(
            message: tooltip,
            child: Icon(
              icon,
              size: 22,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
