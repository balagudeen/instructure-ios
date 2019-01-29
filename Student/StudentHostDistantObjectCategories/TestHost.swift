//
// Copyright (C) 2018-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation
import UIKit
@testable import Core
@testable import Student
import WebKit

// https://github.com/google/EarlGrey/blob/earlgrey2/docs/swift-white-boxing.md

@objc
protocol TestHost {
    func getToken(host: String, id: String, password: String, callback: @escaping (String) -> Void) -> NSObjectProtocol
    func reset()
    func logIn(domain: String, token: String)
    func show(_ route: String)
}

extension GREYHostApplicationDistantObject: TestHost {
    var appDelegate: AppDelegate {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("wrong app delegate type")
        }
        return delegate
    }

    func reset() {
        resetNavigationStack()
        resetDatabase()
        setScreenshotDir()
    }

    private func resetNavigationStack() {
        guard let root = appDelegate.window.rootViewController else { return }
        removePresented(root)
        let navController = root as? UINavigationController ?? root.navigationController
        navController?.popToRootViewController(animated: false)
    }

    private func removePresented(_ controller: UIViewController) {
        if let presented = controller.presentedViewController {
            removePresented(presented)
            presented.dismiss(animated: false, completion: nil)
        }
    }

    private func resetDatabase() {
        do {
            let store = appDelegate.environment.database
            try store.clearAllRecords()
        } catch {
            fatalError("failed to reset database")
        }
    }

    func logIn(domain: String, token: String) {
        let baseURL = URL(string: "https://\(domain)")!
        appDelegate.setup(session: KeychainEntry(accessToken: token, baseURL: baseURL, expiresAt: nil, locale: "en", refreshToken: nil, userID: "", userName: ""))
        appDelegate.environment.queue.waitUntilAllOperationsAreFinished()
    }

    func show(_ route: String) {
        guard var controller = router.match(.parse(route)) else {
            fatalError("No route for \(route)")
        }
        if !(controller is UINavigationController) {
            controller = UINavigationController(rootViewController: controller)
        }
        appDelegate.window.rootViewController = controller
        controller.loadViewIfNeeded()
        appDelegate.environment.queue.waitUntilAllOperationsAreFinished()
    }

    func setScreenshotDir() {
        guard let documentDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            fatalError("no document directory")
        }

        let screenshotDir = documentDir.appendingPathComponent("earlgrey_screenshots").path

        do {
            try FileManager.default.createDirectory(atPath: screenshotDir, withIntermediateDirectories: true, attributes: nil)
        } catch {
            fatalError(error.localizedDescription)
        }

        GREYConfiguration.shared.setValue(screenshotDir, forConfigKey: GREYConfigKey.artifactsDirLocation)
    }

    func getToken(host: String, id: String, password: String, callback: @escaping (String) -> Void) -> NSObjectProtocol {
        // Must return the TokenProvider in order to retain the reference
        return TokenProvider(host: host, loginID: id, password: password, callback: callback)
    }
}
