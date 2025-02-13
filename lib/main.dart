import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Simple LCK',
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.light(
          primary: Colors.white,
          onPrimary: Colors.black,
          surface: Color(0xffF1F1F1)
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
            primary: Color(0xff171717),
            surface: Colors.black,
            onPrimary: Colors.white
          ),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Simple LCK'),
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
  Map<String, List<List<String>>> matchSchedule = {
    "2월 11일" : [["team1", "team2", "team1score", "team2score", "time"]],
    "2월 12일" : [["Gen.G", "T1", "2", "1", "time"]],
    "2월 13일" : [["젠지","team2","team1score", "team2score","time"]],
    "2월 14일" : [["team1","team2","team1score", "team2score","time"]],
    "2월 15일" : [["team1","team2","team1score", "team2score","time"]],
    };
  late List<String> sortedKey;

  @override
  Widget build(BuildContext context) {
    sortedKey = matchSchedule.keys.toList();
    sortedKey.sort();
    return Scaffold(
      appBar: CupertinoNavigationBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        middle: Text("2025 LCK Cup",style: TextStyle(color: Theme.of(context).colorScheme.onPrimary))
      ),
      body: ScrollablePositionedList.builder(
        //initialScrollIndex: 2,
        itemCount: matchSchedule.length,
        itemBuilder: (context, index) {
          String currentKey = sortedKey[index];
          List<List<String>> matchOfCurrentDay = matchSchedule[currentKey] ?? [];
          
          return Padding( // 일정 블록
            padding: EdgeInsets.fromLTRB(12, 0, 12, 30
            
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding( // 날짜
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    sortedKey[index],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),
                  ),
                ),
                ...List.generate(matchOfCurrentDay.length, (i) => Card(
                  color: Theme.of(context).colorScheme.primary,
                  //elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)
                  ),
                  child: SizedBox(
                    height: 180,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${matchOfCurrentDay[i][0]} ${matchOfCurrentDay[i][2]} vs ${matchOfCurrentDay[i][3]} ${matchOfCurrentDay[i][1]} "
                          ),
                      ],
                    ),
                  ),
                ))
              ],
            ),
          );
        },
      ),
    );
  }
}

// // Card( // LCK 일정 카드
//   color: Theme.of(context).colorScheme.primary,
//   //elevation: 0,
//   shape: RoundedRectangleBorder(
//     borderRadius: BorderRadius.circular(14)
//   ),
//   child: SizedBox(
//     height: 180,
//     child: Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Text(matchSchedule[sortedKey[index]]![0][0]),
//         Text("2 "),
//         Text("vs "),
//         Text("1 "),
//         Text("T1"),
//       ],
//     ),
//   ),
// // ),