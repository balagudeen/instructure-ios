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
@testable import Core
import TestsFoundation

class UrlSubmissionPageTests: StudentTest {

    let page = UrlSubmissionPage.self

    lazy var course: APICourse = {
        return seedClient.createCourse()
    }()
    lazy var teacher: AuthUser = {
        return createTeacher(in: course)
    }()
    lazy var student: AuthUser = {
        return createStudent(in: course)
    }()

    func testSumbitUrl() {
        let assignment = seedClient.createAssignment(for: course, submissionTypes: [.online_url])
        launch("/courses/\(course.id)/assignments/\(assignment.id)/submissions/\(student.id)/urlsubmission", as: student)
        page.assertVisible(.url)
        page.assertVisible(.preview)
        page.assertHidden(.loadingView)
        page.typeText("www.amazon.com", in: .url)
        page.tap(label: "Done")
        page.tap(.submit)
        page.assertExists(.loadingView)
        page.assertVisible(.loadingView)

        launch("/courses/\(course.id)/assignments/\(assignment.id)/submissions/\(student.id)", as: student)
        let submission = SubmissionDetailsPage.self
        submission.assertExists(.urlButton)
        submission.assertText(.urlButton, equals: "http://www.amazon.com")
    }
}
