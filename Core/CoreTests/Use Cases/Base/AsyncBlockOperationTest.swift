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

class TestError: Error {
    let label: String
    init (label: String) {
        self.label = label
    }
}

typealias ErrorHandler = (Error?) -> Void

class AsyncBlockOperationTest: CoreTestCase {
    let dispatchQueue = DispatchQueue(label: "Test Queue")

    func testItRunsTheOperation() {
        var ran = false
        let asyncOp = AsyncBlockOperation { [weak self] (completionBlock: @escaping ErrorHandler) in
            self?.dispatchQueue.async {
                ran = true
                completionBlock(nil)
            }
        }
        addOperationAndWait(asyncOp)
        XCTAssertTrue(ran)
    }

    func testItRunsAndAttachesError() {
        var ran = false
        let asyncOp = AsyncBlockOperation { [weak self] (completionBlock: @escaping ErrorHandler) in
            self?.dispatchQueue.async {
                ran = true
                completionBlock(TestError(label: "Test"))
            }
        }
        addOperationAndWait(asyncOp)
        XCTAssertTrue(ran)
        guard let attachedError = asyncOp.errors.first as? TestError else {
            XCTFail()
            return
        }
        XCTAssertEqual(attachedError.label, "Test")
    }
}
