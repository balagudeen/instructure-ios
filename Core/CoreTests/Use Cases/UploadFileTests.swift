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

class UploadFileTests: CoreTestCase {
    func testItStartsFileUpload() {
        queueFileUpload()
        mockAPI()

        let uploadFile = UploadFile(env: environment, file: testFile)
        addOperationAndWait(uploadFile)

        let fileUploads: [FileUpload] = databaseClient.fetch()
        XCTAssertEqual(fileUploads.count, 1)
        XCTAssertEqual(fileUploads.first?.backgroundSessionID, api.identifier)
        XCTAssertEqual(fileUploads.first?.taskID, 1)
        XCTAssertEqual(backgroundAPI.uploadMocks.count, 1)
        XCTAssertEqual(backgroundAPI.uploadMocks.values.first?.resumeCount, 1)
    }

    private func queueFileUpload() {
        let info = FileInfo(url: testFile, size: 120)
        let context = ContextModel(.course, id: "1")
        Assignment.make(["id": "1"])
        let queue = QueueFileUpload(fileInfo: info, context: context, assignmentID: "1", userID: "2", env: environment)
        addOperationAndWait(queue)
    }

    private func mockAPI() {
        let body = PostFileUploadTargetRequest.Body(
            name: testFile.lastPathComponent,
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
