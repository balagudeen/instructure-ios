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
@testable import Student
import UIKit

class FilePickerView: FilePickerViewProtocol {
    var navigationController: UINavigationController?
    var presentCameraCallCount = 0
    var presentLibraryCallCount = 0
    var files: [FileViewModel]?
    var sources: [FilePickerSource]?
    var presentedDocumentTypes: [String]?
    var error: Error?
    var progress: Float = 0
    var toolbarItems: [UIBarButtonItem]?
    var navigationItems: (left: [UIBarButtonItem], right: [UIBarButtonItem])?
    var dismissed: Bool = false
    var onUpdate: (() -> Void)?
    var bytesSent: Int64?
    var expectedToSend: Int64?

    func presentCamera() {
        presentCameraCallCount += 1
    }

    func presentLibrary() {
        presentLibraryCallCount += 1
    }

    func presentDocumentPicker(documentTypes: [String]) {
        presentedDocumentTypes = documentTypes
    }

    func showError(_ error: Error) {
        self.error = error
    }

    func update(files: [FileViewModel], sources: [FilePickerSource]) {
        self.files = files
        self.sources = sources
        onUpdate?()
    }

    func updateTransferProgress(_ progress: Float, sent: Int64, expectedToSend: Int64) {
        self.progress = progress
        self.bytesSent = sent
        self.expectedToSend = expectedToSend
    }

    func updateTransferProgress(_ progress: Float) {
        self.progress = progress
    }

    func updateToolbar(items: [UIBarButtonItem]) {
        toolbarItems = items
    }

    func updateNavigationItems(left: [UIBarButtonItem], right: [UIBarButtonItem]) {
        navigationItems = (left: left, right: right)
    }

    func dismiss() {
        dismissed = true
    }
}
