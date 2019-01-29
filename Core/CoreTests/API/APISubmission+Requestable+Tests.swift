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

class APISubmissionRequestableTests: CoreTestCase {
    func testGetSubmissionRequest() {
        XCTAssertEqual(GetSubmissionRequest(context: ContextModel(.course, id: "1"), assignmentID: "2", userID: "3").path, "courses/1/assignments/2/submissions/3")
        XCTAssertEqual(GetSubmissionRequest(context: ContextModel(.course, id: "1"), assignmentID: "2", userID: "3").query, [ APIQueryItem.array("include", [
            "submission_history",
        ]), ])
    }

    func testCreateSubmissionRequest() {
        let submission = CreateSubmissionRequest.Body.Submission(
            text_comment: "a comment",
            submission_type: .online_text_entry,
            body: "yo",
            url: nil,
            file_ids: nil,
            media_comment_id: nil,
            media_comment_type: nil
        )
        let body = CreateSubmissionRequest.Body(submission: submission)
        let request = CreateSubmissionRequest(context: ContextModel(.course, id: "1"), assignmentID: "2", body: body)

        XCTAssertEqual(request.path, "courses/1/assignments/2/submissions")
        XCTAssertEqual(request.method, .post)
        XCTAssertEqual(request.body, body)
        XCTAssertEqual(request.body?.submission.text_comment, "a comment")
    }

    func testGradeSubmissionRequest() {
        let submission = PutSubmissionGradeRequest.Body.Submission(posted_grade: "10")
        let body = PutSubmissionGradeRequest.Body(submission: submission)
        let request = PutSubmissionGradeRequest(courseID: "1", assignmentID: "2", userID: "3", body: body)

        XCTAssertEqual(request.path, "courses/1/assignments/2/submissions/3")
        XCTAssertEqual(request.method, .put)
        XCTAssertEqual(request.body, body)
    }
}
