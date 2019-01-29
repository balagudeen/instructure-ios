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
import Core
@testable import Student
import TestsFoundation

class CourseNavigationPresenterTests: PersistenceTestCase {

    var resultingTabs: [CourseNavigationViewModel]?
    var presenter: CourseNavigationPresenter!
    var resultingError: NSError?
    var navigationController: UINavigationController?

    var expectation = XCTestExpectation(description: "expectation")

    override func setUp() {
        super.setUp()
        resultingTabs = nil
        expectation = XCTestExpectation(description: "expectation")
        presenter = CourseNavigationPresenter(courseID: "1", view: self, env: env, useCase: MockUseCase {})
    }

    @discardableResult
    func tab() -> Tab {
        return Tab.make(["contextRaw": "course_1"])
    }

    func testLoadTabs() {
        //  given
        let expected = tab()

        //  when
        presenter.loadTabs()
        wait(for: [expectation], timeout: 0.1)
        //  then
        XCTAssertEqual(resultingTabs?.first?.id, expected.id)
    }

    func testTabsAreOrderedByPosition() {
        Tab.make(["position": 2, "id": "b", "contextRaw": "course_1"])
        Tab.make(["position": 3, "id": "c", "contextRaw": "course_1"])
        Tab.make(["position": 1, "id": "a", "contextRaw": "course_1"])

        presenter.loadTabs()

        XCTAssertEqual(resultingTabs?.count, 3)
        XCTAssertEqual(resultingTabs?.first?.id, "a")
        XCTAssertEqual(resultingTabs?.last?.id, "c")
    }

    func testUseCaseFetchesData() {
        //  given
        tab()

        //   when
        presenter.loadTabs()

        //  then
        XCTAssertEqual(resultingTabs?.first?.label, Tab.make().label)
    }
}

extension CourseNavigationPresenterTests: CourseNavigationViewProtocol {
    func updateNavBar(title: String, backgroundColor: UIColor) {
    }

    func showTabs(_ tabs: [CourseNavigationViewModel]) {
        resultingTabs = tabs
        expectation.fulfill()
    }

    func showError(_ error: Error) {
        resultingError = error as NSError
    }
}
