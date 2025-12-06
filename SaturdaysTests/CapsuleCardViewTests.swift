import Testing
import SwiftUI
import ViewInspector
@testable import Saturdays

extension CapsuleCardView: Inspectable {}

struct CapsuleCardViewTests {

    @Test
    func testShowsUntitledWhenEmpty() async throws {
        var model = CapsuleModel(type: .memory)
        model.name = ""

        let view = CapsuleCardView(capsule: model)
        let text = try view.inspect().find(text: "Untitled Capsule")
        #expect(text != nil)
    }

    @Test
    func testShowsNameWhenProvided() async throws {
        var model = CapsuleModel(type: .memory)
        model.name = "Trip"

        let view = CapsuleCardView(capsule: model)
        let text = try view.inspect().find(text: "Trip")
        #expect(text != nil)
    }
}
