import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/*
 * ЗАДАНИЕ: Приложение "Погода"
 * 
 * Создайте приложение для отображения погоды.
 * 
 * 1. Реализуйте fetchWeather() для получения данных из API wttr.in
 * 2. Создайте layout используя: Column, Expanded/Flexible, SizedBox, Text, Image, FutureBuilder
 * 3. Отобразите: город, иконку, температуру, описание
 * 4. Добавьте кнопку обновления
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Погода'),
      ),
      body: Column(
        children: [
          // TODO: Заголовок

          // TODO: Expanded с FutureBuilder для отображения данных о погоде
          Expanded(
            child: Center(
              child: Text('Здесь будет FutureBuilder'),
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
 * Column(children: [...]), Expanded(child: Widget), Flexible(flex: 1, child: Widget)
 * SizedBox(height: 24), Text('Текст'), Image.network('https://...', width: 100, height: 100)
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
 * data['current_condition'][0]['weatherIconUrl'][0]['value'] - URL иконки
 */
