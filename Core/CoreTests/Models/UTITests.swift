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
import Core
import XCTest

class UTITests: XCTestCase {
    func testInitInvalid() {
        let empty = UTI(extension: "")
        XCTAssertNil(empty)
    }

    func testInitValid() {
        let png = UTI(extension: "png")
        XCTAssertNotNil(png)

        let jpg = UTI(extension: "jpg")
        XCTAssertNotNil(jpg)

        let psd = UTI(extension: "psd")
        XCTAssertNotNil(psd)
    }

    func testAny() {
        XCTAssertEqual(UTI.any.rawValue, "public.item")
        XCTAssertTrue(UTI.any.isAny)
    }

    func testVideo() {
        XCTAssertEqual(UTI.video.rawValue, "public.movie")
        XCTAssertTrue(UTI.video.isVideo)
        XCTAssertTrue(UTI(extension: "mp4")!.isVideo)
    }

    func testAudio() {
        XCTAssertEqual(UTI.audio.rawValue, "public.audio")
        XCTAssertTrue(UTI.audio.isAudio)
        XCTAssertTrue(UTI(extension: "mp3")!.isAudio)
    }

    func testImage() {
        XCTAssertEqual(UTI.image.rawValue, "public.image")
        XCTAssertTrue(UTI.image.isImage)
        XCTAssertTrue(UTI(extension: "jpg")!.isImage)
    }

    func testText() {
        XCTAssertEqual(UTI.text.rawValue, "public.text")
    }

    func testURL() {
        XCTAssertEqual(UTI.url.rawValue, "public.url")
    }
}
