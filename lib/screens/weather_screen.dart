import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_cast/services/reminder_service.dart';
import 'package:weather_cast/services/weather_service.dart';

// Function to get the weather icon URL based on the icon code
String getWeatherIconUrl(String iconCode) {
  // If the icon is '01n', replace it with '01d'
  if (iconCode == '01n') {
    iconCode = '01d';
  }
  return 'https://openweathermap.org/img/wn/$iconCode@2x.png';
}

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherService _weatherService = WeatherService();
  final ReminderService _reminderService = ReminderService();

  String _city = 'Colombo';
  Map<String, dynamic>? _weatherData;
  Map<String, dynamic>? _forecastData;
  bool _isLoading = true;

  Future<void> fetchLocationAndWeather() async {
    final currentWeather =
        await _weatherService.fetchWeatherForCurrentLocation();
    final currentForecast =
        await _weatherService.fetchForecastForCurrentLocation();
    if (mounted) {
      setState(() {
        _weatherData = currentWeather;
        _forecastData = currentForecast;
        _isLoading = false;
      });
    }
  }

  Future<void> fetchWeatherByCity(String city) async {
    final weather = await _weatherService.fetchWeather(city: city);
    final forecast = await _weatherService.fetchForecast(city: city);
    if (mounted) {
      setState(() {
        _weatherData = weather;
        _forecastData = forecast;
        _city = city;
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    fetchLocationAndWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color.fromARGB(255, 208, 226, 242),
      // backgroundColor: const Color.fromARGB(255, 185, 207, 227),
      backgroundColor: const Color.fromARGB(255, 193, 213, 230),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 106, 138, 165),
        title: Text(
          'Weather App',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              color: Colors.white,
            ),
            onPressed: () async {
              // Show search dialog
              final city = await showDialog(
                context: context,
                builder: (context) => SearchDialog(),
              );
              if (city != null) {
                await fetchWeatherByCity(city);
              }
            },
          ),
          IconButton(
            icon: Icon(
              Icons.location_on,
              color: Colors.white,
            ),
            onPressed: fetchLocationAndWeather,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _weatherData == null
              ? Center(
                  child: Text('Weather not available',
                      style: TextStyle(fontSize: 18, color: Colors.black54)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Current Weather Display
                      SizedBox(height: 20),

                      Text(
                        _weatherData!['name'],
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      // SizedBox(height: 8),
                      // SizedBox(height: 2),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Stack(children: [
                              Opacity(
                                  child: Image.network(
                                      getWeatherIconUrl(
                                          _weatherData!['weather'][0]['icon']),
                                      width: 83,
                                      height: 82,
                                      // color: const Color.fromARGB(255, 106, 138, 165),
                                      color: Colors.black),
                                  opacity: 0.3),
                              ClipRect(
                                  child: BackdropFilter(
                                filter:
                                    ImageFilter.blur(sigmaX: 3.0, sigmaY: 2.0),
                                child: Image.network(
                                  getWeatherIconUrl(
                                      _weatherData!['weather'][0]['icon']),
                                  width: 80,
                                  height: 80,
                                  // color: const Color.fromARGB(255, 106, 138, 165),
                                ),
                              ))
                            ]),
                            // Display weather icon based on the API's icon code
                            // Image.network(
                            //   getWeatherIconUrl(
                            //       _weatherData!['weather'][0]['icon']),
                            //   width: 80,
                            //   height: 80,
                            // ),
                            Text(
                              '${_weatherData!['main']['temp']}°C',
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ]),
                      SizedBox(height: 2),

                      Text(
                        'L:${_weatherData!['main']['temp_min']} H:${_weatherData!['main']['temp_max']}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 20),
                      Card(
                        // color: const Color.fromARGB(255, 255, 246, 246),
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              WeatherDetailRow(
                                icon: Icons.water_drop,
                                label: 'Humidity',
                                value: '${_weatherData!['main']['humidity']}%',
                              ),
                              Divider(),
                              WeatherDetailRow(
                                icon: Icons.air,
                                label: 'Wind Speed',
                                value: '${_weatherData!['wind']['speed']} m/s',
                              ),
                              Divider(),
                              WeatherDetailRow(
                                icon: Icons.thermostat,
                                label: 'Pressure',
                                value:
                                    '${_weatherData!['main']['pressure']} hPa',
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),

                      // Forecast Display
                      _forecastData != null
                          ? buildForecast()
                          : Text(
                              'No forecast data available.',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                    ],
                  ),
                ),
    );
  }

  Widget buildForecast() {
    final Map<String, List<dynamic>> groupedForecast = {};
    final List<dynamic> todayForecast = [];
    List<dynamic> dailyForecast = [];

    final todayDate = DateTime.now().toLocal().toString().split(' ')[0];

    // Group forecast data by date and separate today's data
    for (var entry in _forecastData!['list']) {
      final date = entry['dt_txt'].split(' ')[0];
      if (date == todayDate) {
        todayForecast.add(entry);
      } else {
        if (groupedForecast[date] == null) {
          groupedForecast[date] = [];
        }
        groupedForecast[date]!.add(entry);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Today's Hourly Forecast
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Today's Hourly Forecast",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
        Container(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: todayForecast.length,
            itemBuilder: (context, index) {
              final weather = todayForecast[index];
              final time = DateTime.parse(weather['dt_txt']).toLocal();
              final temp = weather['main']['temp'];
              final description = weather['weather'][0]['description'];

              return Card(
                // color: const Color.fromARGB(255, 205, 221, 228),
                margin: EdgeInsets.symmetric(horizontal: 6),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),

                      // border: Border.all(
                      //     color: const Color.fromARGB(255, 120, 156, 188),
                      //     width: 1.5), // Optional border
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${time.hour}:00',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 5),
                          Stack(children: [
                            Opacity(
                                child: Image.network(
                                    getWeatherIconUrl(
                                        weather!['weather'][0]['icon']),
                                    width: 43,
                                    height: 42,
                                    // color: const Color.fromARGB(255, 106, 138, 165),
                                    color: Colors.black),
                                opacity: 0.35),
                            ClipRect(
                                child: BackdropFilter(
                              filter:
                                  ImageFilter.blur(sigmaX: 4.0, sigmaY: 3.0),
                              child: Image.network(
                                getWeatherIconUrl(
                                    weather!['weather'][0]['icon']),
                                width: 40,
                                height: 40,
                                // color: const Color.fromARGB(255, 106, 138, 165),
                              ),
                            ))
                          ]),
                          // Image.network(
                          //   getWeatherIconUrl(weather!['weather'][0]['icon']),
                          //   width: 40,
                          //   height: 40,
                          //   // color: const Color.fromARGB(255, 106, 138, 165),
                          // ),
                          // Icon(Icons.thermostat, size: 28),
                          Text(
                            '$temp°C',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 5),
                          Text(
                            description,
                            style: TextStyle(fontSize: 12),
                          ),
                          // IconButton(
                          //   icon: Icon(Icons.notifications),
                          //   onPressed: () {
                          //     _showReminderDialog(time, temp, description);
                          //   },
                          // ),
                        ],
                      ),
                    )),
              );
            },
          ),
        ),

        SizedBox(height: 25),

        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            '5-Day Forecast',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
        Column(
          children: groupedForecast.entries.map((entry) {
            final date = entry.key;
            final weatherList = entry.value;

            return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  margin: EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Column(
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          date,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Column(
                          children: weatherList.map<Widget>((weather) {
                            final time =
                                DateTime.parse(weather['dt_txt']).toLocal();
                            final temp = weather['main']['temp'];
                            final description =
                                weather['weather'][0]['description'];
                            return ListTile(
                              leading: Stack(children: [
                                Opacity(
                                    child: Image.network(
                                        getWeatherIconUrl(
                                            weather!['weather'][0]['icon']),
                                        width: 43,
                                        height: 42,
                                        // color: const Color.fromARGB(255, 106, 138, 165),
                                        color: Colors.black),
                                    opacity: 0.35),
                                ClipRect(
                                    child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                      sigmaX: 4.0, sigmaY: 3.0),
                                  child: Image.network(
                                    getWeatherIconUrl(
                                        weather!['weather'][0]['icon']),
                                    width: 40,
                                    height: 40,
                                    // color: const Color.fromARGB(255, 106, 138, 165),
                                  ),
                                ))
                              ]),
                              // Image.network(
                              //       getWeatherIconUrl(
                              //           weather!['weather'][0]['icon']),
                              //       width: 40,
                              //       height: 40,
                              //       color: const Color.fromARGB(255, 106, 138, 165),
                              //     ),
                              title: Text('$temp°C - $description',
                                  style: TextStyle(fontSize: 14)),
                              subtitle: Text('${time.hour}:00'),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.notifications_outlined,
                                  color: Colors.blueGrey,
                                ),
                                onPressed: () {
                                  _showReminderDialog(time, temp, description);
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ));
          }).toList(),
        ),
      ],
    );
  }

  // _showReminderDialog function
  _showReminderDialog(
      DateTime dateTime, double temp, String description) async {
    String title = '';
    String descriptionText = 'Weather: $description, Temp: $temp°C';
    DateTime selectedDateTime = dateTime;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Set Reminder'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: TextEditingController(text: title),
                    decoration: InputDecoration(hintText: 'Reminder Title'),
                    onChanged: (value) => title = value,
                  ),
                  TextField(
                    controller: TextEditingController(text: descriptionText),
                    decoration: InputDecoration(hintText: 'Description'),
                    onChanged: (value) => descriptionText = value,
                  ),
                  SizedBox(height: 10),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            // Show Date Picker
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: selectedDateTime,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2101),
                            );
                            if (pickedDate != null) {
                              setDialogState(() {
                                selectedDateTime = DateTime(
                                  pickedDate.year,
                                  pickedDate.month,
                                  pickedDate.day,
                                  selectedDateTime.hour,
                                  selectedDateTime.minute,
                                );
                              });
                            }
                          },
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today),
                              SizedBox(width: 8),
                              Text(
                                DateFormat('yyyy-MM-dd')
                                    .format(selectedDateTime),
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        GestureDetector(
                          onTap: () async {
                            // Show Time Picker
                            TimeOfDay? pickedTime = await showTimePicker(
                              context: context,
                              initialTime:
                                  TimeOfDay.fromDateTime(selectedDateTime),
                            );
                            if (pickedTime != null) {
                              setDialogState(() {
                                selectedDateTime = DateTime(
                                  selectedDateTime.year,
                                  selectedDateTime.month,
                                  selectedDateTime.day,
                                  pickedTime.hour,
                                  pickedTime.minute,
                                );
                              });
                            }
                          },
                          child: Row(
                            children: [
                              Icon(Icons.access_time),
                              SizedBox(width: 8),
                              Text(
                                DateFormat('HH:mm').format(selectedDateTime),
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        )
                      ]),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (title.isNotEmpty && selectedDateTime != null) {
                      await _reminderService.createReminder(
                          title, descriptionText, selectedDateTime.toString());
                      Navigator.pop(context);
                    }
                  },
                  child: Text('Add Reminder'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class WeatherDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const WeatherDetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 22, color: const Color.fromARGB(255, 106, 138, 165)),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 14),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class SearchDialog extends StatefulWidget {
  @override
  _SearchDialogState createState() => _SearchDialogState();
}

class _SearchDialogState extends State<SearchDialog> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Search City'),
      content: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Enter city name',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(null);
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(_searchController.text);
          },
          child: Text('Search'),
        ),
      ],
    );
  }
}
