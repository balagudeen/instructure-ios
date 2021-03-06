//
// Copyright (C) 2019-present Instructure, Inc.
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

class StoreTests: CoreTestCase {
    struct TestUseCase: UseCase {
        typealias Model = Course

        let courses: [APICourse]?
        let requestError: Error?
        let writeError: Error?
        let urlResponse: URLResponse?

        init(courses: [APICourse]? = nil, requestError: Error? = nil, writeError: Error? = nil, urlResponse: URLResponse? = nil) {
            self.courses = courses
            self.requestError = requestError
            self.writeError = writeError
            self.urlResponse = urlResponse
        }

        var scope: Scope {
            return .all(orderBy: #keyPath(Course.name))
        }

        var cacheKey: String {
            return "test-use-case"
        }

        func makeRequest(environment: AppEnvironment, completionHandler: @escaping ([APICourse]?, URLResponse?, Error?) -> Void) {
            completionHandler(courses, urlResponse, requestError)
        }

        func write(response: [APICourse]?, urlResponse: URLResponse?, to client: PersistenceClient) throws {
            if let error = writeError {
                throw error
            }
            guard let response = response else {
                return
            }
            for item in response {
                let predicate = NSPredicate(format: "%K == %@", #keyPath(Course.id), item.id)
                let course: Course = client.fetch(predicate).first ?? client.insert()
                course.name = item.name
                course.id = item.id
                course.isFavorite = item.is_favorite ?? false
            }
        }

        func getNext(from urlResponse: URLResponse) -> GetNextRequest<[APICourse]>? {
            return GetCoursesRequest(includeUnpublished: false).getNext(from: urlResponse)
        }
    }

    // Copy store since it is mutable
    struct StoreSnapshot {
        let pending: Bool
        let error: Error?
        let count: Int
        let objects: [TestUseCase.Model]

        init(store: Store<TestUseCase>) {
            self.pending = store.pending
            self.error = store.error
            self.count = store.count

            var objects: [TestUseCase.Model] = []
            for section in 0..<store.numberOfSections {
                for row in 0..<store.numberOfObjects(inSection: section) {
                    if let object = store[IndexPath(row: row, section: section)] {
                        objects.append(object)
                    }
                }
            }
            self.objects = objects
        }
    }

    var store: Store<TestUseCase>!
    var snapshots: [StoreSnapshot] = []
    let eventsExpectation = XCTestExpectation(description: "store events")

    func storeUpdated() {
        let snapshot = StoreSnapshot(store: self.store)
        self.snapshots.append(snapshot)
        self.eventsExpectation.fulfill()
    }

    func testSubscribeWithoutCache() {
        let course = APICourse.make(["id": "1"])
        let useCase = TestUseCase(courses: [course])
        eventsExpectation.expectedFulfillmentCount = 4
        store = environment.subscribe(useCase, storeUpdated)
        store.refresh()

        wait(for: [eventsExpectation], timeout: 1.0)

        let cached = snapshots[0]
        let loading = snapshots[1]
        let notLoading = snapshots[2]
        let loaded = snapshots[3]

        // cached
        XCTAssertEqual(cached.count, 0)

        // loading
        XCTAssertEqual(loading.count, 0)
        XCTAssertTrue(loading.pending)
        XCTAssertNil(loading.error)

        // not loading
        XCTAssertFalse(notLoading.pending)
        XCTAssertNil(notLoading.error)

        // loaded
        XCTAssertEqual(loaded.count, 1)
        XCTAssertFalse(loaded.pending)
        XCTAssertEqual(loaded.objects.first?.id, "1")
        XCTAssertNil(loaded.error)

        let ttls: [TTL] = databaseClient.fetch()
        XCTAssertEqual(ttls.count, 1)
    }

    func testSubscribeWithCache() {
        let course = APICourse.make(["id": "1"])
        let useCase = TestUseCase(courses: [course])
        let multipleEvents = XCTestExpectation(description: "too many store events")
        multipleEvents.isInverted = true

        store = environment.subscribe(useCase) {
            self.storeUpdated()
            if self.snapshots.count > 1 {
                multipleEvents.fulfill()
            }
        }

        Course.make(["id": "1"])
        let now = Date()
        Clock.mockNow(now)
        let cache: TTL = databaseClient.insert()
        cache.key = useCase.cacheKey
        cache.lastRefresh = Clock.now
        try! databaseClient.save()

        wait(for: [eventsExpectation], timeout: 1.0)
        wait(for: [multipleEvents], timeout: 1.0)
        XCTAssertEqual(snapshots.count, 1)

        let cached = snapshots[0]
        XCTAssertEqual(cached.objects.first?.id, "1")
        XCTAssertFalse(cached.pending)
        XCTAssertNil(cached.error)
    }

    func testSubscribeWithNetworkError() {
        let requestError = NSError.instructureError("network error")
        let useCase = TestUseCase(requestError: requestError)
        eventsExpectation.expectedFulfillmentCount = 4
        store = environment.subscribe(useCase, storeUpdated)
        store.refresh()

        wait(for: [eventsExpectation], timeout: 1.0)

        let cached = snapshots[0]
        let loading = snapshots[1]
        let notLoading = snapshots[2]
        let error = snapshots[3]

        // cached
        XCTAssertEqual(cached.count, 0)

        // loading
        XCTAssertEqual(loading.count, 0)
        XCTAssertTrue(loading.pending)
        XCTAssertNil(loading.error)

        // not loading
        XCTAssertEqual(notLoading.count, 0)
        XCTAssertFalse(notLoading.pending)

        // error
        XCTAssertEqual(error.count, 0)
        XCTAssertFalse(error.pending)
        XCTAssertEqual(error.error?.localizedDescription, "network error")

        let ttls: [TTL] = databaseClient.fetch()
        XCTAssertEqual(ttls.count, 0)
    }

    func testSubscribeWithWriteError() {
        let writeError = NSError.instructureError("write error")
        let useCase = TestUseCase(writeError: writeError)
        eventsExpectation.expectedFulfillmentCount = 4
        store = environment.subscribe(useCase, storeUpdated)
        store.refresh()

        wait(for: [eventsExpectation], timeout: 1.0)

        let cached = snapshots[0]
        let loading = snapshots[1]
        let notLoading = snapshots[2]
        let error = snapshots[3]

        // cached
        XCTAssertEqual(cached.count, 0)
        XCTAssertNil(cached.error)

        // loading
        XCTAssertEqual(loading.count, 0)
        XCTAssertTrue(loading.pending)
        XCTAssertNil(loading.error)

        // not loading
        XCTAssertEqual(notLoading.count, 0)
        XCTAssertFalse(notLoading.pending)

        // error
        XCTAssertEqual(error.count, 0)
        XCTAssertFalse(error.pending)
        XCTAssertEqual(error.error?.localizedDescription, "write error")

        let ttls: [TTL] = databaseClient.fetch()
        XCTAssertEqual(ttls.count, 0)
    }

    func testGetNextPage() {
        let prev = "https://cgnuonline-eniversity.edu/api/v1/date"
        let curr = "https://cgnuonline-eniversity.edu/api/v1/date?page=2"
        let next = "https://cgnuonline-eniversity.edu/api/v1/date?page=3"
        let headers = [
            "Link": "<\(curr)>; rel=\"current\",<>;, <\(prev)>; rel=\"prev\", <\(next)>; rel=\"next\"; count=1",
        ]
        let response = HTTPURLResponse(url: URL(string: curr)!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: headers)!
        let secondPage = XCTestExpectation(description: "second page of courses")
        secondPage.expectedFulfillmentCount = 5

        let course1 = APICourse.make(["id": "1"])
        let useCase = TestUseCase(courses: [course1], urlResponse: response)
        eventsExpectation.expectedFulfillmentCount = 4
        store = environment.subscribe(useCase) {
            self.storeUpdated()
            secondPage.fulfill()
        }
        store.refresh()

        // first page
        wait(for: [eventsExpectation], timeout: 1.0)

        XCTAssertEqual(store.count, 1)
        let course2 = APICourse.make(["id": "2"])
        api.mock(useCase.getNext(from: response)!, value: [course2], response: nil, error: nil)
        store.getNextPage()
        wait(for: [secondPage], timeout: 1.0)
        XCTAssertEqual(store.count, 2)
    }
}
