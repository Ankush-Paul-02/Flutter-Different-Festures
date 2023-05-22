import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Student {
  final int studentId;
  final String studentName;

  const Student({required this.studentId, required this.studentName});
}

class SearchNotifier extends ChangeNotifier {
  final List<Student> students = [
    const Student(studentId: 0, studentName: 'Ankush'),
    const Student(studentId: 1, studentName: 'Purbanka'),
    const Student(studentId: 2, studentName: 'Shouvik'),
    const Student(studentId: 3, studentName: 'Deepon'),
    const Student(studentId: 4, studentName: 'Sidhant'),
    const Student(studentId: 5, studentName: 'Sukanta'),
  ];

  final List<Student> queriedStudents = [];

  String? query;
  void setQuery({required String value}) {
    query = value;
    notifyListeners();
  }

  void queryData() {
    queriedStudents.clear();
    for (Student student in students) {
      if (query != null) {
        if (!queriedStudents.contains(student)) {
          if (student.studentId.toString().toLowerCase().contains(query!.toLowerCase())) {
            queriedStudents.add(student);
            notifyListeners();
          }
        }
      }
    }
  }

  void clearSearch() {
    queriedStudents.clear();
    query = null;
    notifyListeners();
  }
}

class FlutterSearch extends StatefulWidget {
  const FlutterSearch({super.key});

  @override
  State<FlutterSearch> createState() => _FlutterSearchState();
}

class _FlutterSearchState extends State<FlutterSearch> {
  SearchNotifier searchNotifier({required bool renderUI}) =>
      Provider.of<SearchNotifier>(context, listen: renderUI);

  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isQueryNull = searchNotifier(renderUI: true).query == null;
    List<Student> students = isQueryNull
        ? searchNotifier(renderUI: true).students
        : searchNotifier(renderUI: true).queriedStudents;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 60,
          backgroundColor: Colors.purpleAccent,
          centerTitle: true,
          title: const Text(
            'Flutter Search Bar',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            children: [
              SearchBar(
                controller: searchController,
                hintText: 'Search...',
                leading: const Icon(Icons.search),
                trailing: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.mic),
                  ),
                ],
                onChanged: (value) {
                  if (value != "") {
                    searchNotifier(renderUI: false).setQuery(value: value);
                    searchNotifier(renderUI: false).queryData();
                  } else {
                    searchNotifier(renderUI: false).clearSearch();
                  }
                },
              ),
              const SizedBox(height: 25),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: students.length,
                  itemBuilder: (BuildContext context, int index) {
                    Student student = students[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: ListTile(
                        tileColor: Colors.purpleAccent,
                        leading: CircleAvatar(
                          child: Center(
                            child: Text(student.studentName.substring(0, 2)),
                          ),
                        ),
                        title: Text(
                          student.studentName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
