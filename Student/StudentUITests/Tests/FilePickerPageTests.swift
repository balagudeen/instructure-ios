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

class FilePickerPageTests: StudentTest {
    let page = FilePickerPage.self
}

class SubmissionFilePickerPageTests: FilePickerPageTests {
    func testEmptyState() {
        let course = seedClient.createCourse()
        let assignment = seedClient.createAssignment(for: course, submissionTypes: [.online_upload])
        let student = createStudent(in: course)
        launch("/courses/\(course.id)/assignments/\(assignment.id)/fileupload", as: student)
        page.assertExists(.emptyView)
        page.assertExists(.cameraButton)
        page.assertExists(.libraryButton)
        page.assertExists(.filesButton)
    }

    func testHidesCameraAndLibraryIfNotAllowed() {
        let course = seedClient.createCourse()
        let assignment = seedClient.createAssignment(
            for: course,
            submissionTypes: [.online_upload],
            allowedExtensions: ["txt"]
        )
        let student = createStudent(in: course)
        launch("/courses/\(course.id)/assignments/\(assignment.id)/fileupload", as: student)
        page.assertExists(.filesButton)
        page.assertHidden(.cameraButton)
        page.assertHidden(.libraryButton)
    }
}
