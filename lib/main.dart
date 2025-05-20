import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:home_widget/home_widget.dart';


import 'manage_fetching.dart';

/* ─────────────────────────  한-글 표기 맵  ────────────────────────── */
Map<String, String> teamInKr = {
  "OKSavingsBank BRION": "OK저축은행", "DRX": "DRX", "DN Freecs": "DNF",
  "Nongshim RedForce": "농심", "BNK FEARX": "BFX", "KT Rolster": "KT",
  "Dplus KIA": "DK", "T1": "T1", "Gen.G": "젠지", "Hanwha Life Esports": "한화생명"
};

Map<String, String> tabInKr = {
  "Play-In Round 1": "플레이인 1R", "Play-In Round 2": "플레이인 2R",
  "Play-In Round 3": "플레이인 3R", "Playoffs Round 1": "플레이오프 1R",
  "Playoffs Round 2": "플레이오프 2R", "Playoffs Round 3": "플레이오프 3R",
  "Finals": "결승전"
};

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await HomeWidget.setAppGroupId('group.com.JunSince99.simplelck');
  await initializeDateFormatting('ko');
  runApp(const MyApp());
}

/* ────────────────────────────  앱  ───────────────────────────── */
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Simple LCK',
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: Colors.white, onPrimary: Colors.black, surface: Color(0xffF1F1F1)),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xff171717), surface: Colors.black, onPrimary: Colors.white),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

/* ────────────────────────  홈 위젯  ─────────────────────────── */
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  /* Remote Config 값 */
  String? tournamentTitle;   // 예: LCK 2025 1-2R
  String? tournamentPath;    // 예: data:LCK/2025 Season/Rounds 1-2


  
  Map<String, List<Map<String, String>>>? matchSchedule;
  late List<String> sortedKey;
  final ItemScrollController _scroll = ItemScrollController();

  @override
  void initState() {
    super.initState();
    _fetchRemoteConfig();          // ① 대회 정보 받아오고
  }

  /* ───────────────  Remote Config  ─────────────── */
  Future<void> _fetchRemoteConfig() async {
    final rc = FirebaseRemoteConfig.instance;

    await rc.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: const Duration(hours: 1),
    ));

    await rc.setDefaults(<String, dynamic>{
      'lck_tournament_title': 'LCK 2025 2R',
      'lck_tournament_path': 'data:LCK/2025 Season/Rounds 1-2',
    });

    try {
      await rc.fetchAndActivate();
    } catch (_) {}

    tournamentTitle = rc.getString('lck_tournament_title').trim();
    tournamentPath  = rc.getString('lck_tournament_path').trim();

    if ((tournamentTitle ?? '').isEmpty || (tournamentPath ?? '').isEmpty) {
      tournamentTitle = 'LCK 2025';
      tournamentPath  = 'data:Fallback';
    }

    if ((tournamentPath ?? '').isNotEmpty) {
      setState(() {});
      await _loadData();  // 🔄 데이터를 먼저 불러오고

      // ✅ 이후에 matchSchedule 기반으로 위젯에 업데이트
      if (matchSchedule != null) {
        final upcoming = getUpcomingMatches(matchSchedule!, 2);
        if (upcoming.isNotEmpty) {
          await updateHomeWidget(
            upcoming[0],
            upcoming.length > 1 ? upcoming[1] : null,
          );
        }
      }
    }
  }

  List<Map<String, String>> getUpcomingMatches(
      Map<String, List<Map<String, String>>> matchSchedule, int maxCount) {
    final now = DateTime.now();
    final today = DateFormat('M월 d일').format(now);

    // keys 정렬
    final keys = matchSchedule.keys.toList();
    keys.sort((a, b) {
      final ma = RegExp(r'(\d+)월 (\d+)일').firstMatch(a)!;
      final mb = RegExp(r'(\d+)월 (\d+)일').firstMatch(b)!;
      final da = DateTime(2025, int.parse(ma[1]!), int.parse(ma[2]!));
      final db = DateTime(2025, int.parse(mb[1]!), int.parse(mb[2]!));
      return da.compareTo(db);
    });

    List<Map<String, String>> result = [];

    for (final key in keys) {
      final games = matchSchedule[key]!;
      for (final game in games) {
        if (result.length < maxCount) result.add(game);
      }
      if (result.length >= maxCount) break;
    }

    return result;
  }

  /* ──────────────────  위젯에 띄울 경기  ────────────────── */
  Future<void> updateHomeWidget(Map<String, String> game1, [Map<String, String>? game2]) async {
    await HomeWidget.saveWidgetData('match1_team1', game1['team1']);
    await HomeWidget.saveWidgetData('match1_team2', game1['team2']);
    await HomeWidget.saveWidgetData('match1_time', game1['matchTime']);

    if (game2 != null) {
      await HomeWidget.saveWidgetData('match2_team1', game2['team1']);
      await HomeWidget.saveWidgetData('match2_team2', game2['team2']);
      await HomeWidget.saveWidgetData('match2_time', game2['matchTime']);
    }

    await HomeWidget.updateWidget(
      name: 'LckWidget',
      iOSName: 'LckWidget', // 생성한 위젯 클래스명
    );

    print('🧩 위젯 저장 시작: ${game1['team1']} vs ${game1['team2']} @ ${game1['matchTime']}');
  }

  /* ──────────────────  데이터 로드 & 파싱  ────────────────── */
  Future<void> _loadData() async {
    final raw = await ManageFetching().fetchMatchSchedule(tournamentPath!);
    setState(() {
      matchSchedule = ManageFetching().textPostProcessing(raw);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (matchSchedule != null && _scroll.isAttached) {
        _scroll.jumpTo(index: _indexForToday(matchSchedule!.keys.toList()));
      }
    });
  }

  int _indexForToday(List<String> keys) {
    final base = DateTime(2025, DateTime.now().month, DateTime.now().day);
    for (int d = 0; d < 30; d++) {
      final key = DateFormat('M월 d일').format(base.add(Duration(days: d)));
      final idx = keys.indexOf(key);
      if (idx != -1) return idx;
    }
    return keys.length - 1;
  }

  String getWeekday(String key) {
    final m = RegExp(r'(\d+)월\s*(\d+)일').firstMatch(key);
    if (m != null) {
      return DateFormat('EEE', 'ko').format(
          DateTime(2025, int.parse(m[1]!), int.parse(m[2]!)));
    }
    return "";
  }

  Future<bool> assetExists(String p) async {
    try { await rootBundle.load(p); return true; } catch (_) { return false; }
  }

  /* ─────────────────────────  UI  ────────────────────────── */
  @override
  Widget build(BuildContext context) {
    if (tournamentTitle == null || matchSchedule == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    sortedKey = matchSchedule!.keys.toList();

    return Scaffold(
      appBar: CupertinoNavigationBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        middle: Text(tournamentTitle!,
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
      ),
      body: ScrollablePositionedList.builder(
        itemScrollController: _scroll,
        itemCount: matchSchedule!.length,
        itemBuilder: (c, i) {
          final dayKey = sortedKey[i];
          final games = matchSchedule![dayKey]!;
          const double logo = 60;

          return Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    "$dayKey (${getWeekday(dayKey)})",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                  ),
                ),
                ...games.map((g) => Card(
                      color: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      child: Column(children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(tabInKr[g["Tab"]] ?? g["Tab"]!),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _teamCol(context, g["team1"]!, logo),
                            _score(g["team1score"]!, g["team2score"]!),
                            _teamCol(context, g["team2"]!, logo),
                          ],
                        ),
                        const SizedBox(height: 25),
                        Column(children: [
                          Divider(
                              color: Theme.of(context).brightness == Brightness.light
                                  ? const Color(0xFFF1F1F1)
                                  : const Color(0xFF252525),
                              height: 1),
                          Text(g["matchTime"]!,
                              style: const TextStyle(fontSize: 14)),
                        ]),
                      ]),
                    )),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _teamCol(BuildContext ctx, String team, double size) {
    return Column(children: [
      FutureBuilder<bool>(
        future: Theme.of(ctx).brightness == Brightness.light
            ? assetExists('assets/lightmode/$team.png')
            : assetExists('assets/darkmode/$team.png'),
        builder: (c, s) {
          if (s.connectionState != ConnectionState.done) {
            return const SizedBox(width: 60, height: 60);
          }
          if (s.data == true) {
            final folder = Theme.of(ctx).brightness == Brightness.light
                ? 'lightmode' : 'darkmode';
            return Image.asset('assets/$folder/$team.png',
                width: size, height: size);
          }
          return Card(
              color: Theme.of(ctx).colorScheme.surface,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              child: SizedBox(width: size, height: size));
        },
      ),
      const SizedBox(height: 2),
      Text(teamInKr[team] ?? team),
    ]);
  }

  Widget _score(String a, String b) => Row(children: [
        Text(a, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
        const Text("  vs  "),
        Text(b, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
      ]);
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

/*
  TODO 일정
  1. 대회 이동 가능하게 변경하기
  TODO 알림
  1. lck 유튜브 채널 라이브 시작시 최초 1회만 알림 보내기
  2. 라이브 중이라면 유튜브로 이동해서 lck 채널 여는 버튼
  TODO 다이나믹 아일랜드 실시간현황

  TODO 위젯
 */