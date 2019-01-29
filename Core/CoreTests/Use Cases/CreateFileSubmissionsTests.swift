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

class CreateFileSubmissionsTests: CoreTestCase {
    func testItStartsNextUpload() {
        let next = createNextFileUpload()
        mockAPI(fileUpload: next)

        let operation = CreateFileSubmissions(env: environment, userID: "1")
        addOperationAndWait(operation)

        databaseClient.refresh()
        XCTAssertEqual(next.backgroundSessionID, api.identifier)
        XCTAssertEqual(next.taskID, 1)
    }

    func testItSubmitsReadySubmissions() {
        let next = createNextFileUpload()
        next.completed = true
        try! databaseClient.save()

        let operation = CreateFileSubmissions(env: environment, userID: "1")
        addOperationAndWait(operation)
    }

    private func createNextFileUpload() -> FileUpload {
        let fileSubmission = FileSubmission.make()
        let completed = FileUpload.make(["completed": true])
        fileSubmission.addToFileUploads(completed)
        let next = FileUpload.make(["completed": false, "error": nil, "url": testFile])
        fileSubmission.addToFileUploads(next)
        try! databaseClient.save()
        return next
    }

    private func mockAPI(fileUpload: FileUpload) {
        let body = PostFileUploadTargetRequest.Body(
            name: fileUpload.url.lastPathComponent,
            on_duplicate: .rename,
            parent_folder_id: nil
        )
        let request = PostFileUploadTargetRequest(
            target: .submission(courseID: "1", assignmentID: "1"),
            body: body
        )
        let response = PostFileUploadTargetRequest.Response.init(upload_url: URL(string: "s3://somewhere.com/bucket/1")!, upload_params: [:])
        api.mock(request, value: response)
    }
}
