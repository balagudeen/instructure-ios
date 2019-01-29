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
@testable import Core
import TestsFoundation

class DashboardIntegrationTests: XCTestCase {
    func testView() {
        let view = DashboardViewController.create(env: testEnvironment())
        let mockPresenter = MockDashboardPresenter()
        view.presenter = mockPresenter

        XCTAssertNotNil(view.presenter)
        XCTAssert(view.viewModel == nil)

        view.loadViewIfNeeded()
        XCTAssert(mockPresenter.vcDidLoadMethodCalledCount == 1)

        view.refreshView()
        XCTAssert(mockPresenter.refreshMethodCalledCount == 1)
    }
}
