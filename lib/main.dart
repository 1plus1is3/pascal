import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:charts_flutter/flutter.dart' as charts;

void main() {
  runApp(PascalApp());
}

class TemperatureData {
  final DateTime time;
  final num temperature;

  TemperatureData(this.time, this.temperature);
}

class PressureData {
  final DateTime time;
  final num pressure;

  PressureData(this.time, this.pressure);
}

class PascalApp extends StatefulWidget {
  @override
  _PascalAppState createState() => _PascalAppState();
}

class _PascalAppState extends State<PascalApp> {
  List<TemperatureData> temperatureData = [];
  List<PressureData> pressureData = [];

  Future<void> fetchWeatherData() async {
    final apiKey = 'YOUR_API_KEY';
    final String city = 'Tokyo,JP';
    final url =
        'https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apiKey&lang=ja&units=metric';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List<dynamic> forecasts = jsonData['list'];

        setState(() {
          temperatureData.clear();
          pressureData.clear();

          if (jsonData['list'] != null) {
            for (var forecast in forecasts) {
              final num temperature = forecast['main']['temp_max'];
              final num pressure = forecast['main']['pressure'];
              final int timestamp = forecast['dt'];
              final DateTime time = DateTime.fromMillisecondsSinceEpoch(
                  timestamp * 1000, isUtc: true).toLocal();

              temperatureData.add(TemperatureData(time, temperature));
              pressureData.add(PressureData(time, pressure));
            } // for
          } // if

        }); //setState
      } else {
        throw Exception('Failed to fetch weather data');
      }
    } catch (error) {
      throw Exception('Failed to fetch weather data: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchWeatherData();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black87,
        appBar: AppBar(
          title: const Text('Pascal'),
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: Container(
          color: Colors.black87,
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView(
                  children: [
                    Container(
                      height: 400,
                      child: TemperatureChart(
                        temperatureData: temperatureData,
                      ),
                    ),
                    Container(
                      height: 400,
                      child: PressureChart(
                        pressureData: pressureData,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      )
    );
  }
}

class TemperatureChart extends StatelessWidget {
  final List<TemperatureData> temperatureData;

  TemperatureChart({required this.temperatureData});

  List<charts.Series<TemperatureData, DateTime>> _createSeries() {
    return [
      charts.Series<TemperatureData, DateTime>(
        id: 'Temperature',
        data: temperatureData,
        domainFn: (TemperatureData data, _) => data.time,
        measureFn: (TemperatureData data, _) => data.temperature,
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return charts.TimeSeriesChart(
      _createSeries(),
      animate: true,
      primaryMeasureAxis: charts.NumericAxisSpec(
        tickProviderSpec: charts.BasicNumericTickProviderSpec(
          desiredTickCount: 6,
        ),
        renderSpec: charts.GridlineRendererSpec(
          labelStyle: charts.TextStyleSpec(
            color: charts.ColorUtil.fromDartColor(Colors.white),
          ),
          lineStyle: charts.LineStyleSpec(
            thickness: 1,
            color: charts.ColorUtil.fromDartColor(Colors.white.withOpacity(0.3)),
          ),
        ),
      ),
      domainAxis: charts.DateTimeAxisSpec(
        tickFormatterSpec: charts.AutoDateTimeTickFormatterSpec(
          hour: charts.TimeFormatterSpec(
            format: 'MM/dd HH:mm',
            transitionFormat: 'MM/dd HH:mm',
          ),
        ),
        renderSpec: charts.SmallTickRendererSpec(
          labelStyle: charts.TextStyleSpec(
            color: charts.ColorUtil.fromDartColor(Colors.white),
          ),
          lineStyle: charts.LineStyleSpec(
            thickness: 1,
            color: charts.ColorUtil.fromDartColor(Colors.white.withOpacity(0.3)),
          ),
        ),
      ),
    );
  }
}

class PressureChart extends StatelessWidget {
  final List<PressureData> pressureData;

  PressureChart({required this.pressureData});

  List<charts.Series<PressureData, DateTime>> _createSeries() {
    return [
      charts.Series<PressureData, DateTime>(
        id: 'Pressure',
        data: pressureData,
        domainFn: (PressureData data, _) => data.time,
        measureFn: (PressureData data, _) => data.pressure,
        colorFn: (_, __) => charts.MaterialPalette.purple.shadeDefault,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return charts.TimeSeriesChart(
      _createSeries(),
      animate: true,
      primaryMeasureAxis: charts.NumericAxisSpec(
        tickProviderSpec: const charts.BasicNumericTickProviderSpec(
          desiredTickCount: 6,
          desiredMinTickCount: 10,
          zeroBound: false,
          dataIsInWholeNumbers: false,
        ),
        renderSpec: charts.GridlineRendererSpec(
          labelStyle: charts.TextStyleSpec(
            color: charts.ColorUtil.fromDartColor(Colors.white),
          ),
          lineStyle: charts.LineStyleSpec(
            thickness: 1,
            color: charts.ColorUtil.fromDartColor(Colors.white.withOpacity(0.3)),
          ),
        ),
        viewport: const charts.NumericExtents(980, 1025),
      ),
      domainAxis: charts.DateTimeAxisSpec(
        tickFormatterSpec: charts.AutoDateTimeTickFormatterSpec(
          hour: charts.TimeFormatterSpec(
            format: 'MM/dd HH:mm',
            transitionFormat: 'MM/dd HH:mm',
          ),
        ),
        renderSpec: charts.SmallTickRendererSpec(
          labelStyle: charts.TextStyleSpec(
            color: charts.ColorUtil.fromDartColor(Colors.white),
          ),
          lineStyle: charts.LineStyleSpec(
            thickness: 1,
            color: charts.ColorUtil.fromDartColor(Colors.white.withOpacity(0.3)),
          ),
        ),
      ),
    );
  }
}


















