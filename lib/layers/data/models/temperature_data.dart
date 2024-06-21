class TemperatureData{
  final DateTime time;
  final double tempC;

  TemperatureData(this.time, this.tempC);

  factory TemperatureData.fromJSON(Map<String, dynamic> json){
    return TemperatureData(DateTime.parse(json['time']), json['temp_c'].toDouble());
  }
}