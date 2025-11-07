import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/*
 * ЗАДАНИЕ: Приложение "Погода"
 * 
 * Создайте приложение для отображения погоды.
 * 
 * 1. Реализуйте fetchWeather() для получения данных из API wttr.in
 * 2. Создайте layout используя: Column, Row, Expanded/Flexible, SizedBox, Text, Image, FutureBuilder, Stack
 * 3. Отобразите: город, иконку, температуру, описание
 *    - Используйте Row для горизонтальной компоновки информации о погоде (иконка и температура)
 * 4. Добавьте кнопку обновления внизу экрана используя Stack
 * 
 * ВАЖНО: Не допускайте большую вложенность виджетов. Выносите компоненты 
 * в отдельные виджеты (StatelessWidget или отдельные методы).
 * 
 * ДОПОЛНИТЕЛЬНОЕ ЗАДАНИЕ 1: Scrollable list
 * Создайте прокручиваемый список с данными о погоде для трех городов:
 * Москва, Париж, Лондон. Используйте ListView или ListView.builder.
 * 
 * ДОПОЛНИТЕЛЬНОЕ ЗАДАНИЕ 2: Theme
 * Используйте Theme для настройки темы приложения (цвета, стили текста).
 * Добавьте переключатель между светлой и темной темой.
 * 
 * ПОДСКАЗКИ см. внизу файла
 */

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Погода',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String city = 'Moscow';
  Future<Map<String, dynamic>>? weatherFuture;

  @override
  void initState() {
    super.initState();
    // TODO: Инициализируйте weatherFuture
  }

  // TODO: Реализуйте функцию для получения данных о погоде
  Future<Map<String, dynamic>> fetchWeather() async {
    throw UnimplementedError();
  }

  // Функция для выбора иконки в зависимости от описания погоды
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
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Погода',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // TODO: Expanded с FutureBuilder для отображения данных о погоде
          // Используйте Stack для размещения кнопки внизу поверх контента
          Expanded(
            child: Stack(
              children: [
                // TODO: FutureBuilder с данными о погоде
                Center(
                  child: Text('Здесь будет FutureBuilder'),
                ),
                // TODO: Кнопка обновления внизу экрана используя Positioned
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/*
 * ПОДСКАЗКИ:
 * 
 * ВИДЖЕТЫ КОМПОНОВКИ:
 * Column(children: [...]), Row(children: [...]), Expanded(child: Widget), Flexible(flex: 1, child: Widget)
 * SizedBox(height: 24), Text('Текст'), Image.network('https://...', width: 100, height: 100)
 * Stack(children: [Widget1, Positioned(bottom: 16, child: Widget2)]) - для наложения виджетов
 * 
 * FutureBuilder(future: weatherFuture, builder: (context, snapshot) {
 *   if (snapshot.connectionState == ConnectionState.waiting) return CircularProgressIndicator();
 *   if (snapshot.hasError) return Text('Ошибка');
 *   if (snapshot.hasData) { final data = snapshot.data; /* отобразите данные */ }
 * })
 * 
 * SCROLLABLE LIST:
 * ListView(children: [Widget1, Widget2, Widget3])
 * ListView.builder(itemCount: cities.length, itemBuilder: (context, index) { ... })
 * 
 * THEME:
 * ThemeData(
 *   colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
 *   textTheme: TextTheme(headlineLarge: TextStyle(fontSize: 32)),
 * )
 * Theme.of(context).colorScheme.primary
 * Theme.of(context).textTheme.headlineLarge
 * 
 * API: https://wttr.in/$city?format=j1
 * data['current_condition'][0]['temp_C'] - температура
 * data['current_condition'][0]['weatherDesc'][0]['value'] - описание
 * 
 * ИКОНКА:
 * Используйте функцию _getWeatherIcon(description) для получения иконки.
 * Используйте Icon виджет для отображения иконки.
 */
