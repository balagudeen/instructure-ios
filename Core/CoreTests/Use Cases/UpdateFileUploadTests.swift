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
import TestsFoundation

class UpdateFileUploadTests: CoreTestCase {
    lazy var fileInfo: FileInfo = {
        return FileInfo(url: testFile, size: 2048)
    }()
    var assignment: Assignment!
    let context = ContextModel(.course, id: "1")
    let task = MockAPITask(taskIdentifier: 32)
    let backgroundSessionID = "foo"

    override func setUp() {
        super.setUp()
        assignment = Assignment.make(["courseID": context.id])

        let prepare = QueueFileUpload(fileInfo: fileInfo, context: context, assignmentID: assignment.id, userID: "1", env: environment)
        addOperationAndWait(prepare)
    }

    func start() {
        let start = StartFileUpload(backgroundSessionID: backgroundSessionID, task: task, database: database, url: fileInfo.url)
        addOperationAndWait(start)
    }
}

class StartFileUploadTests: UpdateFileUploadTests {
    func testItSetsTaskIdentifiersAndResumes() {
        start()

        let fileUpload: FileUpload = databaseClient.fetch().first!
        XCTAssertEqual(fileUpload.backgroundSessionID, "foo")
        XCTAssertEqual(fileUpload.taskID, 32)
        XCTAssertEqual(task.resumeCount, 1)
    }
}

class UpdateFileUploadProgressTests: UpdateFileUploadTests {
    func testItUpdatesBytesSent() {
        start()
        let progress = UpdateFileUploadProgress(backgroundSessionID: backgroundSessionID, task: task, bytesSent: 12, expectedToSend: 2048, database: database)
        addOperationAndWait(progress)
        let fileUpload: FileUpload = databaseClient.fetch().first!
        XCTAssertEqual(fileUpload.bytesSent, 12)
        XCTAssertEqual(fileUpload.size, 2048)
    }
}

class UpdateFileUploadDataTests: UpdateFileUploadTests {
    var validData: Data {
        let encoder = JSONEncoder()
        let file = ["id": 42]
        return try! encoder.encode(file)
    }

    var invalidData: Data {
        let encoder = JSONEncoder()
        let response = ["error": "Something is wrong"]
        return try! encoder.encode(response)
    }

    func testItUpdatesFileID() {
        start()

        let update = UpdateFileUploadData(backgroundSessionID: backgroundSessionID, task: task, data: validData, database: database)
        addOperationAndWait(update)

        let fileUpload: FileUpload = databaseClient.fetch().first!
        XCTAssertEqual(fileUpload.fileID, "42")
        XCTAssertNil(fileUpload.error)
    }

    func testError() {
        start()

        let update = UpdateFileUploadData(backgroundSessionID: backgroundSessionID, task: task, data: invalidData, database: database)
        addOperationAndWait(update)

        let fileUpload: FileUpload = databaseClient.fetch().first!
        XCTAssertNil(fileUpload.fileID)
        XCTAssertNotNil(fileUpload.error)
    }
}

class CompleteFileUploadTests: UpdateFileUploadTests {
    func testCompletedWithoutError() {
        start()

        let complete = CompleteFileUpload(backgroundSessionID: backgroundSessionID, task: task, error: nil, database: database)
        addOperationAndWait(complete)

        let fileUpload: FileUpload = databaseClient.fetch().first!
        XCTAssertTrue(fileUpload.completed)
        XCTAssertNil(fileUpload.error)
    }

    func testCompletedWithError() {
        start()
        let error = NSError.instructureError("upload failed")

        let complete = CompleteFileUpload(backgroundSessionID: backgroundSessionID, task: task, error: error, database: database)
        addOperationAndWait(complete)

        let fileUpload: FileUpload = databaseClient.fetch().first!
        XCTAssertFalse(fileUpload.completed)
        XCTAssertEqual(fileUpload.error, "upload failed")
    }
}
