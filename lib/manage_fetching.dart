import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class ManageFetching {
  final String baseUrl;
  
  ManageFetching({this.baseUrl = 'lol.fandom.com'});

  Future<dynamic> fetchMatchSchedule(String tournamentName) async {
    final Map<String, String> queryParameters = {
      'action': 'cargoquery',
      'format': 'json',
      'limit': 'max',
      'tables': 'MatchSchedule=MS',
      'fields': 'MS.OverviewPage, MS.Team1, MS.Team2, MS.Team1Score, MS.Team2Score, MS.DateTime_UTC',
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

  Map<String, List<List<String>>>? textPostProcessing(dynamic datas) {
    Map<String, List<List<String>>> matchSchedule = {}; //"2월 11일" : [["team1", "team2", "team1score", "team2score", "time"]],
    print(datas["cargoquery"][37]["title"]);
    for (Map<String, dynamic> data in datas["cargoquery"]){
      String utcString = data["title"]!["DateTime UTC"] ?? "none";
      String matchDay;
      String matchTime;
      if (utcString != "none") {
        DateTime utcTime = DateTime.parse("${utcString}Z");
        DateTime localTime = utcTime.toLocal();
        matchDay = DateFormat('M월 d일').format(localTime);
        matchTime = DateFormat('HH:mm').format(localTime);
        String team1 = data["title"]!["Team1"] ?? "none";
        String team2 = data["title"]!["Team2"] ?? "none";
        String team1score = data["title"]!["Team1Score"] ?? "none";
        String team2score = data["title"]!["Team2Score"] ?? "none";

        if(matchSchedule.containsKey(matchDay)) {
          matchSchedule[matchDay]!.add([team1, team2, team1score, team2score, matchTime]);
        } else {
          matchSchedule[matchDay] = [[team1, team2, team1score, team2score, matchTime]];
        }
      } else {
        return null;
      }
    }
    return matchSchedule;
  }
}