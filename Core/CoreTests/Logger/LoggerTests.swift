//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
import XCTest
@testable import Core

class LoggerTests: CoreTestCase {
    var theLogger: Logger!

    override func setUp() {
        super.setUp()

        theLogger = Logger()
        theLogger.database = database
    }
    func testLog() {
        let now = Date()
        Clock.mockNow(now)
        theLogger.log("log message")
        theLogger.queue.waitUntilAllOperationsAreFinished()
        let event: LogEvent = databaseClient.fetch().first!
        XCTAssertEqual(event.message, "log message")
        XCTAssertEqual(event.timestamp, now)
        XCTAssertEqual(event.type, .log)
    }

    func testError() {
        let now = Date()
        Clock.mockNow(now)
        theLogger.error("error message")
        theLogger.queue.waitUntilAllOperationsAreFinished()
        let event: LogEvent = databaseClient.fetch().first!
        XCTAssertEqual(event.message, "error message")
        XCTAssertEqual(event.timestamp, now)
        XCTAssertEqual(event.type, .error)
    }

    func testClearAll() {
        LogEvent.make()
        LogEvent.make()
        let before: [LogEvent] = databaseClient.fetch()
        XCTAssertEqual(before.count, 2)

        theLogger.clearAll()

        theLogger.queue.waitUntilAllOperationsAreFinished()
        databaseClient.refresh()
        let after: [LogEvent] = databaseClient.fetch()
        XCTAssertEqual(after.count, 0)
    }
}
