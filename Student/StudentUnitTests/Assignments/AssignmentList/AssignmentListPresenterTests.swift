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
@testable import Student
import Core
import TestsFoundation

class AssignmentListPresenterTests: PersistenceTestCase {

    var resultingError: NSError?
    var resultingAssignments: [Assignment]?
    var resultingBaseURL: URL?
    var resultingSubtitle: String?
    var resultingBackgroundColor: UIColor?
    var presenter: AssignmentListPresenter!
    var expectation = XCTestExpectation(description: "expectation")
    var colorExpectation = XCTestExpectation(description: "expectation")

    var titleSubtitleView = TitleSubtitleView.create()
    var navigationItem: UINavigationItem = UINavigationItem(title: "")

    var title: String?
    var color: UIColor?

    override func setUp() {
        super.setUp()
        expectation = XCTestExpectation(description: "expectation")
        presenter = AssignmentListPresenter(env: env, view: self, courseID: "1")
    }

    func testLoadAssignments() {
        //  given
        let expected = Assignment.make()

        //  when
        presenter.loadDataForView()

        //  then
        XCTAssert(resultingAssignments?.first! === expected)
    }

    func testUseCaseFetchesData() {
        //  given
        Assignment.make()

        //   when
        presenter.loadDataForView()

        //  then
        XCTAssertEqual(resultingAssignments?.first?.name, "Assignment One")
    }

    func testLoadCourseColorsAndTitle() {
        //  given
        let expected = Course.make()
        let expectedColor = Color.make()

        //  when
        presenter.loadDataForView()

        //  then
        XCTAssertEqual(resultingBackgroundColor, expectedColor.color)
        XCTAssertEqual(resultingSubtitle, expected.name)
    }

    func testSelect() {
        let a = Assignment.make()
        let router = env.router as? TestRouter
        XCTAssertNoThrow(presenter.select(a, from: UIViewController()))
        XCTAssertEqual(router?.calls.last?.0, URLComponents.parse(a.htmlURL))
    }
}

extension AssignmentListPresenterTests: AssignmentListViewProtocol {
    func update(list: [Assignment]) {
        resultingAssignments = list
    }

    var navigationController: UINavigationController? {
        return UINavigationController(nibName: nil, bundle: nil)
    }

    func showError(_ error: Error) {
        resultingError = error as NSError
    }

    func updateNavBar(subtitle: String?, color: UIColor?) {
        resultingBackgroundColor = color
        resultingSubtitle = subtitle
        colorExpectation.fulfill()
    }
}
