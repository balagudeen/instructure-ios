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
import UserNotifications

class NotificationManagerTests: CoreTestCase {
    func testNotify() {
        notificationManager.notify(title: "Title", body: "Body", route: Route.courses)
        let request = notificationCenter.requests.last
        XCTAssertNotNil(request)
        XCTAssertEqual(request?.content.title, "Title")
        XCTAssertEqual(request?.content.body, "Body")
        XCTAssert(request?.trigger is UNTimeIntervalNotificationTrigger)
        XCTAssertEqual((request?.trigger as? UNTimeIntervalNotificationTrigger)?.timeInterval, 1)
        XCTAssertEqual((request?.trigger as? UNTimeIntervalNotificationTrigger)?.repeats, false)
        XCTAssertEqual(request?.content.userInfo[NotificationManager.RouteURLKey] as? String, "/courses")
    }

    func testNotifyLogsError() {
        notificationCenter.error = NSError.instructureError("error")
        notificationManager.notify(title: "Title", body: "Body", route: nil)
        let log = logger.errors.last
        XCTAssertNotNil(log)
        XCTAssertEqual(log, "error")
    }
}
