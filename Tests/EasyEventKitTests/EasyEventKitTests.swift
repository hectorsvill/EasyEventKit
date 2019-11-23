
import XCTest
import EventKit
@testable import EasyEventKit

final class EasyEventKitTests: XCTestCase {
    let eventKitController = EventKitController()
    let calendarTitle = "Test this Calendar 0000"
    
    // start date
    var start: Date {
        return Date(timeIntervalSinceNow: -10800)
    }

       // end date
    var end: Date {
        return Date()
    }
    
    func testCreateCalendar() {
        eventKitController.permission()
        eventKitController.permission()
        eventKitController.createNewCalendar(with: calendarTitle, using: .local)
        let calendarTitles = eventKitController.eventCalendars.map { $0.title }
        XCTAssertTrue(calendarTitles.contains(calendarTitle))
   }

   func testFetchCalendar() {
       let calendar = eventKitController.fetchCalendar(with: calendarTitle)
       XCTAssertNotNil(calendar)
   }

   func testInsertEvent() {
       guard let calendar = eventKitController.fetchCalendar(with: calendarTitle) else {
           XCTFail()
           return
       }

       let store = eventKitController.eventStore
       let event = EKEvent(eventStore: store)

       event.calendar = calendar
       event.title = "Test title with a diff "
       event.notes = "notes about the event here!"
       event.url = nil
       event.startDate = start
       event.endDate = end

       XCTAssertNoThrow(try store.save(event, span: .thisEvent))
   }

   func testFetchEvents() {
       guard let events = eventKitController.fetchEvents(start: start, end: end) else {
           XCTFail()
           return
       }
       XCTAssertTrue(events.count > 0)
    }


    static var allTests = [
        ["testCreateCalendar", testCreateCalendar],
//        ["testFetchCalendar", testFetchCalendar],
//        ["testInsertEvent", testInsertEvent],
//        ["testFetchEvents", testFetchEvents]
    ]
}
