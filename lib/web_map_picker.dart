import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:ui' as ui;
import 'dart:js' as js;
// import 'dart:ui_web' as ui;


class WebMapPicker extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;

  const WebMapPicker({super.key, this.initialLat, this.initialLng});

  @override
  State<WebMapPicker> createState() => _WebMapPickerState();
}

class _WebMapPickerState extends State<WebMapPicker> {
  String _selectedAddress = '';
  double? _selectedLat;
  double? _selectedLng;
  bool _isMapVisible = false;
  final String _viewId = 'google-map-${DateTime.now().millisecondsSinceEpoch}';

  @override
  void initState() {
    super.initState();
    _registerMapView();
  }

  void _registerMapView() {
    // Register the view factory for the map
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(_viewId, (int viewId) {
      final div = html.DivElement()
        ..id = 'map-container-$viewId'
        ..style.width = '100%'
        ..style.height = '100%';

      return div;
    });
  }

  void _initializeMap() {
    setState(() => _isMapVisible = true);

    Future.delayed(const Duration(milliseconds: 300), () {
      final script = '''
        (function() {
          const mapDiv = document.getElementById('map-container-0');
          if (!mapDiv) return;

          const initialLat = ${widget.initialLat ?? 24.8607};
          const initialLng = ${widget.initialLng ?? 67.0011};

          const map = new google.maps.Map(mapDiv, {
            center: { lat: initialLat, lng: initialLng },
            zoom: 13,
            mapTypeControl: true,
            streetViewControl: false,
            fullscreenControl: false,
          });

          let marker = new google.maps.Marker({
            position: { lat: initialLat, lng: initialLng },
            map: map,
            draggable: true,
            animation: google.maps.Animation.DROP,
          });

          const geocoder = new google.maps.Geocoder();

          function geocodePosition(pos) {
            geocoder.geocode({ location: pos }, function(results, status) {
              if (status === 'OK' && results[0]) {
                window.selectedAddress = results[0].formatted_address;
                window.selectedLat = pos.lat();
                window.selectedLng = pos.lng();
                
                // Trigger Flutter callback
                if (window.updateFlutterLocation) {
                  window.updateFlutterLocation(
                    results[0].formatted_address,
                    pos.lat(),
                    pos.lng()
                  );
                }
              } else {
                window.selectedAddress = pos.lat().toFixed(6) + ', ' + pos.lng().toFixed(6);
                window.selectedLat = pos.lat();
                window.selectedLng = pos.lng();
                
                if (window.updateFlutterLocation) {
                  window.updateFlutterLocation(
                    window.selectedAddress,
                    pos.lat(),
                    pos.lng()
                  );
                }
              }
            });
          }

          // Initial geocoding
          geocodePosition(marker.getPosition());

          // Update on marker drag
          marker.addListener('dragend', function() {
            geocodePosition(marker.getPosition());
          });

          // Update on map click
          map.addListener('click', function(event) {
            marker.setPosition(event.latLng);
            geocodePosition(event.latLng);
          });

          // Current location button
          const locationButton = document.createElement('button');
          locationButton.textContent = 'Current Location';
          locationButton.classList.add('custom-map-control-button');
          locationButton.style.backgroundColor = '#fff';
          locationButton.style.border = '2px solid #fff';
          locationButton.style.borderRadius = '3px';
          locationButton.style.boxShadow = '0 2px 6px rgba(0,0,0,.3)';
          locationButton.style.color = 'rgb(25,25,25)';
          locationButton.style.cursor = 'pointer';
          locationButton.style.fontFamily = 'Roboto,Arial,sans-serif';
          locationButton.style.fontSize = '16px';
          locationButton.style.lineHeight = '38px';
          locationButton.style.margin = '8px 0 22px';
          locationButton.style.padding = '0 5px';
          locationButton.style.textAlign = 'center';

          map.controls[google.maps.ControlPosition.TOP_CENTER].push(locationButton);

          locationButton.addEventListener('click', () => {
            if (navigator.geolocation) {
              navigator.geolocation.getCurrentPosition(
                (position) => {
                  const pos = {
                    lat: position.coords.latitude,
                    lng: position.coords.longitude,
                  };
                  map.setCenter(pos);
                  map.setZoom(15);
                  marker.setPosition(pos);
                  geocodePosition(new google.maps.LatLng(pos.lat, pos.lng));
                },
                () => {
                  alert('Error: The Geolocation service failed.');
                }
              );
            } else {
              alert('Error: Your browser doesn\\'t support geolocation.');
            }
          });
        })();
      ''';

      html.document.head?.append(html.ScriptElement()..text = script);
    });

    // Setup callback from JavaScript
    js.context['updateFlutterLocation'] = (String address, num lat, num lng) {
      if (mounted) {
        setState(() {
          _selectedAddress = address;
          _selectedLat = lat.toDouble();
          _selectedLng = lng.toDouble();
        });
      }
    };
  }

  @override
  void dispose() {
    js.context['updateFlutterLocation'] = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 900,
          maxHeight: 700,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.map, color: Colors.orange, size: 30),
                  const SizedBox(width: 12),
                  const Text(
                    'Select Location on Map',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Map or Instructions
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    if (!_isMapVisible)
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.map_outlined,
                                size: 80,
                                color: Colors.orange,
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Click below to open the interactive map',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 30),
                              ElevatedButton.icon(
                                onPressed: _initializeMap,
                                icon: const Icon(Icons.map),
                                label: const Text('Open Map'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: Column(
                          children: [
                            // Instructions
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.orange),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.info_outline, color: Colors.orange, size: 20),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Click on map or drag marker to select location. Use "Current Location" button to go to your position.',
                                      style: TextStyle(color: Colors.white70, fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Map Container
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.orange),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: HtmlElementView(viewType: _viewId),
                                ),
                              ),
                            ),

                            // Selected Address Display
                            if (_selectedAddress.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[850],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Selected Location:',
                                      style: TextStyle(
                                        color: Colors.orange,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _selectedAddress,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                    if (_selectedLat != null && _selectedLng != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          'Lat: ${_selectedLat!.toStringAsFixed(6)}, Lng: ${_selectedLng!.toStringAsFixed(6)}',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Footer Buttons
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.grey),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _selectedAddress.isNotEmpty
                          ? () {
                        final result = {
                          'address': _selectedAddress,
                          'latitude': _selectedLat,
                          'longitude': _selectedLng,
                        };
                        Navigator.pop(context, result);
                      }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedAddress.isNotEmpty
                            ? Colors.orange
                            : Colors.grey[700],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Save Location',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}