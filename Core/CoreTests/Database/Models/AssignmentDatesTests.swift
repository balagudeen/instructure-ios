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

class AssignmentDatesTests: XCTestCase {

    var df = ISO8601DateFormatter()
    var a: Assignment!
    override func setUp() {
        df = ISO8601DateFormatter()
        a = Assignment.make(["lockAt": nil, "unlockAt": nil])

        let now    = df.date(from: "2018-10-01T06:00:00Z")!
        Clock.mockNow(now)
    }

    func testAssignmentOpenForSubmissionsWithLockDate() {
        //  given
        a.lockAt = df.date(from: "2018-10-01T06:00:00Z")

        //  when
        var result = a.isOpenForSubmissions()

        //  then
        XCTAssertFalse(result)

        a.lockAt = df.date(from: "2018-10-01T05:59:59Z")

        //  when
        result = a.isOpenForSubmissions()

        //  then
        XCTAssertFalse(result)
    }

    func testAssignmentOpenForSubmissionsWithUnlockDate() {
        //  given
        a.unlockAt = df.date(from: "2018-10-01T06:00:00Z")

        //  when
        var result = a.isOpenForSubmissions()

        //  then
        XCTAssertTrue(result)

        a.unlockAt = df.date(from: "2018-10-01T06:00:01Z")

        //  when
        result = a.isOpenForSubmissions()

        //  then
        XCTAssertFalse(result)
    }

    func testAssignmentOpenForSubmissionsWithAvailabilityDates() {
        //  given
        a.unlockAt = df.date(from: "2018-10-01T05:00:00Z")
        a.lockAt   = df.date(from: "2018-10-01T06:01:00Z")

        //  when
        var result = a.isOpenForSubmissions()

        //  then
        XCTAssertTrue(result)

        Clock.mockNow(df.date(from: "2018-10-01T06:02:00Z")!)

        //  when
        result = a.isOpenForSubmissions()

        //  then
        XCTAssertFalse(result)
    }

    func testAssignmentOpenForSubmissionsWithGoodAvailabilityDatesLockedForUser() {
        //  given
        a.lockedForUser = true
        a.unlockAt = df.date(from: "2018-10-01T05:00:00Z")
        a.lockAt   = df.date(from: "2018-10-01T06:01:00Z")

        //  when
        let result = a.isOpenForSubmissions()

        //  then
        XCTAssertFalse(result)
    }

    func testAssignmentOpenForSubmissionsWithGoodAvailabilityDatesNotLockedForUser() {
        //  given
        a.lockedForUser = false
        a.unlockAt = df.date(from: "2018-10-01T05:00:00Z")
        a.lockAt   = df.date(from: "2018-10-01T06:01:00Z")

        //  when
        let result = a.isOpenForSubmissions()

        //  then
        XCTAssertTrue(result)
    }
}
