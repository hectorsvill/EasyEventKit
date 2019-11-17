import EventKit

open class EventKitController {
    private (set) var eventStore: EKEventStore
        
    /// returns event calendars array
    open var eventCalendars: [EKCalendar] {
        eventStore.calendars(for: .event)
    }
    
    /// returns reminder calendars array
    open var reminderCalendars: [EKCalendar] {
        eventStore.calendars(for: .reminder)
    }
    
    open init(eventStore: EKEventStore = EKEventStore()) {
        self.eventStore = eventStore
    }
    
    /// returns true if calendar with title exitst
    open func calendarExist(with title: String) -> Bool {
        let titles = eventCalendars.map { $0.title }
        return titles.contains(title)
    }

    /// check permission and request access to calendar from user
    open func permission() {
        switch EKEventStore.authorizationStatus(for: .event) {
        case .denied:
            eventStore.requestAccess(to: .event) { _, _ in}
        case .notDetermined:
            eventStore.requestAccess(to: .event) { _, _ in}
        default:
            NSLog("EventKitController.permission() went to default")
            eventStore.requestAccess(to: .event) { _, _ in}
        }
    }

    /// create new event calendar inside icloud default, if exist do nothing
    open func createNewCalendar(with title: String, using sourceType: EKSourceType = EKSourceType.local) {
        guard !calendarExist(with: title) else { return}

        let newCalendar = EKCalendar(for: .event, eventStore: eventStore)
        newCalendar.title = title
        if !eventStore.sources.isEmpty {
            newCalendar.source = eventStore.sources.filter { $0.sourceType.rawValue == sourceType.rawValue}.first!
        }
        do {
            try eventStore.saveCalendar(newCalendar, commit: true)
        } catch {
            NSLog("Error creating calendar: \(error)")
        }
    }
    
    /// insert  EKEvent
    open func insertEvent(with event: EKEvent, completion: @escaping (Error?) -> ()) {
        do {
            try eventStore.save(event, span: .thisEvent)
            completion(nil)
        } catch {
            completion(error)
        }
    }
    
    /// fetch a calendar with a title
    open func fetchCalendar(with title: String) -> EKCalendar? {
        return eventCalendars.filter { $0.title == title }.first
    }
    
    /// fetch events from all calendars stored in a given range, specify specific calendars in array
    open func fetchEvents(start: Date, end: Date, calendars: [EKCalendar]? = nil) -> [EKEvent]? {
        // Create the predicate from the event store's instance method.
        let eventsPredicate = eventStore.predicateForEvents(withStart: start, end: end, calendars: calendars)
        return eventStore.events(matching: eventsPredicate)
    }
}
