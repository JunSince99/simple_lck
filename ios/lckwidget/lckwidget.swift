import WidgetKit
import SwiftUI

// 1. 데이터 모델
struct MatchEntry: TimelineEntry {
    let date: Date
    let team1: String
    let team2: String
    let matchTime: String
}

// 2. 데이터 제공자
struct LckWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> MatchEntry {
        MatchEntry(date: Date(), team1: "T1", team2: "GEN", matchTime: "18:00")
    }

    func getSnapshot(in context: Context, completion: @escaping (MatchEntry) -> Void) {
        completion(loadData())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MatchEntry>) -> Void) {
        let entry = loadData()
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }

    private func loadData() -> MatchEntry {
        let defaults = UserDefaults(suiteName: "group.com.JunSince99.simplelck")
        let team1 = defaults?.string(forKey: "match1_team1") ?? "팀1"
        let team2 = defaults?.string(forKey: "match1_team2") ?? "팀2"
        let time  = defaults?.string(forKey: "match1_time")  ?? "--:--"
        return MatchEntry(date: Date(), team1: team1, team2: team2, matchTime: time)
    }
}

// 3. 위젯 UI
struct LckWidgetEntryView: View {
    var entry: MatchEntry

    var body: some View {
        VStack(alignment: .leading) {
            Text("다음 경기")
                .font(.headline)
            Text("\(entry.team1) vs \(entry.team2)")
                .font(.title2)
                .bold()
            Text("시작 시간: \(entry.matchTime)")
                .font(.caption)
        }
        .padding()
    }
}

// 4. 위젯 등록
@main
struct LckWidget: Widget {
    let kind: String = "LckWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LckWidgetProvider()) { entry in
            LckWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("오늘의 LCK")
        .description("다음 경기 정보를 보여줍니다.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
