import Testing
import SwiftUI
import ViewInspector
@testable import Saturdays

extension MemoryCard: Inspectable {}

struct MemoryCardTests {

    @Test
    func testButtonActionIsCalled() async throws {
        var tapped = false
        let view = MemoryCard {
            tapped = true
        }

        try view.inspect().find(button: "").tap()
        #expect(tapped == true)
    }
}
