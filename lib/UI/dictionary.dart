import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Widget/drawer_menu.dart';
import './input.dart';

class Dictionary extends StatefulWidget {
  Dictionary(this.isFav);
  final bool isFav;
  @override
  _Dictionary createState() => _Dictionary();
}

class _Dictionary extends State<Dictionary>
    with SingleTickerProviderStateMixin {
  TabController tabController;
  final List<Tab> tabs = <Tab>[
    Tab(text: '英和'),
    Tab(text: '和英'),
  ];
  bool isFav;
  @override
  void initState() {
    isFav = widget.isFav;
    tabController = TabController(vsync: this, length: tabs.length);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: createAppBarText(),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.add_box),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      settings: const RouteSettings(name: "/edit"),
                      builder: (BuildContext context) => InputForm(null)),
                );
              }),
        ],
        bottom: TabBar(
          controller: tabController,
          tabs: tabs,
        ),
      ),
      drawer: DrawerMenu(),
      body: TabBarView(
        controller: tabController,
        children: tabs.map((Tab tab) {
          return SingleChildScrollView(
              child: Column(
            children: <Widget>[buildStreamBuilder(tab.text)],
          ));
        }).toList(),
      ),
    );
  }

  Widget buildStreamBuilder(String tab) {
    String queryType = "";
    if (tab == '英和') {
      queryType = 'en';
    } else {
      queryType = 'ja';
    }
    if (isFav) {
      return new StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection("dictionary")
            .where('fav', isEqualTo: true)
            .where('type', isEqualTo: queryType)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          return createStreamBuilder(context, snapshot);
        },
      );
    }
    return new StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection("dictionary")
          .where('type', isEqualTo: queryType)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        return createStreamBuilder(context, snapshot);
      },
    );
  }

  Widget createStreamBuilder(
      BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
    if (snapshot.hasError) {
      return new Text('Error: ${snapshot.error}');
    }
    switch (snapshot.connectionState) {
      case ConnectionState.waiting:
        return createLoadingText();
      default:
        return createAlign(snapshot);
    }
  }

  Widget createLoadingText() {
    return Text("Loading...");
  }

  Widget createAlign(AsyncSnapshot<QuerySnapshot> snapshot) {
    return Align(
      alignment: Alignment.topCenter,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            createPlayerNameTextColumn(snapshot),
          ]),
    );
  }

  Widget createAppBarText() {
    if (isFav) {
      return Text("お気に入り一覧");
    }
    return Text("ワード一覧");
  }

  Widget createPlayerNameTextColumn(AsyncSnapshot<QuerySnapshot> snapshot) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: snapshot.data.documents.map((DocumentSnapshot document) {
        return createWordCard(document);
      }).toList(),
    );
  }

  Widget createWordCard(DocumentSnapshot document) {
    return Card(
      child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        createWordTile(document),
        createButtonBar(document),
      ]),
    );
  }

  Widget createWordTile(DocumentSnapshot document) {
    if (document['translated'] == null) {
      return Text("Looding...");
    }

    if (document['type'] == 'en') {
      return ListTile(
        leading: const Icon(Icons.book),
        title: Text(
            document['word']),
        subtitle: Text("\n意味 ： " + document['translated']['ja'].toString()),
      );
    } else if (document['type'] == 'ja') {
      return ListTile(
        leading: const Icon(Icons.book),
        title: Text(
            document['word']),
        subtitle: Text("\n意味 ： " + document['translated']['en'].toString()),
      );
    } else {
      return Text("Error");
    }
  }

  Widget createButtonBar(DocumentSnapshot document) {
    return ButtonTheme.bar(
        child: ButtonBar(
      children: <Widget>[
        createFavIconButton(document),
        createDeleteButton(document),
      ],
    ));
  }

  Widget createEditButton(DocumentSnapshot document) {
    return FlatButton(
        child: const Text("編集"),
        onPressed: () {
          onPressEditButton(document);
        });
  }

  Widget createFavButton(DocumentSnapshot document) {
    return FlatButton(
        child: const Text("お気に入り"),
        onPressed: () {
          onPressFavButton(document);
        });
  }

  Widget createDeleteButton(DocumentSnapshot document) {
    return IconButton(
        icon: Icon(Icons.delete),
        onPressed: () {
          onPressDeleteButton(document);
        });
  }

  Widget createFavIconButton(DocumentSnapshot document) {
    if (document['fav']) {
      return IconButton(
        icon: Icon(Icons.star),
        color: Colors.cyan[800],
        onPressed: () {
          setState(() {
            onPressFavButton(document);
          });
        },
      );
    }
    return IconButton(
      icon: Icon(Icons.star_border),
      onPressed: () {
        setState(() {
          onPressFavButton(document);
        });
      },
    );
  }

  void onPressEditButton(DocumentSnapshot document) {
    Navigator.push(
      context,
      MaterialPageRoute(
          settings: const RouteSettings(name: "/edit"),
          builder: (BuildContext context) => InputForm(document)),
    );
  }

  void onPressFavButton(DocumentSnapshot document) {
    DocumentReference mainReference = Firestore.instance
        .collection('dictionary')
        .document(document.documentID);
    mainReference.updateData({'fav': !document['fav']});
  }

  void onPressDeleteButton(DocumentSnapshot document) {
    DocumentReference mainReference = Firestore.instance
        .collection('dictionary')
        .document(document.documentID);
    mainReference.delete();
  }
}
