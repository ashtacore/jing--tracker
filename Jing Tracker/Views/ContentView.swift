import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            LogView()
                .tabItem {
                    Label("Log", systemImage: "plus.circle.fill")
                }
            
            StatisticsView()
                .tabItem {
                    Label("Statistics", systemImage: "chart.bar.fill")
                }
            
            CalendarViewWithInfo()
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}
#Preview {
    ContentView()
        .modelContainer(for: WellnessEvent.self, inMemory: true)
}
