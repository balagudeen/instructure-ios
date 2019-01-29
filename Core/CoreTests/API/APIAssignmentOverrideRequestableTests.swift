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

class APIAssignmentOverrideRequestableTests: XCTestCase {
    func testCreateAssignmentOverrideRequest() {
        let override = CreateAssignmentOverrideRequest.Body.AssignmentOverride(title: "a")
        let expectedBody = CreateAssignmentOverrideRequest.Body(assignment_override: override)
        let request = CreateAssignmentOverrideRequest(courseID: "1", assignmentID: "2", body: expectedBody)

        XCTAssertEqual(request.path, "courses/1/assignments/2/overrides")
        XCTAssertEqual(request.method, .post)
        XCTAssertEqual(request.body, expectedBody)
    }
}
