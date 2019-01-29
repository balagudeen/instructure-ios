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

let coreTestBundle = Bundle(for: DownloadFileTest.self)

class DownloadFileTest: CoreTestCase {
    var fileURL: URL!

    override func setUp() {
        super.setUp()
        do {
            guard let resourcePath = coreTestBundle.resourcePath else {
                return
            }
            let url = URL(fileURLWithPath: resourcePath).appendingPathComponent("TestImage.png")
            fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("TestImage.png")
            if FileManager.default.fileExists(atPath: fileURL.path) == false {
                try FileManager.default.copyItem(at: url, to: fileURL)
                XCTAssertTrue(FileManager.default.fileExists(atPath: fileURL.path))
            }
        } catch {
            XCTFail()
        }
    }

    func testDownloadFile() {
        let downloadURL = URL(string: "https://canvas.instructure.com/files/2/download")!
        File.make([
            "id": "2",
            "url": downloadURL,
        ])
        api.mockDownload(downloadURL, value: fileURL, response: nil, error: nil)

        let downloadOp = DownloadFile(fileID: "2", userID: "1", env: environment)
        addOperationAndWait(downloadOp)

        guard let file: File = databaseClient.fetch().first else {
            XCTFail()
            return
        }
        databaseClient.refresh()
        XCTAssertTrue(FileManager.default.fileExists(atPath: file.localFileURL!.path))
    }
}
