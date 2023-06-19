import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({Key? key}) : super(key: key);

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  DatabaseReference ref = FirebaseDatabase.instance.ref().child('users');
  List<Map<String, dynamic>> userList = []; // Kullanıcı listesi
  List<Map<String, dynamic>> filteredList = []; // Filtrelenmiş kullanıcı listesi
  final TextEditingController _searchController = TextEditingController();
  bool showSearchBar = false; // Arama için controller

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);

    // Firebase veritabanından verileri çekmek için bir dinleyici oluşturulur.
    ref.onChildAdded.listen((event) {
      setState(() {
        // Kullanıcı listesine yeni bir kullanıcı eklenir.
        userList.add({
          'key': event.snapshot.key,
          'username': event.snapshot.child('username').value.toString(),
          'email': event.snapshot.child('email').value.toString(),
        });
      });
    });

    ref.onChildRemoved.listen((event) {
      setState(() {
        // Kullanıcı listesinden bir kullanıcı silinir.
        userList.removeWhere((user) => user['key'] == event.snapshot.key);
      });
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    debugPrint('Search Query: ${_searchController.text}'); // Arama sorgusunu debug loglarına ekler
    searchUser(_searchController.text);
  }

  void searchUser(String query) {
    List<Map<String, dynamic>> searchResult = [];
    searchResult = userList.where((user) {
      String userName = user['username'].toLowerCase();
      String searchQuery = query.toLowerCase();
      return userName.contains(searchQuery);
    }).toList();

    setState(() {
      filteredList = searchResult;
    });

    debugPrint('User List: $userList'); // User listesini debug loglarına ekler
    debugPrint('Filtered List: $filteredList'); // Filtrelenmiş listeyi debug loglarına ekler
  }

  void deleteUser(String userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete User'),
          content: Text('Are you sure you want to delete the user?'),
          actions: <Widget>[
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop(); // Dialog kapatılıyor
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                DatabaseReference userRef =
                FirebaseDatabase.instance.ref().child('users').child(userId);
                userRef.remove();
                Navigator.of(context).pop(); // Dialog kapatılıyor
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
        actions: <Widget>[
          if (showSearchBar)
            Expanded(
              child: Container(
                height: kToolbarHeight - 0, // AppBar boyutuna uygun hale getirir
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Search by Username",
                    hintStyle: TextStyle(color: Colors.white),
                    prefixIcon: Icon(Icons.search, color: Colors.white),
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(25.0),
                      ),
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(25.0),
                      ),
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  autofocus: true,
                  onChanged: (value) {
                    _onSearchChanged();
                  },
                  onEditingComplete: () {
                    setState(() {
                      showSearchBar = false; // Arama tamamlandığında arama çubuğunu gizler
                    });
                  },
                ),
              ),
            )
          else
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: UserSearch(userList),
                );
              },
            ),
        ],
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: filteredList.isEmpty ? userList.length : filteredList.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> user =
            filteredList.isEmpty ? userList[index] : filteredList[index];
            String? userId = user['key'];

            bool hideDeleteIcon = user['email'] == 'mymail1@gmail.com'; // Silme ikonunu gizlemek için kontrol değişkeni

            return Card(
              child: InkWell(
                onTap: hideDeleteIcon
                    ? null
                    : () {
                  deleteUser(userId!);
                },
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
                  title: Text(user['username']),
                  subtitle: Text(user['email']),
                  trailing: hideDeleteIcon
                      ? null
                      : IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      deleteUser(userId!);
                    },
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

class UserSearch extends SearchDelegate {
  final List<Map<String, dynamic>> userList;

  UserSearch(this.userList);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = "";
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
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final suggestionList = query.isEmpty
        ? userList
        : userList
        .where((user) =>
        user["username"].toString().toLowerCase().startsWith(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) => Card(
        child: InkWell(
          onTap: () {
            // deleteUser(userId!);
            // TODO: Silme işlemi burada yapılmalı
          },
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
            title: Text(suggestionList[index]['username']),
            subtitle: Text(suggestionList[index]['email']),
            trailing: suggestionList[index]['email'] == 'mymail1@gmail.com'
                ? null
                : IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                // deleteUser(userId!);
                // TODO: Silme işlemi burada yapılmalı
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = query.isEmpty
        ? userList
        : userList
        .where((user) =>
        user["username"].toString().toLowerCase().startsWith(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) => Card(
        child: InkWell(
          onTap: () {
            // deleteUser(userId!);
            // TODO: Silme işlemi burada yapılmalı
          },
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
            title: Text(suggestionList[index]['username']),
            subtitle: Text(suggestionList[index]['email']),
            trailing: suggestionList[index]['email'] == 'mymail1@gmail.com'
                ? null
                : IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                // deleteUser(userId!);
                // TODO: Silme işlemi burada yapılmalı
              },
            ),
          ),
        ),
      ),
    );
  }
}
