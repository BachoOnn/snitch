import Testing
import UIKit
@testable import Snitch

@MainActor
@Suite struct InspectorHostingControllerTests {
    @Test func stylesSegmentedControlsOnlyInsideTheInspector() {
        _ = InspectorHostingController(rootView: InspectorView(onClose: {}))
        let inside = UISegmentedControl.appearance(whenContainedInInstancesOf: [InspectorHostingController.self])
        #expect(inside.selectedSegmentTintColor != nil)
        #expect(UISegmentedControl.appearance().selectedSegmentTintColor == nil)
        #expect(UISegmentedControl.appearance().backgroundColor == nil)
    }
}
