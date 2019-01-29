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

class GetFileTests: CoreTestCase {
    func testItCreatesFile() {
        let dateString = Date().isoString()
        let request = GetFileRequest(context: ContextModel(.course, id: "1"), fileID: "2")
        let apiFile = APIFile.make([
            "id": "2",
            "uuid": "test-uuid-1234",
            "folder_id": "1",
            "display_name": "GetFileTest",
            "filename": "GetFileTest.pdf",
            "content-type": "application/pdf",
            "url": "https://canvas.instructure.com/files/2/download",
            "size": 2048,
            "created_at": dateString,
            "updated_at": dateString,
            "modified_at": dateString,
            "mime_class": "PDF",
        ])
        api.mock(request, value: apiFile, response: nil, error: nil)

        let getFile = GetFile(courseID: "1", fileID: "2", env: environment)
        addOperationAndWait(getFile)

        XCTAssertEqual(getFile.errors.count, 0)
        let files: [File] = databaseClient.fetch(predicate: nil, sortDescriptors: nil)
        XCTAssertEqual(files.count, 1)
        let file = files.first!
        XCTAssertEqual(file.id, "2")
        XCTAssertEqual(file.uuid, "test-uuid-1234")
        XCTAssertEqual(file.folderID, "1")
        XCTAssertEqual(file.displayName, "GetFileTest")
        XCTAssertEqual(file.filename, "GetFileTest.pdf")
        XCTAssertEqual(file.contentType, "application/pdf")
        XCTAssertEqual(file.url.absoluteString, "https://canvas.instructure.com/files/2/download")
        XCTAssertEqual(file.size, 2048)
        XCTAssertEqual(file.createdAt.isoString(), dateString)
        XCTAssertEqual(file.updatedAt!.isoString(), dateString)
        XCTAssertFalse(file.locked)
        XCTAssertFalse(file.hidden)
        XCTAssertFalse(file.hiddenForUser)
        XCTAssertEqual(file.mimeClass, "PDF")
        XCTAssertFalse(file.lockedForUser)
    }
}
