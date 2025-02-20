import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class ManageFetching {
  final String baseUrl;
  
  ManageFetching({this.baseUrl = 'lol.fandom.com'});

  Future<dynamic> fetchMatchSchedule(String tournamentName) async { // lck 일정 정보 요청
    final Map<String, String> queryParameters = {
      'action': 'cargoquery',
      'format': 'json',
      'limit': 'max',
      'tables': 'MatchSchedule=MS',
      'fields': 'MS.OverviewPage, MS.Team1, MS.Team2, MS.Team1Score, MS.Team2Score, MS.DateTime_UTC, MS.Tab',
      'where': 'MS._pageName="$tournamentName"',
      'order_by': 'MS.N_Page, MS.N_MatchInPage',
    };

    final Uri uri = Uri.https(baseUrl, '/api.php', queryParameters);

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }

  Map<String, List<Map<String, String>>>? textPostProcessing(dynamic datas) { // lck 일정 데이터 후처리
    Map<String, List<Map<String, String>>> matchSchedule = {}; //"2월 11일" : [["team1", "team2", "team1score", "team2score", "time"]],
    print(datas["cargoquery"]);
    for (Map<String, dynamic> data in datas["cargoquery"]){
      String utcString = data["title"]!["DateTime UTC"] ?? "none";
      String matchDay;
      String matchTime;
      if (utcString != "none") {
        DateTime utcTime = DateTime.parse("${utcString}Z");
        DateTime localTime = utcTime.toLocal();
        matchDay = DateFormat('M월 d일').format(localTime);
        matchTime = DateFormat('HH:mm').format(localTime);
        String team1 = data["title"]!["Team1"];
        String team2 = data["title"]!["Team2"];

        String team1score = data["title"]!["Team1Score"] ?? "0";
        String team2score = data["title"]!["Team2Score"] ?? "0";

        if(matchSchedule.containsKey(matchDay)) {
          matchSchedule[matchDay]!.add(
            {
              "team1" : team1,
              "team2" : team2,
              "team1score" : team1score,
              "team2score" : team2score,
              "matchTime" : matchTime,
              "Tab" : data["title"]!["Tab"] ?? ""
            });
        } else {
          matchSchedule[matchDay] = [
            {
              "team1" : team1,
              "team2" : team2,
              "team1score" : team1score,
              "team2score" : team2score,
              "matchTime" : matchTime,
              "Tab" : data["title"]!["Tab"] ?? ""
            }];
        }
      } else {
        return null;
      }
    }
    return matchSchedule;
  }

  Future<List<String>> fetchTournamentRosters(String tournamentName) async { //현재 대회 로스터 (팀명 String List)
    final Map<String, String> queryParameters = {
      'action': 'cargoquery',
      'format': 'json',
      'limit': 'max',
      'tables': 'TournamentRosters=TR',
      'fields': 'TR.Team',
      'where': 'MS._pageName="$tournamentName"',
    };

    final Uri uri = Uri.https(baseUrl, '/api.php', queryParameters);

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        List<String> tournamentRoster = [];
        final datas = json.decode(response.body);
        for(Map<String, dynamic> data in datas) {
          tournamentRoster.add(data['Team']);
        }
        return tournamentRoster;
      } else {
        throw Exception('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }
}