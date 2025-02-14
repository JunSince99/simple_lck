import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'manage_fetching.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko');
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
  late List<String> sortedKey;
  late Map<String, List<List<String>>>? matchSchedule = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // 비동기 함수를 호출하고 결과를 기다립니다.
    dynamic temp = await ManageFetching().fetchMatchSchedule('data:LCK/2025 Season/Cup');
    // 처리 후에 상태를 업데이트 합니다.
    setState(() {
      matchSchedule = ManageFetching().textPostProcessing(temp);
    });
  }

  String getWeekday(String key) {
    final regExp = RegExp(r'(\d+)월\s*(\d+)일');
    final match = regExp.firstMatch(key);
    if (match != null) {
      final month = int.parse(match.group(1)!);
      final day = int.parse(match.group(2)!);
      final date = DateTime(2025, month, day);
      // 'EEE'를 사용하면 요일의 축약형을 얻을 수 있습니다. 예: "토"
      return DateFormat('EEE', 'ko').format(date);
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    if (matchSchedule == null || matchSchedule!.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    sortedKey = matchSchedule!.keys.toList();

    final now = DateTime.now();
    final today2025 = DateTime(2025, now.month, now.day);

    // 초기 인덱스를 찾기 위한 변수
    int initialIndex = -1;

    // 오늘부터 30일 뒤까지 반복하며, 해당 날짜에 맞는 key를 찾는다.
    for (int i = 0; i < 30; i++) {
    DateTime dateToCheck = today2025.add(Duration(days: i));
    String keyToCheck = DateFormat('M월 d일').format(dateToCheck);

      // sortedKey에서 keyToCheck와 일치하는 인덱스를 찾는다.
      int foundIndex = sortedKey.indexWhere((key) => key == keyToCheck);
      if (foundIndex != -1) {
        initialIndex = foundIndex;
        break;
      }
    }

    // 만약 30일 내에 해당하는 key를 찾지 못하면, 마지막 인덱스로 설정
    if (initialIndex == -1) {
      initialIndex = sortedKey.length - 1;
    }

    return Scaffold(
      appBar: CupertinoNavigationBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        middle: Text("2025 LCK Cup",style: TextStyle(color: Theme.of(context).colorScheme.onPrimary))
      ),
      body: ScrollablePositionedList.builder(
        initialScrollIndex: initialIndex,
        itemCount: matchSchedule!.length,
        itemBuilder: (context, index) {
          String currentKey = sortedKey[index];
          List<List<String>> matchOfCurrentDay = matchSchedule![currentKey] ?? [];
          
          return Padding( // 일정 블록
            padding: EdgeInsets.fromLTRB(12, 0, 12, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding( // 날짜
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    "${sortedKey[index]} (${getWeekday(sortedKey[index])})",
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