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

class CourseTests: CoreTestCase {
    func testDetailsScopeOnlyIncludesCourse() {
        let course = Course.make(["id": "1"])
        let other = Course.make(["id": "2"])
        let list = environment.subscribe(Course.self, .details("1"))
        list.performFetch()
        let objects = list.fetchedObjects
        XCTAssertEqual(objects?.count, 1)
        XCTAssertEqual(objects?.contains(course), true)
        XCTAssertEqual(objects?.contains(other), false)
    }

    func testAllScope() {
        let one = Course.make(["id": "1"])
        let two = Course.make(["id": "2"])
        let list = environment.subscribe(Course.self, .all)
        list.performFetch()
        let objects = list.fetchedObjects

        XCTAssertEqual(objects?.count, 2)
        XCTAssertEqual(objects?.contains(one), true)
        XCTAssertEqual(objects?.contains(two), true)
    }

    func testFavoritesScopeOnlyIncludesFavorites() {
        let favorite = Course.make(["id": "1", "isFavorite": true])
        let nonFavorite = Course.make(["id": "1", "isFavorite": false])
        let list = environment.subscribe(Course.self, .favorites)
        list.performFetch()
        let objects = list.fetchedObjects

        XCTAssertEqual(objects?.count, 1)
        XCTAssertEqual(objects?.first, favorite)
        XCTAssertEqual(objects?.contains(nonFavorite), false)
    }

    func testColor() {
        let a = Course.make()
        _ = Color.make()

        XCTAssertEqual(a.color, UIColor.red)
    }

    func testDefaultView() {
        let expected = CourseDefaultView.assignments
        let a = Course.make()
        a.defaultView = expected

        XCTAssertEqual(a.defaultView, expected)
    }

    func testEnrollmentRelationship() {
        let a = Course.make()
        let enrollment = Enrollment.make()
        a.enrollments = [enrollment]

        let pred = NSPredicate(format: "%K == %@", #keyPath(Course.id), a.id)
        let list: [Course] = environment.database.mainClient.fetch(predicate: pred, sortDescriptors: nil)
        let result = list.first
        let resultEnrollment = result?.enrollments?.first

        XCTAssertNotNil(result)
        XCTAssertNotNil(result?.enrollments)
        XCTAssertNotNil(resultEnrollment)
        XCTAssertEqual(resultEnrollment?.canvasContextID, "course_1")
    }
}
