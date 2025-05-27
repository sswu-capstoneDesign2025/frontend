import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:capstone_story_app/widgets/custom_layout.dart';

class TodayWeatherScreen extends StatefulWidget {
  const TodayWeatherScreen({super.key});

  @override
  State<TodayWeatherScreen> createState() => _TodayWeatherScreenState();
}

class _TodayWeatherScreenState extends State<TodayWeatherScreen> {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';

  String? fullAddress;
  String? currentTemp;
  String? perceivedTemp;
  String? airQuality;
  String? currentSky;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    detectAndFetchWeather();
  }

  Future<void> detectAndFetchWeather() async {
    final position = await _getCurrentPosition();
    if (position == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    if (placemarks.isEmpty) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    final place = placemarks[0];
    final String searchLocation =
        place.thoroughfare ?? place.subLocality ?? place.locality ?? place.administrativeArea ?? '서울';

    fullAddress = [
      place.administrativeArea,
      place.locality,
      place.subLocality,
      place.thoroughfare,
    ].where((e) => e != null && e.trim().isNotEmpty).join(' ');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/weather?text=${Uri.encodeComponent(searchLocation)}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          fullAddress = data['location']?.toString();
          currentTemp = data['current_temp']?.toString();
          perceivedTemp = data['perceived_temp']?.replaceAll("°", "");
          airQuality = data['air_quality']?.toString();
          currentSky = data['sky']?.toString();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<Position?> _getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  String getWeatherImagePath(String? skyDescription) {
    final mapping = {
      '맑음': 'assets/images/맑음.png',
      '구름조금': 'assets/images/구름조금.png',
      '흐림': 'assets/images/흐림.png',
      '비': 'assets/images/비.png',
      '강우': 'assets/images/강우.png',
      '눈': 'assets/images/눈.png',
      '진눈깨비': 'assets/images/진눈깨비.png',
      '천둥번개': 'assets/images/천둥번개.png',
      '폭풍우': 'assets/images/폭풍우.png',
      '강풍': 'assets/images/강풍.png',
    };
    return mapping[skyDescription] ?? 'assets/images/맑음.png';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return CustomLayout(
      isHome: false,
      backgroundColor: const Color(0xFFC7F2D6),
      child: Container(
        color: const Color(0xFFC7F2D6),
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: isLoading
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              const Text(
                '날씨 정보를 불러오는 중입니다...',
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'HakgyoansimGeurimilgi',
                  color: Colors.black87,
                ),
              ),
            ],
          )
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 위치
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Colors.black87,
                    size: 28,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    (fullAddress?.trim().isNotEmpty ?? false)
                        ? fullAddress!
                        : "대한민국",
                    style: const TextStyle(
                      fontFamily: 'HakgyoansimGeurimilgi',
                      fontSize: 28,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 날씨 이미지
              Image.asset(
                getWeatherImagePath(currentSky),
                width: 200,
                height: 200,
              ),
              const SizedBox(height: 12),

              // 온도
              Text(
                '${currentTemp ?? "--"}도',
                style: const TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'HakgyoansimGeurimilgi',
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '체감온도: ${perceivedTemp ?? "--"}도',
                style: const TextStyle(
                  fontSize: 30,
                  color: Colors.black54,
                  fontFamily: 'HakgyoansimGeurimilgi',
                ),
              ),
              const SizedBox(height: 36),

              // 미세먼지
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    )
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 왼쪽 아이콘
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Image.asset(
                        'assets/images/air_quality_icon.png',
                        width: 100,
                        height: 100,
                      ),
                    ),

                    // 오른쪽 텍스트 (가운데 몰리도록 조정)
                    Flexible(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            airQuality?.split(',').first.trim() ?? '미세먼지 정보 없음',
                            style: const TextStyle(
                              fontSize: 26,
                              fontFamily: 'HakgyoansimGeurimilgi',
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            airQuality?.split(',').length == 2
                                ? airQuality!.split(',')[1].trim()
                                : '초미세먼지 정보 없음',
                            style: const TextStyle(
                              fontSize: 26,
                              fontFamily: 'HakgyoansimGeurimilgi',
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
