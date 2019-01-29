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

import XCTest
@testable import Core

class APIAssignmentRequestableTests: XCTestCase {
    func testGetAssignmentRequest() {
        let request = GetAssignmentRequest(courseID: "1", assignmentID: "2", include: [])
        XCTAssertEqual(request.path, "courses/1/assignments/2")
        XCTAssertEqual(request.queryItems, [])
    }

    func testGetAssignmentRequestWithSubmission() {
        let request = GetAssignmentRequest(courseID: "1", assignmentID: "2", include: [.submission])
        XCTAssertEqual(request.path, "courses/1/assignments/2")
        XCTAssertEqual(request.queryItems, [
            URLQueryItem(name: "include[]", value: "submission"),
        ])
    }

    func testGetAssignmentsRequest() {
        let request = GetAssignmentsRequest(courseID: "1")
        XCTAssertEqual(request.path, "courses/1/assignments?per_page=100")
        XCTAssertEqual(request.queryItems, [])
    }

    func testCreateAssignmentRequest() {
        let assignment = APIAssignmentParameters(
            name: "A",
            description: "d",
            points_possible: 10,
            due_at: Date(),
            submission_types: [SubmissionType.online_upload],
            allowed_extensions: ["pdf"],
            published: true,
            grading_type: .percent,
            lock_at: nil,
            unlock_at: nil
        )
        let expectedBody = PostAssignmentRequest.Body(assignment: assignment)
        let request = PostAssignmentRequest(courseID: "1", body: expectedBody)

        XCTAssertEqual(request.path, "courses/1/assignments")
        XCTAssertEqual(request.method, .post)
        XCTAssertEqual(request.body, expectedBody)
    }
}
