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

class URLExtensionsTests: XCTestCase {

    let path = URL(fileURLWithPath: "\(NSTemporaryDirectory())submissions/")

    func setup() {
        deleteTempDir()
    }

    func deleteTempDir() {
        XCTAssertNoThrow( try FileManager.default.removeItem(at: path) )
    }

    func testTemporarySubmissionDirectoryPath() {
        //  when
        let result = try? URL.temporarySubmissionDirectoryPath()

        //  then
        XCTAssertEqual(result, path)
    }

    func testTemporarySubmissionDirectoryPathWithExistingFolder() {

        //  given
        _ = try? URL.temporarySubmissionDirectoryPath()
        let files = try? FileManager.default.contentsOfDirectory(at: URL(fileURLWithPath: NSTemporaryDirectory()), includingPropertiesForKeys: nil)
        XCTAssertTrue((files?.contains(path))!)

        //  when
        let result = try? URL.temporarySubmissionDirectoryPath()

        //  then
        XCTAssertEqual(result, path)
    }

    func testLookupFileSize() {
        let url = Bundle(for: URLExtensionsTests.self).url(forResource: "Info", withExtension: "plist")
        XCTAssertGreaterThan(url!.lookupFileSize(), 500)
        XCTAssertEqual(URL(string: "bogus")?.lookupFileSize(), 0)
        XCTAssertEqual(URL(fileURLWithPath: "bogus").lookupFileSize(), 0)
    }

    func testAppendingQueryItems() {
        let url = URL(string: "/")?.appendingQueryItems(URLQueryItem(name: "a", value: "b"), URLQueryItem(name: "c", value: nil))
        XCTAssertEqual(url?.absoluteString, "/?a=b&c")
    }
}
