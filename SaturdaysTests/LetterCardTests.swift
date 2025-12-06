import Testing
import SwiftUI
import ViewInspector
@testable import Saturdays

extension LetterCard: Inspectable {}

struct LetterCardTests {

    @Test
    func testButtonActionIsCalled() async throws {
        var tapped = false
        let view = LetterCard {
            tapped = true
        }

        try view.inspect().find(button: "").tap()
        #expect(tapped == true)
    }
}
