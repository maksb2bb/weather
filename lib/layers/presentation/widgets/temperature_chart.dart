import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import '../../data/models/temperature_data.dart';

class TemperatureChart extends StatelessWidget {
  final List<charts.Series<TemperatureData, DateTime>> seriesList;
  final bool animate;

  TemperatureChart(this.seriesList, {required this.animate});

  @override
  Widget build(BuildContext context) {
    return charts.TimeSeriesChart(
      seriesList,
      animate: animate,
      dateTimeFactory: const charts.LocalDateTimeFactory(),
      primaryMeasureAxis: charts.NumericAxisSpec(
        tickProviderSpec: charts.BasicNumericTickProviderSpec(zeroBound: false),
        renderSpec: charts.GridlineRendererSpec(
          labelStyle: charts.TextStyleSpec(
            fontSize: 12,
            color: charts.MaterialPalette.black,
          ),
          lineStyle: charts.LineStyleSpec(
            thickness: 1,
            color: charts.MaterialPalette.gray.shade300,
          ),
        ),
      ),
      domainAxis: charts.DateTimeAxisSpec(
        tickProviderSpec: charts.AutoDateTimeTickProviderSpec(),
        renderSpec: charts.GridlineRendererSpec(
          labelStyle: charts.TextStyleSpec(
            fontSize: 12,
            color: charts.MaterialPalette.black,
          ),
          lineStyle: charts.LineStyleSpec(
            thickness: 1,
            color: charts.MaterialPalette.gray.shade300,
          ),
        ),
      ),
    );
  }
}
