import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UserActivityListScreen extends StatefulWidget {
  const UserActivityListScreen({Key? key}) : super(key: key);

  @override
  State<UserActivityListScreen> createState() => _UserActivityListScreenState();
}

class _UserActivityListScreenState extends State<UserActivityListScreen> {
  DatabaseReference ref = FirebaseDatabase.instance.ref().child('LED_ACTIVITIES');
  List<Map<String, dynamic>> activityList = [];

  @override
  void initState() {
    super.initState();
    ref.onChildAdded.listen((event) {
      setState(() {
        activityList.add({
          'key': event.snapshot.key,
          'username': event.snapshot.child('username').value.toString(),
          'timestamp': event.snapshot.child('timestamp').value,
        });

        // Listeyi timestamp'a göre sırala
        activityList.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
      });
    });

    ref.onChildRemoved.listen((event) {
      setState(() {
        activityList.removeWhere((activity) => activity['key'] == event.snapshot.key);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              final selectedResult = await showSearch<Map<String, dynamic>>(
                context: context,
                delegate: DataSearch(activityList: activityList),
              );
              print(selectedResult);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: activityList.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> activity = activityList[index];

            return Card(
              child: InkWell(
                child: ListTile(
                  leading: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.black,
                      ),
                    ),
                    child: Icon(Icons.person_outline),
                  ),
                  title: Text(activity['username']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Date: ' + activity['timestamp']),
                      Text('User has entered the apartment.', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                    ],
                  ),
                ),
              ),
            );



          },
        ),
      ),
    );
  }
}

class DataSearch extends SearchDelegate<Map<String, dynamic>> {
  final List<Map<String, dynamic>> activityList;

  DataSearch({required this.activityList});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, {}); // Geri dönüş için boş bir Map kullanılıyor.
      },
    );
  }


  @override
  Widget buildResults(BuildContext context) {
    final List<Map<String, dynamic>> resultList = activityList.where((activity) {
      String userName = activity['username'].toLowerCase();
      String searchQuery = query.toLowerCase();
      return userName.contains(searchQuery);
    }).toList();

    return ListView.builder(
      itemCount: resultList.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(resultList[index]['username']),
          subtitle: Text('Date: ' + resultList[index]['timestamp']),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<Map<String, dynamic>> suggestionList = query.isEmpty
        ? []
        : activityList.where((activity) {
      String userName = activity['username'].toLowerCase();
      String searchQuery = query.toLowerCase();
      return userName.startsWith(searchQuery);
    }).toList();

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(suggestionList[index]['username']),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Date: ' + suggestionList[index]['timestamp']),
              Text('User has entered the apartment.', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
            ],
          ),
        );
      },
    );

  }
}
