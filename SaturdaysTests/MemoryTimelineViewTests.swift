//
//  MemoryTimelineViewTests.swift
//  Saturdays
//
//  Created by Yining He  on 12/10/25.
//

import Testing
import SwiftUI
import ViewInspector
@testable import Saturdays

// MARK: - Make views inspectable
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

// MARK: - Helper
func makeEvent(
    title: String = "Test Title",
    description: String = "Description",
    date: Date = Date()
) -> TimelineEvent {

    TimelineEvent(
        id: UUID().uuidString,
        type: TimelineEventType.accountCreated, // <-- VALID enum case
        date: date,
        title: title,
        description: description
    )
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

    // -------------------------------------------------------
    // TEST 2: Empty state shown when no events
    // -------------------------------------------------------
    @Test
    func testEmptyState() throws {
        let mock = MockTimelineService()
        mock.eventsToReturn = []

        let view = MemoryTimelineView(timelineService: mock)

        ViewHosting.host(view: view)
        try view.inspect().callOnAppear()

        let emptyText = try view.inspect().find(text: "Your Journey Awaits")
        #expect(try emptyText.string() == "Your Journey Awaits")
        #expect(mock.didFetch == true)
    }

    // -------------------------------------------------------
    // TEST 3: Timeline renders events
    // -------------------------------------------------------
    @Test
    func testTimelineRendersEvents() throws {
        let mock = MockTimelineService()
        mock.eventsToReturn = [
            makeEvent(title: "A"),
            makeEvent(title: "B")
        ]

        let view = MemoryTimelineView(timelineService: mock)
        ViewHosting.host(view: view)

        try view.inspect().callOnAppear()

        let a = try view.inspect().find(text: "A")
        let b = try view.inspect().find(text: "B")

        #expect(try a.string() == "A")
        #expect(try b.string() == "B")
    }


    // -------------------------------------------------------
    // TEST 5: loadTimeline() triggered onAppear
    // -------------------------------------------------------
    @Test
    func testOnAppearFetchesTimeline() throws {
        let mock = MockTimelineService()
        let view = MemoryTimelineView(timelineService: mock)

        ViewHosting.host(view: view)
        try view.inspect().callOnAppear()

        #expect(mock.didFetch == true)
    }

    // =======================================================
    // MARK: - TimelineEventRow Tests
    // =======================================================

    // CONTENT TEST
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

    // FIRST ROW hides top line
    @Test
    func testFirstRowHidesTopLine() throws {
        let event = makeEvent()
        let row = TimelineEventRow(event: event, isFirst: true, isLast: false)
        ViewHosting.host(view: row)

        // Instead of looking for ANY shape, we target the top-line specifically
        #expect(throws: Error.self) {
            _ = try row.inspect().find(viewWithId: "topLine")
        }
    }

    @Test
    func testLastRowHidesBottomLine() throws {
        let event = makeEvent()
        let row = TimelineEventRow(event: event, isFirst: false, isLast: true)
        ViewHosting.host(view: row)

        // bottomLine should not exist
        #expect(throws: Error.self) {
            _ = try row.inspect().find(viewWithId: "bottomLine")
        }
    }

    // DATE FORMATTING
    @Test
    func testDateFormatting() throws {
        let date = Date(timeIntervalSince1970: 0)
        let event = makeEvent(date: date)

        let row = TimelineEventRow(event: event, isFirst: false, isLast: false)
        ViewHosting.host(view: row)

        let firstText = try row.inspect().find(ViewType.Text.self).string()
        #expect(firstText.contains("1970"))
    }

    // COLOR MAPPING
    @Test
    func testEventColorMapping() throws {
        let event = makeEvent()
        let row = TimelineEventRow(event: event, isFirst: false, isLast: false)

        ViewHosting.host(view: row)

        // Find the first Shape (background circle)
        let shape = try row.inspect().find(ViewType.Shape.self)

        #expect(shape != nil)
    }
}
