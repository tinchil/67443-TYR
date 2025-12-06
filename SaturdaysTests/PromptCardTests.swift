import Testing
import SwiftUI
import ViewInspector
@testable import Saturdays

extension PromptCard: Inspectable {}

struct PromptCardTests {

    @Test
    func testDisplaysPrompt() async throws {
        let view = PromptCard(prompt: "Hello world")

        let text = try view.inspect().find(text: "Hello world").string()
        #expect(text == "Hello world")
    }

    @Test
    func testEditButtonExists() async throws {
        let view = PromptCard(prompt: "Sample")

        let button = try view.inspect().find(button: "")
        #expect(button != nil)
    }
}
