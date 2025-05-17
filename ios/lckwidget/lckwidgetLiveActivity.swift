//
//  lckwidgetLiveActivity.swift
//  lckwidget
//
//  Created by Jun on 5/17/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct lckwidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct lckwidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: lckwidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension lckwidgetAttributes {
    fileprivate static var preview: lckwidgetAttributes {
        lckwidgetAttributes(name: "World")
    }
}

extension lckwidgetAttributes.ContentState {
    fileprivate static var smiley: lckwidgetAttributes.ContentState {
        lckwidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: lckwidgetAttributes.ContentState {
         lckwidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: lckwidgetAttributes.preview) {
   lckwidgetLiveActivity()
} contentStates: {
    lckwidgetAttributes.ContentState.smiley
    lckwidgetAttributes.ContentState.starEyes
}
