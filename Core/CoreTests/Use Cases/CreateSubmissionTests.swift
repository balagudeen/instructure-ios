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

class CreateSubmissionTests: CoreTestCase {
    func testItCreatesAssignmentSubmission() {
        //  given
        let submissionType = SubmissionType.online_url
        let context = ContextModel(.course, id: "1")
        let url = URL(string: "http://www.instructure.com")!
        let body = CreateSubmissionRequest.Body.Submission(text_comment: nil, submission_type: submissionType, body: nil, url: url, file_ids: nil, media_comment_id: nil, media_comment_type: nil)
        let request =  CreateSubmissionRequest(context: context, assignmentID: "1", body: .init(submission: body))
        let template: APISubmission = APISubmission.make([
            "assignment_id": "2",
            "grade": "A-",
            "score": 97,
            "late": true,
            "excused": true,
            "missing": true,
            "workflow_state": SubmissionWorkflowState.submitted.rawValue,
            "late_policy_status": LatePolicyStatus.late.rawValue,
            "points_deducted": 10,
            ])

        api.mock(request, value: template, response: nil, error: nil)

        //  when
        let createSubmission = CreateSubmission(context: context, assignmentID: "1", userID: "1", submissionType: submissionType, url: url, env: environment)
        addOperationAndWait(createSubmission)

        //  then
        XCTAssertEqual(createSubmission.errors.count, 0)
        let subs: [Submission] = databaseClient.fetch()
        let submission = subs.first
        XCTAssertNotNil(submission)
        XCTAssertEqual(submission?.grade, "A-")
        XCTAssertEqual(submission?.late, true)
        XCTAssertEqual(submission?.excused, true)
        XCTAssertEqual(submission?.missing, true)
        XCTAssertEqual(submission?.workflowState, .submitted)
        XCTAssertEqual(submission?.latePolicyStatus, .late)
        XCTAssertEqual(submission?.pointsDeducted, 10)
    }
}
