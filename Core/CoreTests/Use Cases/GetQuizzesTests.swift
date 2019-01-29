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

class GetQuizzesTest: CoreTestCase {

    let courseID = "1"
    lazy var request: GetQuizzesRequest = { [weak self] in
        return GetQuizzesRequest(courseID: self!.courseID)
    }()

    func testItCreatesQuizzes() {
        let groupQuiz = APIQuiz.make()
        let getQuizzes = GetQuizzes(courseID: courseID)
        try! getQuizzes.write(response: [groupQuiz], urlResponse: nil, to: databaseClient)

        let quizzes: [Quiz] = databaseClient.fetch(predicate: nil, sortDescriptors: nil)
        XCTAssertEqual(quizzes.count, 1)
        XCTAssertEqual(quizzes.first?.title, "What kind of pokemon are you?")
        XCTAssertEqual(quizzes.first?.quizType, .survey)
        XCTAssertEqual(quizzes.first?.htmlURL.path, "/courses/1/quizzes/123")
    }

    func testItDeletesQuizzesThatNoLongerExist() {
        let quiz = Quiz.make(["courseID": courseID])
        let request = GetQuizzesRequest(courseID: courseID)
        api.mock(request, value: [], response: nil, error: nil)
        let getQuizzes = GetQuizzes(courseID: courseID)
        let expectation = XCTestExpectation(description: "quizzes written")
        getQuizzes.makeRequest(environment: environment) { response, urlResponse, _ in
            try! getQuizzes.write(response: response, urlResponse: urlResponse, to: self.databaseClient)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)

        databaseClient.refresh()
        let quizzes: [Quiz] = databaseClient.fetch()
        XCTAssertFalse(quizzes.contains(quiz))
    }
}
