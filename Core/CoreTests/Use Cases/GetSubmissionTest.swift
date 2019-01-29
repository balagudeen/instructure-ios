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

class GetSubmissionTest: CoreTestCase {
    func testItCreatesSubmission() {
        let context = ContextModel(.course, id: "1")
        let request = GetSubmissionRequest(context: context, assignmentID: "2", userID: "3")
        let apiSubmission = APISubmission.make([
            "assignment_id": "2",
            "user_id": "3",
        ])
        api.mock(request, value: apiSubmission, response: nil, error: nil)

        let getSubmission = GetSubmission(context: context, assignmentID: "2", userID: "3", env: environment)
        addOperationAndWait(getSubmission)

        XCTAssertEqual(getSubmission.errors.count, 0)
        let submissions: [Submission] = databaseClient.fetch()
        XCTAssertEqual(submissions.count, 1)
        let submission = submissions.first!
        XCTAssertEqual(submission.assignmentID, "2")
        XCTAssertEqual(submission.userID, "3")
    }

    func testItCreatesSubmissionHistory() {
        let context = ContextModel(.course, id: "1")
        let request = GetSubmissionRequest(context: context, assignmentID: "2", userID: "3")
        let apiSubmission = APISubmission.make([
            "attempt": 2,
            "assignment_id": "2",
            "user_id": "3",
            "submission_history": [
                APISubmission.fixture([ "attempt": 2, "assignment_id": "2", "user_id": "3" ]),
                APISubmission.fixture([ "attempt": 1, "assignment_id": "2", "user_id": "3" ]),
            ],
        ])
        api.mock(request, value: apiSubmission, response: nil, error: nil)

        let getSubmission = GetSubmission(context: context, assignmentID: "2", userID: "3", env: environment)
        addOperationAndWait(getSubmission)

        XCTAssertEqual(getSubmission.errors.count, 0)
        let submissions: [Submission] = databaseClient.fetch()
        XCTAssertEqual(submissions.count, 2)
        let submission = submissions.first!
        XCTAssertEqual(submission.assignmentID, "2")
        XCTAssertEqual(submission.userID, "3")
    }

    func testNoHistoryDoesntDelete() {
        let context = ContextModel(.course, id: "1")
        let request = GetSubmissionRequest(context: context, assignmentID: "2", userID: "3")
        Submission.make([ "attempt": 2, "assignmentID": "2", "userID": "3", "late": false ])
        Submission.make([ "attempt": 1, "assignmentID": "2", "userID": "3" ])
        let apiSubmission = APISubmission.make([
            "attempt": 2,
            "assignment_id": "2",
            "user_id": "3",
            "late": true,
        ])
        api.mock(request, value: apiSubmission, response: nil, error: nil)

        let getSubmission = GetSubmission(context: context, assignmentID: "2", userID: "3", env: environment)
        addOperationAndWait(getSubmission)

        XCTAssertEqual(getSubmission.errors.count, 0)
        let submissions: [Submission] = databaseClient.fetch()
        XCTAssertEqual(submissions.count, 2)
        let submission = submissions.first(where: { $0.attempt == 2 })!
        XCTAssertEqual(submission.assignmentID, "2")
        XCTAssertEqual(submission.userID, "3")
        XCTAssertEqual(submission.late, true)
    }
}
