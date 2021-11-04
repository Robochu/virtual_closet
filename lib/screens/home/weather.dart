import 'package:flutter/material.dart';
import 'package:weather_icons/weather_icons.dart';
/*
* Stateless widget to give a summary of current weather
 */

class WeatherSummary extends StatelessWidget {
  final double? currTemp;
  final double? feelLike;
  final String weatherText;
  final String weatherIconText;

  const WeatherSummary(
      {Key? key,
        required this.weatherText,
        required this.currTemp,
        required this.feelLike,
        required this.weatherIconText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.all(15.0),
        color: Colors.blue,
        height: 70,
        width: 170,
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Column(
            children: [
              Text(
                '${_formatTemperature(currTemp)}°F',
                style: const TextStyle(
                  fontSize: 30,
                ),
              ),
              Text(
                weatherText,
                style: const TextStyle(fontSize: 11),
              ),
              Text('Feel like ${_formatTemperature(feelLike)}°F',
                  style: const TextStyle(fontSize: 11))
            ],
          ),
          Icon(
              WeatherIcons.fromString(weatherIconText,
                  fallback: WeatherIcons.na),
              size: 40)
        ]));
  }

  String _formatTemperature(double? t) {
    var temp = (t == null ? '' : t.round().toString());
    return temp;
  }
}