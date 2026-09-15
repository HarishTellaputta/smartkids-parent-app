import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class BusTrackingScreen extends StatefulWidget {
  const BusTrackingScreen({super.key});

  @override
  State<BusTrackingScreen> createState() => _BusTrackingScreenState();
}

class _BusTrackingScreenState extends State<BusTrackingScreen> {
  final MapController mapController = MapController();

  Timer? _timer;

  // ============================================================
  // DUMMY BUS ROUTE
  // ============================================================
  //
  // These are dummy coordinates around Vijayawada.
  //
  // Later these coordinates can come from your Spring Boot API.
  //

  final List<LatLng> routePoints = [
    const LatLng(16.5062, 80.6480),
    const LatLng(16.5075, 80.6465),
    const LatLng(16.5090, 80.6450),
    const LatLng(16.5105, 80.6435),
    const LatLng(16.5120, 80.6420),
    const LatLng(16.5140, 80.6405),
    const LatLng(16.5160, 80.6390),
    const LatLng(16.5180, 80.6375),
    const LatLng(16.5200, 80.6360),
    const LatLng(16.5220, 80.6345),
    const LatLng(16.5240, 80.6330),
  ];

  int currentPointIndex = 0;

  bool isTracking = true;

  // ============================================================
  // STOPS
  // ============================================================

  final List<String> stops = [
    "Sai Nagar Junction",
    "Vijay Nagar Colony",
    "Market Road",
    "Main Road",
    "School Campus",
  ];

  // ============================================================
  // START MOVING BUS
  // ============================================================

  @override
  void initState() {
    super.initState();

    _startBusMovement();
  }

  void _startBusMovement() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!isTracking) return;

      if (currentPointIndex < routePoints.length - 1) {
        setState(() {
          currentPointIndex++;
        });

        // Move camera with bus
        mapController.move(routePoints[currentPointIndex], 15.5);
      } else {
        // Route completed
        setState(() {
          currentPointIndex = 0;
        });

        mapController.move(routePoints[0], 15.5);
      }
    });
  }

  void _toggleTracking() {
    setState(() {
      isTracking = !isTracking;
    });
  }

  // ============================================================
  // CURRENT BUS LOCATION
  // ============================================================

  LatLng get currentBusLocation {
    return routePoints[currentPointIndex];
  }

  // ============================================================
  // CURRENT STOP
  // ============================================================

  String get currentStop {
    if (currentPointIndex >= routePoints.length - 1) {
      return "School Campus";
    }

    if (currentPointIndex < 2) {
      return "Sai Nagar Junction";
    }

    if (currentPointIndex < 5) {
      return "Vijay Nagar Colony";
    }

    if (currentPointIndex < 8) {
      return "Market Road";
    }

    if (currentPointIndex < 10) {
      return "Main Road";
    }

    return "School Campus";
  }

  // ============================================================
  // NEXT STOP
  // ============================================================

  String get nextStop {
    if (currentPointIndex < 2) {
      return "Vijay Nagar Colony";
    }

    if (currentPointIndex < 5) {
      return "Market Road";
    }

    if (currentPointIndex < 8) {
      return "Main Road";
    }

    return "School Campus";
  }

  // ============================================================
  // ETA
  // ============================================================

  int get estimatedMinutes {
    final remaining = routePoints.length - currentPointIndex - 1;

    return remaining <= 0 ? 0 : remaining * 2;
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _timer?.cancel();
    mapController.dispose();
    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F8FC),

      // ==========================================================
      // APP BAR
      // ==========================================================
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        centerTitle: true,

        title: const Text(
          "Live Bus Tracking",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),

        iconTheme: const IconThemeData(color: Colors.black),
      ),

      // ==========================================================
      // BODY
      // ==========================================================
      body: Column(
        children: [
          // ========================================================
          // MAP
          // ========================================================
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: mapController,

                  options: MapOptions(
                    initialCenter: routePoints[0],
                    initialZoom: 15.5,

                    minZoom: 10,
                    maxZoom: 18,
                  ),

                  children: [
                    // ==================================================
                    // OPEN STREET MAP
                    // ==================================================
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',

                      userAgentPackageName: 'com.smartschool.parent_app',
                    ),

                    // ==================================================
                    // ROUTE
                    // ==================================================
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: routePoints,

                          strokeWidth: 5,

                          color: const Color(0xff1565C0),
                        ),
                      ],
                    ),

                    // ==================================================
                    // BUS MARKER
                    // ==================================================
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: currentBusLocation,

                          width: 70,
                          height: 70,

                          child: _buildBusMarker(),
                        ),

                        // =================================================
                        // START LOCATION
                        // =================================================
                        Marker(
                          point: routePoints.first,

                          width: 40,
                          height: 40,

                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),

                            child: const Icon(
                              Icons.location_on,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),

                        // =================================================
                        // SCHOOL
                        // =================================================
                        Marker(
                          point: routePoints.last,

                          width: 50,
                          height: 50,

                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),

                            child: const Icon(
                              Icons.school_rounded,
                              color: Colors.white,
                              size: 25,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // ========================================================
                // LIVE BADGE
                // ========================================================
                Positioned(
                  top: 15,
                  left: 15,

                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.white,

                      borderRadius: BorderRadius.circular(30),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 10,
                        ),
                      ],
                    ),

                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,

                          decoration: BoxDecoration(
                            color: isTracking ? Colors.green : Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),

                        const SizedBox(width: 7),

                        Text(
                          isTracking ? "LIVE" : "PAUSED",

                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isTracking ? Colors.green : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ========================================================
                // BUS NUMBER BADGE
                // ========================================================
                Positioned(
                  top: 15,
                  right: 15,

                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.white,

                      borderRadius: BorderRadius.circular(14),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 10,
                        ),
                      ],
                    ),

                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          "School Bus",
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),

                        SizedBox(height: 2),

                        Text(
                          "BUS - 12",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xff1565C0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ==========================================================
          // BOTTOM BUS INFORMATION
          // ==========================================================
          Container(
            width: double.infinity,

            padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),

            decoration: const BoxDecoration(
              color: Colors.white,

              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),

              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 15,
                  offset: Offset(0, -5),
                ),
              ],
            ),

            child: Column(
              children: [
                // ========================================================
                // BUS INFORMATION
                // ========================================================
                Row(
                  children: [
                    // BUS ICON
                    Container(
                      height: 52,
                      width: 52,

                      decoration: BoxDecoration(
                        color: const Color(0xffEAF2FF),
                        borderRadius: BorderRadius.circular(15),
                      ),

                      child: const Icon(
                        Icons.directions_bus_rounded,
                        color: Color(0xff1565C0),
                        size: 30,
                      ),
                    ),

                    const SizedBox(width: 12),

                    // BUS DETAILS
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          const Text(
                            "School Bus - 12",

                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 3),

                          Text(
                            "AP 16 AB 4567",

                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ETA
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,

                      children: [
                        const Text(
                          "ETA",

                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),

                        Text(
                          estimatedMinutes == 0
                              ? "Arrived"
                              : "$estimatedMinutes min",

                          style: const TextStyle(
                            color: Color(0xff1565C0),
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ========================================================
                // CURRENT / NEXT STOP
                // ========================================================
                Container(
                  width: double.infinity,

                  padding: const EdgeInsets.all(14),

                  decoration: BoxDecoration(
                    color: const Color(0xffF5F8FC),

                    borderRadius: BorderRadius.circular(15),
                  ),

                  child: Row(
                    children: [
                      // CURRENT
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(
                              "Current Location",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              currentStop,

                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,

                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        height: 35,
                        width: 1,
                        color: Colors.grey.shade300,
                      ),

                      const SizedBox(width: 14),

                      // NEXT
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(
                              "Next Stop",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              nextStop,

                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,

                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                // ========================================================
                // START / STOP BUTTON
                // ========================================================
                SizedBox(
                  width: double.infinity,
                  height: 52,

                  child: ElevatedButton.icon(
                    onPressed: _toggleTracking,

                    style: ElevatedButton.styleFrom(
                      backgroundColor: isTracking
                          ? Colors.red
                          : const Color(0xff1565C0),

                      foregroundColor: Colors.white,

                      elevation: 0,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),

                    icon: Icon(
                      isTracking
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                    ),

                    label: Text(
                      isTracking ? "Stop Tracking" : "Start Tracking",

                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BUS MARKER
  // ============================================================

  Widget _buildBusMarker() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),

      curve: Curves.easeInOut,

      child: Stack(
        alignment: Alignment.center,

        children: [
          // OUTER CIRCLE
          Container(
            width: 62,
            height: 62,

            decoration: BoxDecoration(
              color: const Color(0xff1565C0).withOpacity(0.18),

              shape: BoxShape.circle,
            ),
          ),

          // BUS CIRCLE
          Container(
            width: 46,
            height: 46,

            decoration: BoxDecoration(
              color: const Color(0xff1565C0),

              shape: BoxShape.circle,

              border: Border.all(color: Colors.white, width: 3),

              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),

            child: const Icon(
              Icons.directions_bus_rounded,
              color: Colors.white,
              size: 25,
            ),
          ),
        ],
      ),
    );
  }
}
