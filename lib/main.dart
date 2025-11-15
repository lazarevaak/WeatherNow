import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}


Future<Map<String, dynamic>> fetchWeather(String city) async {
  final url = Uri.parse('https://wttr.in/$city?format=j1');
  final r = await http.get(url);

  if (r.statusCode != 200) {
    throw Exception('Ошибка загрузки');
  }

  return jsonDecode(r.body);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDark = false;

  void _toggleTheme() {
    setState(() {
      _isDark = !_isDark;
    });
  }

  ThemeData _buildTheme(
    Color seedColor, {
    Brightness brightness = Brightness.light,
  }) {
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: brightness,
      ),
      useMaterial3: true,
    );

    return base.copyWith(
      appBarTheme: base.appBarTheme.copyWith(
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: base.cardTheme.copyWith(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      textTheme: base.textTheme.copyWith(
        headlineMedium: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: const TextStyle(fontSize: 18),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Погода',
      debugShowCheckedModeBanner: false,
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      theme: _buildTheme(Colors.blue, brightness: Brightness.light),
      darkTheme: _buildTheme(
        Colors.deepPurple,
        brightness: Brightness.dark,
      ),
      home: WeatherScreen(
        onToggleTheme: _toggleTheme,
        isDark: _isDark,
      ),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDark;

  const WeatherScreen({
    super.key,
    required this.onToggleTheme,
    required this.isDark,
  });

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final List<String> cities = ["Moscow", "Paris", "London"];

  String city = 'Moscow';
  Future<Map<String, dynamic>>? weatherFuture;

  final Map<String, Future<Map<String, dynamic>>> _cityWeatherFutures = {};

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  void _loadWeather() {
    setState(() {
      for (final c in cities) {
        _cityWeatherFutures[c] = fetchWeather(c);
      }
      weatherFuture = _cityWeatherFutures[city];
    });
  }

  IconData _getWeatherIcon(String description) {
    final desc = description.toLowerCase();
    if (desc.contains('sunny') || desc.contains('clear')) {
      return Icons.wb_sunny;
    } else if (desc.contains('cloudy') || desc.contains('overcast')) {
      return Icons.cloud;
    } else if (desc.contains('rain') || desc.contains('drizzle')) {
      return Icons.grain;
    } else if (desc.contains('snow')) {
      return Icons.ac_unit;
    } else if (desc.contains('fog') || desc.contains('mist')) {
      return Icons.filter_drama;
    } else if (desc.contains('thunder')) {
      return Icons.flash_on;
    } else {
      return Icons.wb_cloudy;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mainTextColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
  body: SafeArea(
    child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer.withOpacity(0.6),
            colorScheme.surface,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: mainTextColor,
            title: const Text(
              'Погода',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                onPressed: widget.onToggleTheme,
                icon: Icon(
                  widget.isDark ? Icons.dark_mode : Icons.light_mode,
                ),
              ),
            ],
          ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    children: [
                      CitySelectorRow(
                        cities: cities,
                        selectedCity: city,
                        onCityChanged: (value) {
                          setState(() {
                            city = value;
                            weatherFuture = _cityWeatherFutures[city];
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: Stack(
                          children: [
                            FutureBuilder<Map<String, dynamic>>(
                              future: weatherFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                if (snapshot.hasError) {
                                  return Center(
                                    child: Text(
                                      'Ошибка: ${snapshot.error}',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: mainTextColor),
                                    ),
                                  );
                                }

                                if (!snapshot.hasData) {
                                  return Center(
                                    child: Text(
                                      'Нет данных',
                                      style: TextStyle(color: mainTextColor),
                                    ),
                                  );
                                }

                                final data = snapshot.data!;
                                final current = data['current_condition'][0];
                                final temp = current['temp_C'] as String;
                                final desc = current['weatherDesc'][0]['value']
                                    as String;

                                final otherCities = cities
                                    .where((c) => c != city)
                                    .toList(growable: false);

                                return SingleChildScrollView(
                                  padding:
                                      const EdgeInsets.only(bottom: 80.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Card(
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: _MainCityWeather(
                                            city: city,
                                            tempC: temp,
                                            description: desc,
                                            icon: _getWeatherIcon(desc),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      Text(
                                        'Погода в других городах',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: mainTextColor,
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      SizedBox(
                                        height: 200,
                                        child: ListView.separated(
                                          itemCount: otherCities.length,
                                          separatorBuilder: (_, __) =>
                                              const SizedBox(height: 4),
                                          itemBuilder: (context, index) {
                                            final otherCity =
                                                otherCities[index];
                                            final future =
                                                _cityWeatherFutures[otherCity];
                                            if (future == null) {
                                              return Text(
                                                '$otherCity: нет данных',
                                                style: TextStyle(
                                                    color: mainTextColor),
                                              );
                                            }
                                            return OtherCityWeatherCard(
                                              city: otherCity,
                                              getWeatherIcon: _getWeatherIcon,
                                              weatherFuture: future,
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: Center(
                                child: FilledButton.icon(
                                  onPressed: _loadWeather,
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Обновить'),
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CitySelectorRow extends StatelessWidget {
  final List<String> cities;
  final String selectedCity;
  final ValueChanged<String> onCityChanged;

  const CitySelectorRow({
    super.key,
    required this.cities,
    required this.selectedCity,
    required this.onCityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final labelStyle =
        Theme.of(context).textTheme.titleMedium?.copyWith(color: textColor);

    return Row(
      children: [
        Text(
          'Город:',
          style: labelStyle,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: DropdownButton<String>(
                isExpanded: true,
                value: selectedCity,
                underline: const SizedBox.shrink(),
                items: cities
                    .map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Text(
                          c,
                          style: TextStyle(color: textColor),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  onCityChanged(value);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class OtherCityWeatherCard extends StatelessWidget {
  final String city;
  final IconData Function(String) getWeatherIcon;
  final Future<Map<String, dynamic>> weatherFuture;

  const OtherCityWeatherCard({
    super.key,
    required this.city,
    required this.getWeatherIcon,
    required this.weatherFuture,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Card(
      color: colorScheme.surfaceVariant.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: FutureBuilder<Map<String, dynamic>>(
          future: weatherFuture,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return Row(
                children: [
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Text(city, style: TextStyle(color: textColor)),
                ],
              );
            }

            if (snap.hasError) {
              return Text(
                '$city: ошибка загрузки',
                style: TextStyle(color: textColor),
              );
            }

            if (!snap.hasData) {
              return Text(
                '$city: нет данных',
                style: TextStyle(color: textColor),
              );
            }

            final current = snap.data!['current_condition'][0];
            final temp = current['temp_C'] as String;
            final desc = current['weatherDesc'][0]['value'] as String;

            return Row(
              children: [
                Icon(
                  getWeatherIcon(desc),
                  size: 28,
                  color: textColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        city,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        desc,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: textColor.withOpacity(0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$temp°C',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MainCityWeather extends StatelessWidget {
  final String city;
  final String tempC;
  final String description;
  final IconData icon;

  const _MainCityWeather({
    super.key,
    required this.city,
    required this.tempC,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          city,
          style: textTheme.headlineMedium?.copyWith(color: textColor),
        ),

        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: textColor),
            const SizedBox(width: 16),
            Text(
              '$tempC°C',
              style: textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Text(
          description,
          textAlign: TextAlign.center,
          style: textTheme.titleMedium?.copyWith(
            color: textColor.withOpacity(0.85),
          ),
        ),

        const SizedBox(height: 16),

        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
          width: double.infinity,
          height: 240,
          child: Image.network(
          'https://wttr.in/${city}_0.png?m',
          fit: BoxFit.contain,
          alignment: Alignment.topCenter,
            ),
          ),
        )
      ],
    );
  }
}



