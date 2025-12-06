import Testing
@testable import Saturdays

struct HomeViewModelTests {

    @Test
    func testStartCapsuleCreatesNewCapsuleVM() async throws {
        let vm = HomeViewModel()

        let oldVM = vm.currentCapsuleVM

        vm.startCapsule(type: .video)

        #expect(vm.currentCapsuleVM.capsule.type == .video)
        #expect(vm.currentCapsuleVM !== oldVM)
    }

    @Test
    func testDefaultPrompt() async throws {
        let vm = HomeViewModel()

        #expect(vm.promptOfTheDay == "What’s something you’re grateful for today?")
    }

    @Test
    func testCapsulesInitiallyEmpty() async throws {
        let vm = HomeViewModel()

        #expect(vm.capsules.isEmpty)
    }
}
