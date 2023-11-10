import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final SqlServerService sqlServerService = SqlServerService();
  List<Map<String, dynamic>> data = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final result = await sqlServerService.fetchDataFromDatabase();
    setState(() {
      data = result;
    });
  }

  Future<void> editRow(int index) async {
    Map<String, dynamic> rowData = data[index];
    DateTime date = rowData['date'];

    TextEditingController tenCVController =
        TextEditingController(text: rowData['TenCV']);
    TextEditingController dateController =
        TextEditingController(text: DateFormat('dd/MM/yyyy').format(date));
    bool isChecked = rowData['check'] == true;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Chỉnh sửa công việc'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: tenCVController,
                decoration: InputDecoration(labelText: 'Tên Công Việc'),
              ),
              TextFormField(
                controller: dateController,
                decoration: InputDecoration(labelText: 'Ngày'),
                onTap: () async {
                  DateTime? selectedDate = await showDatePicker(
                    context: context,
                    initialDate: date ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (selectedDate != null) {
                    dateController.text =
                        DateFormat('dd/MM/yyyy').format(selectedDate);
                  }
                },
              ),
              Row(
                children: [
                  Text('Đã hoàn thành:'),
                  Checkbox(
                    value: isChecked,
                    onChanged: (newValue) {
                      setState(() {
                        isChecked = newValue!;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Lưu'),
              onPressed: () async {
                data[index]['TenCV'] = tenCVController.text;
                data[index]['date'] =
                    DateFormat('dd/MM/yyyy').parse(dateController.text, true);
                data[index]['check'] = isChecked;

                await sqlServerService.updateDataInDatabase(data[index]);

                setState(() {});

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showAddDialog(BuildContext context) {
    TextEditingController tenCVController = TextEditingController();
    TextEditingController dateController = TextEditingController();
    bool isChecked = false;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Thêm công việc mới'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: tenCVController,
                decoration: InputDecoration(labelText: 'Tên Công Việc'),
              ),
              TextFormField(
                controller: dateController,
                decoration: InputDecoration(labelText: 'Ngày'),
                onTap: () async {
                  DateTime? selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (selectedDate != null) {
                    dateController.text =
                        DateFormat('dd/MM/yyyy').format(selectedDate);
                  }
                },
              ),
              Row(
                children: [
                  Text('Đã hoàn thành:'),
                  Checkbox(
                    value: isChecked,
                    onChanged: (newValue) {
                      isChecked = newValue!;
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Lưu'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SQL Server Data'),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text('STT'),
                  ),
                  Expanded(
                    flex: 5,
                    child: Text('Tên Công Việc'),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text('Ngày'),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text('Hoàn Thành'),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text('Tùy Chỉnh'),
                  ),
                ],
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final date = data[index]['date'] as DateTime;
                  final formattedDate = DateFormat('dd/MM/yyyy').format(date);
                  Icon checkIcon = data[index]['check'] == true
                      ? Icon(Icons.check, color: Colors.green)
                      : Icon(Icons.close, color: Colors.red);
                  Icon editIcon = Icon(Icons.edit, color: Colors.blue);
                  Icon deleteIcon = Icon(Icons.delete, color: Colors.red);
                  return Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text('${data[index]['Stt']}'),
                      ),
                      Expanded(
                        flex: 5,
                        child: Text('${data[index]['TenCV']}'),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(formattedDate),
                      ),
                      Expanded(
                        flex: 1,
                        child: checkIcon,
                      ),
                      Expanded(
                        flex: 1, // Cột mới
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            GestureDetector(
                              onTap: () {
                                editRow(index);
                              },
                              child: editIcon,
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: deleteIcon,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddDialog(context);
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

class SqlServerService {
  final String baseUrl = 'http://localhost:3000';

  Future<List<Map<String, dynamic>>> fetchDataFromDatabase() async {
    final response = await http.get(Uri.parse('$baseUrl/api/data'));
    if (response.statusCode == 200) {
      final List<Map<String, dynamic>> jsonData =
          List<Map<String, dynamic>>.from(json.decode(response.body));

      // Chuyển đổi cột "date" thành kiểu dữ liệu DateTime
      jsonData.forEach((row) {
        final date = DateTime.parse(row['date']);
        row['date'] = date;
      });

      return jsonData;
    } else {
      throw Exception('Failed to load data from SQL Server.');
    }
  }

  Future<void> updateDataInDatabase(Map<String, dynamic> newData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/update-data'),
      body: jsonEncode(newData),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // Xử lý khi cập nhật thành công
    } else {
      throw Exception('Failed to update data in the database.');
    }
  }
}
