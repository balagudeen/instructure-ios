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

class FileUploadTests: CoreTestCase {

    func testSaveFileUpload() {
        let url = URL(fileURLWithPath: NSTemporaryDirectory())
        let assignmentID = "1"
        let size: Int64 = 1024
        let info = FileInfo(url: url, size: size)
        let c = ContextModel(.course, id: "1")
        Assignment.make(["id": assignmentID])
        let queueToUpload = QueueFileUpload(fileInfo: info, context: c, assignmentID: assignmentID, userID: "1", env: environment)

        addOperationAndWait(queueToUpload)

        let files: [FileUpload] = environment.database.mainClient.fetch()
        guard let file = files.first else { XCTFail(); return }
        XCTAssertEqual(file.url, url)
        XCTAssertEqual(file.submission?.assignment.id, "1")
        XCTAssertEqual(file.context as? ContextModel, c)
        XCTAssertEqual(file.size, size)
    }
}
