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

class GetCourseTest: CoreTestCase {
    func testItCreatesCourse() {
        let request = GetCourseRequest(courseID: "1")
        let response = APICourse.make()
        api.mock(request, value: response)

        let getCourse = GetCourse(courseID: "1", env: environment)
        addOperationAndWait(getCourse)

        let courses: [Course] = databaseClient.fetch(predicate: nil, sortDescriptors: nil)
        XCTAssertEqual(courses.count, 1)
        XCTAssertEqual(courses.first?.id, response.id)
        XCTAssertEqual(courses.first?.name, response.name)
    }

    func testItCreatesCourseWithEnrollments() {
        let request = GetCourseRequest(courseID: "1")
        let response = APICourse.make()
        api.mock(request, value: response)

        let getCourse = GetCourse(courseID: "1", env: environment)
        addOperationAndWait(getCourse)

        let courses: [Course] = databaseClient.fetch(predicate: nil, sortDescriptors: nil)
        XCTAssertEqual(courses.first?.enrollments?.first?.canvasContextID, "course_1")
        XCTAssertEqual(courses.first?.enrollments?.first?.state, .active)
    }

    func testItCreatesCourseWithEnrollmentsAndDeletesExistingEnrollments() {
        let enrollment = Enrollment.make(["stateRaw": "invited"])
        let a = Course.make(["enrollments": Set([enrollment])])
        XCTAssertGreaterThan(a.enrollments!.count, 0)
        XCTAssertEqual(a.enrollments?.first?.state, .invited)

        let request = GetCourseRequest(courseID: "1")
        let response = APICourse.make()
        api.mock(request, value: response)

        let getCourse = GetCourse(courseID: "1", env: environment)
        addOperationAndWait(getCourse)

        databaseClient.refresh()
        let courses: [Course] = databaseClient.fetch(predicate: nil, sortDescriptors: nil)
        XCTAssertEqual(courses.first?.enrollments?.first?.canvasContextID, "course_1")
        XCTAssertEqual(courses.first?.enrollments?.first?.state, .active)
    }

    func testItCreatesCourseWithEnrollmentsWithMissingRoleType() {
        let enrollment = Enrollment.make(["roleRaw": "ObserverEnrollment"])
        let a = Course.make(["enrollments": Set([enrollment])])
        XCTAssertGreaterThan(a.enrollments!.count, 0)
        XCTAssertNil(a.enrollments?.first?.role)

        let request = GetCourseRequest(courseID: "1")

        let response = APICourse.make(["enrollments": [APIEnrollment.fixture(["role": "foo"])]])
        api.mock(request, value: response)

        let getCourse = GetCourse(courseID: "1", env: environment)
        addOperationAndWait(getCourse)

        databaseClient.refresh()
        let courses: [Course] = databaseClient.fetch(predicate: nil, sortDescriptors: nil)
        XCTAssertEqual(courses.first?.enrollments?.first?.canvasContextID, "course_1")
        XCTAssertNil(courses.first?.enrollments?.first?.role)
    }

    func testItDeletesEnrollmentsIfNotReceivedInResponse() {
        let enrollment = Enrollment.make(["stateRaw": "invited"])
        let a = Course.make(["enrollments": Set([enrollment])])
        XCTAssertGreaterThan(a.enrollments!.count, 0)
        XCTAssertEqual(a.enrollments?.first?.state, .invited)

        let request = GetCourseRequest(courseID: "1")
        let response = APICourse.make(["enrollments": nil])
        api.mock(request, value: response)

        let getCourse = GetCourse(courseID: "1", env: environment)
        addOperationAndWait(getCourse)

        databaseClient.refresh()
        let courses: [Course] = databaseClient.fetch(predicate: nil, sortDescriptors: nil)
        if let enrollments = courses.first?.enrollments {
            XCTAssertEqual(enrollments.count, 0)
        } else {
            XCTAssertNil(courses.first?.enrollments)
        }
    }

    func testItUpdatesCourse() {
        let course = Course.make(["id": "1", "name": "Old Name"])
        let request = GetCourseRequest(courseID: "1")
        let response = APICourse.make(["id": "1", "name": "New Name"])
        api.mock(request, value: response)

        let getCourse = GetCourse(courseID: "1", env: environment)
        addOperationAndWait(getCourse)
        databaseClient.refresh()
        XCTAssertEqual(course.name, "New Name")
    }
}
