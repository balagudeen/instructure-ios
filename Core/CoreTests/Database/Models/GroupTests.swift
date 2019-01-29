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

class GroupTests: CoreTestCase {
    func testDetailsScopeOnlyIncludesGroup() {
        let group = Group.make(["id": "1"])
        Group.make(["id": "2"])
        let list = environment.subscribe(Group.self, .details("1"))
        list.performFetch()
        let objects = list.fetchedObjects

        XCTAssertEqual(objects?.count, 1)
        XCTAssertEqual(objects, [group])
    }

    func testDashboardScopeDoesNotIncludeConcluded() {
        let notConcluded = Group.make(["id": "1", "concluded": false])
        Group.make(["id": "2", "concluded": true])
        let list = environment.subscribe(Group.self, .dashboard)
        list.performFetch()
        let objects = list.fetchedObjects

        XCTAssertEqual(objects?.count, 1)
        XCTAssertEqual(objects, [notConcluded])
    }

    func testDashboardScopeOrdersByName() {
        let a = Group.make(["id": "1", "name": "a"])
        let b = Group.make(["id": "2", "name": "b"])
        let c = Group.make(["id": "3", "name": "c"])
        let list = environment.subscribe(Group.self, .dashboard)
        list.performFetch()
        let objects = list.fetchedObjects

        XCTAssertEqual(objects?.count, 3)
        XCTAssertEqual(objects, [a, b, c])
    }

    func testColorWithNoLinkOrCourse() {
        let a = Group.make()
        _ = Color.make()

        XCTAssertEqual(a.color, .named(.ash))
    }

    func testColor() {
        let a = Group.make()
        _ = Color.make([#keyPath(Color.canvasContextID): a.canvasContextID])

        XCTAssertEqual(a.color, .red)
    }

    func testColorWithCourseID() {
        let a = Group.make(["courseID": "1"])
        _ = Color.make()

        XCTAssertEqual(a.color, .red)
    }
}
