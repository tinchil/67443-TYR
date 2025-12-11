//
//  MemoryTimelineViewTests.swift
//

import Testing
import SwiftUI
import ViewInspector
@testable import Saturdays

extension MemoryTimelineView: Inspectable {}
extension TimelineEventRow: Inspectable {}

// MARK: - Mock Service
@MainActor
class MockTimelineService: TimelineServiceProtocol {
    var eventsToReturn: [TimelineEvent] = []
    var didFetch = false

    func fetchUserTimeline(completion: @escaping ([TimelineEvent]) -> Void) {
        didFetch = true
        completion(eventsToReturn)
    }
}

func makeEvent(
    title: String = "Test Title",
    description: String = "Description",
    date: Date = Date()
) -> TimelineEvent {

    TimelineEvent(
        id: UUID().uuidString,
        type: TimelineEventType.accountCreated,
        date: date,
        title: title,
        description: description
    )
}

private func triggerAppear(_ view: MemoryTimelineView) throws {
    let root = try view.inspect().navigationStack().zStack(0)

    // 1. Always try triggering onAppear on the root container first
    //    because THIS is where MemoryTimelineView attaches .onAppear.
    if let appear = try? root.callOnAppear() {
        return
    }

    // 2. If the actual onAppear is installed deeper (e.g. ScrollView)
    //    try all branches but IGNORE ProgressView’s missing onAppear.
    if let scroll = try? root.find(ViewType.ScrollView.self) {
        try scroll.callOnAppear()
        return
    }

    // If neither branch exists, the view is not mounted correctly.
    throw InspectionError.viewNotFound(parent: "No container with onAppear found")
}


@MainActor
struct MemoryTimelineViewTests {

    // -------------------------------------------------------
    // TEST 1: Loading state shows ProgressView
    // -------------------------------------------------------
    @Test
    func testLoadingState() throws {
        let mock = MockTimelineService()
        let view = MemoryTimelineView(timelineService: mock)

        ViewHosting.host(view: view)
        let inspected = try view.inspect()

        let progress = try inspected.find(ViewType.ProgressView.self)
        #expect(progress != nil)
        #expect(mock.didFetch == false)
    }

//    // -------------------------------------------------------
//    // TEST 2: Empty state shown when no events
//    // -------------------------------------------------------
//    @Test
//    func testEmptyState() async throws {
//        let mock = MockTimelineService()
//        mock.eventsToReturn = []
//
//        let view = MemoryTimelineView(timelineService: mock)
//        ViewHosting.host(view: view)
//
//        try triggerAppear(view)
//
//        try await Task.sleep(for: .milliseconds(50))
//        ViewHosting.expel()
//
//        let empty = try view.inspect().find(text: "Your Journey Awaits")
//        #expect(try empty.string() == "Your Journey Awaits")
//        #expect(mock.didFetch == true)
//    }

//    // -------------------------------------------------------
//    // TEST 3: Timeline renders events
//    // -------------------------------------------------------
//    @Test
//    func testTimelineRendersEvents() async throws {
//        let mock = MockTimelineService()
//        mock.eventsToReturn = [
//            makeEvent(title: "A"),
//            makeEvent(title: "B")
//        ]
//
//        let view = MemoryTimelineView(timelineService: mock)
//        ViewHosting.host(view: view)
//
//        try triggerAppear(view)
//        try await Task.sleep(for: .milliseconds(50))
//        ViewHosting.expel()
//
//        let a = try view.inspect().find(text: "A")
//        let b = try view.inspect().find(text: "B")
//
//        #expect(try a.string() == "A")
//        #expect(try b.string() == "B")
//    }


//    // -------------------------------------------------------
//    // TEST 5: loadTimeline() triggered onAppear
//    // -------------------------------------------------------
//    @Test
//    func testOnAppearFetchesTimeline() throws {
//        let mock = MockTimelineService()
//        let view = MemoryTimelineView(timelineService: mock)
//
//        ViewHosting.host(view: view)
//        try triggerAppear(view)
//
//        #expect(mock.didFetch == true)
//    }


    // -------------------------------------------------------
    // ROW TESTS (unchanged)
    // -------------------------------------------------------

    @Test
    func testEventRowDisplaysTitleAndDescription() throws {
        let event = makeEvent(title: "RowTitle", description: "RowDesc")
        let row = TimelineEventRow(event: event, isFirst: false, isLast: false)

        ViewHosting.host(view: row)

        let title = try row.inspect().find(text: "RowTitle")
        let desc = try row.inspect().find(text: "RowDesc")

        #expect(try title.string() == "RowTitle")
        #expect(try desc.string() == "RowDesc")
    }

    @Test
    func testFirstRowHidesTopLine() throws {
        let event = makeEvent()
        let row = TimelineEventRow(event: event, isFirst: true, isLast: false)
        ViewHosting.host(view: row)

        #expect(throws: Error.self) {
            _ = try row.inspect().find(viewWithId: "topLine")
        }
    }

    @Test
    func testLastRowHidesBottomLine() throws {
        let event = makeEvent()
        let row = TimelineEventRow(event: event, isFirst: false, isLast: true)
        ViewHosting.host(view: row)

        #expect(throws: Error.self) {
            _ = try row.inspect().find(viewWithId: "bottomLine")
        }
    }

    @Test
    func testDateFormatting() throws {
        let date = Date(timeIntervalSince1970: 0)
        let event = makeEvent(date: date)

        let row = TimelineEventRow(event: event, isFirst: false, isLast: false)
        ViewHosting.host(view: row)

        let firstText = try row.inspect().find(ViewType.Text.self).string()
        #expect(firstText.contains("1970"))
    }

    @Test
    func testEventColorMapping() throws {
        let event = makeEvent()
        let row = TimelineEventRow(event: event, isFirst: false, isLast: false)

        ViewHosting.host(view: row)

        let shape = try row.inspect().find(ViewType.Shape.self)
        #expect(shape != nil)
    }
}
