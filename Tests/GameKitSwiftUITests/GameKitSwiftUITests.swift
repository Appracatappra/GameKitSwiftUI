import XCTest
@testable import GameKitSwiftUI

final class SwiftUIKitTests: XCTestCase {
    @MainActor func testGameKitSwiftUI() throws {
        let control:GameKitSwiftUI? = GameKitSwiftUI()
        
        XCTAssert(control != nil)
    }
}

