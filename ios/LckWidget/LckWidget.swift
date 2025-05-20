import WidgetKit
import SwiftUI

struct MatchEntry: TimelineEntry {
    let date: Date
    let match1Team1: String
    let match1Team2: String
    let match1Time: String
    let match2Team1: String?
    let match2Team2: String?
    let match2Time: String?
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> MatchEntry {
        MatchEntry(date: Date(), match1Team1: "T1", match1Team2: "DK", match1Time: "18:00", match2Team1: nil, match2Team2: nil, match2Time: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (MatchEntry) -> ()) {
        completion(getEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = getEntry()
        let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(60 * 15)))
        completion(timeline)
    }

    func getEntry() -> MatchEntry {
        let userDefaults = UserDefaults(suiteName: "group.com.JunSince99.simplelck")
        let m1t1 = userDefaults?.string(forKey: "match1_team1") ?? "-"
        let m1t2 = userDefaults?.string(forKey: "match1_team2") ?? "-"
        let m1time = userDefaults?.string(forKey: "match1_time") ?? "-"

        let m2t1 = userDefaults?.string(forKey: "match2_team1")
        let m2t2 = userDefaults?.string(forKey: "match2_team2")
        let m2time = userDefaults?.string(forKey: "match2_time")

        return MatchEntry(
            date: Date(),
            match1Team1: m1t1,
            match1Team2: m1t2,
            match1Time: m1time,
            match2Team1: m2t1,
            match2Team2: m2t2,
            match2Time: m2time
        )
    }
}

struct LckWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading) {
            Text("\(entry.match1Team1) vs \(entry.match1Team2)")
            Text("⏰ \(entry.match1Time)")
            if let t1 = entry.match2Team1, let t2 = entry.match2Team2, let time = entry.match2Time {
                Divider()
                Text("\(t1) vs \(t2)")
                Text("⏰ \(time)")
            }
        }.padding()
    }
}

@main
struct LckWidget: Widget {
    let kind: String = "LckWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            LckWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Simple LCK 위젯")
        .description("다가오는 경기들을 보여줍니다.")
        .supportedFamilies([.systemSmall, .systemMedium]) // 필요에 따라 추가
    }
}
