import SwiftUI
import WidgetKit

@main
struct PatroWidgetBundle: WidgetBundle {
    var body: some Widget {
        TodayWidget()
        DeskWidget()
        AgendaWidget()
        WeekWidget()
        MonthWidget()
    }
}
