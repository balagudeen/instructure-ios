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

class GroupNavigationPresenterTests: PersistenceTestCase {

    var resultingTabs: [GroupNavigationViewModel]?
    var resultingColor: UIColor?
    var resultingTitle = ""
    var presenter: GroupNavigationPresenter!
    var resultingError: NSError?
    var expectation = XCTestExpectation(description: "expectation")
    var navigationController: UINavigationController?

    override func setUp() {
        super.setUp()
        expectation = XCTestExpectation(description: "expectation")
        presenter = GroupNavigationPresenter(groupID: Group.make().id, view: self, env: env, useCase: MockUseCase {})
    }

    func testLoadTabs() {
        //  given
        Group.make()
        let expected = Tab.make()

        //  when
        presenter.loadTabs()

        //  then
        XCTAssertEqual(resultingTabs?.first?.id, expected.id)
    }

    func testTabsAreOrderedByPosition() {
        Tab.make(["position": 2, "id": "b"])
        Tab.make(["position": 3, "id": "c"])
        Tab.make(["position": 1, "id": "a"])

        presenter.loadTabs()

        XCTAssertEqual(resultingTabs?.count, 3)
        XCTAssertEqual(resultingTabs?.first?.id, "a")
        XCTAssertEqual(resultingTabs?.last?.id, "c")
    }

    func testUseCaseFetchesData() {
        //  given
        var color: Color!
        var group: Group!
        let useCase = MockUseCase {
            group = Group.make()
            color = Color.make(["canvasContextID": group.canvasContextID, "color": UIColor.init(hexString: "#ff0")])
            Tab.make()
            self.expectation.fulfill()
        }

        presenter = GroupNavigationPresenter(groupID: Group.make().id, view: self, env: env, useCase: useCase)

       //   when
        presenter.loadTabs()
        wait(for: [expectation], timeout: 1)

        //  then
        XCTAssertEqual(resultingTabs?.first?.label, Tab.make().label)
        XCTAssertEqual(resultingTabs?.first?.icon.renderingMode, .alwaysTemplate)
        XCTAssertEqual(resultingTitle, group.name)
        XCTAssertEqual(resultingColor, color.color )
    }
}

extension GroupNavigationPresenterTests: GroupNavigationViewProtocol {
    func updateNavBar(title: String, backgroundColor: UIColor) {
        resultingTitle = title
    }

    func showTabs(_ tabs: [GroupNavigationViewModel], color: UIColor) {
        resultingTabs = tabs
        resultingColor = color
    }

    func showError(_ error: Error) {
        resultingError = error as NSError
    }
}
