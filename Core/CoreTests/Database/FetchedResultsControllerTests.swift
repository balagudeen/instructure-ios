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
@testable import Core
import TestsFoundation

class FetchedResultsControllerTests: CoreTestCase {

    var frc: FetchedResultsController<Course>!
    var p: PersistenceClient {
        return databaseClient
    }
    var resultsDidChange = false
    var expectation = XCTestExpectation(description: "delegate was called")

    func testFetch() {
        let a: Course = p.make(["id": "1", "name": "a"])
        let b: Course = p.make(["id": "2", "name": "b"])

        let expected = [a, b]

        frc = database.fetchedResultsController(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)])
        frc.performFetch()

        let objs = frc.fetchedObjects
        XCTAssertEqual(objs!.count, 2)
        XCTAssertEqual(objs, expected)
    }

    func testFetchWithAdd() {
        let a: Course = p.make(["id": "1", "name": "a"])
        let b: Course = p.make(["id": "2", "name": "b"])

        let expected = [a, b]

        frc = database.fetchedResultsController(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)])
        frc.delegate = self
        frc.performFetch()

        var objs = frc.fetchedObjects
        XCTAssertEqual(objs!.count, 2)
        XCTAssertEqual(objs, expected)

        var c: Course?
        database.perform { (_) in
            c = Course.make(["id": "3", "name": "c"])
        }

        wait(for: [expectation], timeout: 0.1)
        XCTAssertTrue(resultsDidChange)
        frc.performFetch()
        objs = frc.fetchedObjects
        XCTAssertEqual(objs!.count, 3)
        XCTAssertEqual(objs, [a, b, c!])
    }

    func testObjectAtIndex() {
        _ = p.make(["id": "1", "name": "a"]) as Course
        let b: Course = p.make(["id": "2", "name": "b"])
        let indexPath = IndexPath(item: 1, section: 0)

        frc = database.fetchedResultsController(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)])
        frc.performFetch()
        let object = frc.object(at: indexPath)

        XCTAssertEqual(object, b)
    }

    func testPredicate() {
        let a: Course = p.make(["id": "1", "name": "foo"])
        let _: Course = p.make(["id": "2", "name": "bar"])
        let c: Course = p.make(["id": "3", "name": "foobar"])
        let expected = [a, c]

        let pred = NSPredicate(format: "name contains[c] %@", "foo")
        let sort = NSSortDescriptor(key: "name", ascending: true)

        frc = database.fetchedResultsController(predicate: pred, sortDescriptors: [sort])
        frc.performFetch()

        let objs = frc.fetchedObjects
        XCTAssertEqual(objs!.count, 2)
        XCTAssertEqual(objs, expected)
    }

    func testSort() {
        let c: Course = p.make(["id": "3", "name": "c"])
        let a: Course = p.make(["id": "1", "name": "a"])
        let b: Course = p.make(["id": "2", "name": "b"])
        let expected = [c, b, a]

        let sort = NSSortDescriptor(key: "name", ascending: false)
        frc = database.fetchedResultsController(sortDescriptors: [sort])
        frc.performFetch()

        let objs = frc.fetchedObjects
        XCTAssertEqual(objs!.count, 3)
        XCTAssertEqual(objs, expected)
    }

    func testSections() {
        let _: Course = p.make(["id": "1", "name": "a", "courseCode": "red"])
        let _: Course = p.make(["id": "2", "name": "b", "courseCode": "blue"])
        let _: Course = p.make(["id": "3", "name": "c", "courseCode": "red"])
        let _: Course = p.make(["id": "4", "name": "d", "courseCode": "blue"])
        let _: Course = p.make(["id": "5", "name": "e", "courseCode": "green"])

        let expected: [FetchedSection] = [
            FetchedSection(name: "blue", numberOfObjects: 2),
            FetchedSection(name: "green", numberOfObjects: 1),
            FetchedSection(name: "red", numberOfObjects: 2),
        ]

        let sort = NSSortDescriptor(key: "courseCode", ascending: true)
        let name = NSSortDescriptor(key: "name", ascending: false)
        frc = database.fetchedResultsController(sortDescriptors: [sort, name], sectionNameKeyPath: "courseCode")
        frc.performFetch()
        let sections = frc.sections!

        XCTAssertEqual(sections.count, 3)
        XCTAssertEqual(sections, expected)
    }

    func testSectionsWithNilKeyValue() {
        let _: Course = p.make(["id": "1", "name": "a", "courseCode": "red"])
        let _: Course = p.make(["id": "2", "name": "b", "courseCode": "blue"])
        let _: Course = p.make(["id": "3", "name": "c", "courseCode": "red"])
        let _: Course = p.make(["id": "4", "name": "d", "courseCode": "blue"])
        let e: Course = p.make(["id": "5", "name": "e"])

        let expected: [FetchedSection] = [
            FetchedSection(name: "", numberOfObjects: 1),
            FetchedSection(name: "blue", numberOfObjects: 2),
            FetchedSection(name: "red", numberOfObjects: 2),
        ]

        let sort = NSSortDescriptor(key: "courseCode", ascending: true)
        let name = NSSortDescriptor(key: "name", ascending: false)
        frc = database.fetchedResultsController(sortDescriptors: [sort, name], sectionNameKeyPath: "courseCode")
        frc.performFetch()
        let sections = frc.sections!

        XCTAssertEqual(sections.count, 3)
        XCTAssertEqual(sections, expected)

        let objectAtIndex = frc.object(at: IndexPath(row: 0, section: 0) )
        XCTAssertEqual(objectAtIndex, e)
    }

    func testObjectAtKeyPathWithSections() {
        let _: Course = p.make(["id": "1", "name": "a", "courseCode": "red"])
        let _: Course = p.make(["id": "2", "name": "b", "courseCode": "blue"])
        let c: Course = p.make(["id": "3", "name": "c", "courseCode": "red"])
        let _: Course = p.make(["id": "4", "name": "d", "courseCode": "blue"])
        let e: Course = p.make(["id": "5", "name": "e"])

        let expected: [FetchedSection] = [
            FetchedSection(name: "", numberOfObjects: 1),
            FetchedSection(name: "blue", numberOfObjects: 2),
            FetchedSection(name: "red", numberOfObjects: 2),
        ]

        let sort = NSSortDescriptor(key: "courseCode", ascending: true)
        let name = NSSortDescriptor(key: "name", ascending: true)
        frc = database.fetchedResultsController(sortDescriptors: [sort, name], sectionNameKeyPath: "courseCode")
        frc.performFetch()
        let sections = frc.sections!

        XCTAssertEqual(sections.count, 3)
        XCTAssertEqual(sections, expected)

        var objectAtIndex = frc.object(at: IndexPath(row: 0, section: 0))
        XCTAssertEqual(objectAtIndex, e)

        objectAtIndex = frc.object(at: IndexPath(row: 1, section: 2))
        XCTAssertEqual(objectAtIndex, c)
    }

    func testObservingValueChangesInSections() {
        let a: Course = p.make(["id": "1", "name": "a", "courseCode": "red"])
        let b: Course = p.make(["id": "2", "name": "b", "courseCode": "blue"])

        var expected: [FetchedSection] = [
            FetchedSection(name: "blue", numberOfObjects: 1),
            FetchedSection(name: "red", numberOfObjects: 1),
        ]

        let sort = [NSSortDescriptor(key: "courseCode", ascending: true), NSSortDescriptor(key: "name", ascending: true)]
        frc = database.fetchedResultsController(sortDescriptors: sort, sectionNameKeyPath: "courseCode")
        frc.performFetch()
        var sections = frc.sections!

        XCTAssertEqual(sections.count, 2)
        XCTAssertEqual(sections, expected)

        let obj = frc.object(at: IndexPath(row: 0, section: 1))
        XCTAssertEqual(obj, a)

        frc.delegate = self

        database.perform { (_) in
            b.courseCode = "red"
        }

        wait(for: [expectation], timeout: 0.1)
        XCTAssertTrue(resultsDidChange)
        frc.performFetch()
        sections = frc.sections!

        expected = [
            FetchedSection(name: "red", numberOfObjects: 2),
        ]

        XCTAssertEqual(sections.count, 1)
        XCTAssertEqual(sections, expected)
    }

    func testSortingOfSectionsWithDates() {
        let mockNow = Date(timeIntervalSince1970: 1536597712.04575)
        let mock100DaysFromMockNow = Calendar.current.date(byAdding: .day, value: 100, to: Date(timeIntervalSince1970: 1545241312.0443602))
        let _: TTL = p.make(["key": "a", "lastRefresh": mockNow])
        let _: TTL = p.make(["key": "b", "lastRefresh": mock100DaysFromMockNow])

        let expected: [FetchedSection] = [
            FetchedSection(name: "2018-09-10 16:41:52 +0000", numberOfObjects: 1),
            FetchedSection(name: "2019-03-29 16:41:52 +0000", numberOfObjects: 1),
            ]

        let sort = [NSSortDescriptor(key: "key", ascending: true), NSSortDescriptor(key: "lastRefresh", ascending: true)]
        let frc: FetchedResultsController<TTL> = database.fetchedResultsController(sortDescriptors: sort, sectionNameKeyPath: "lastRefresh")
        frc.performFetch()
        let sections = frc.sections!

        XCTAssertEqual(sections.count, 2)
        XCTAssertEqual(sections, expected)
    }

    func testObservingValueChangesInRowsOnBackgroundThread() {
        let _: Course = p.make(["id": "1", "name": "a"])
        frc = database.fetchedResultsController(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)])
        frc.delegate = self
        frc.performFetch()
        XCTAssertEqual(frc.fetchedObjects?.count, 1)

        let opExpectation = XCTestExpectation(description: "opExpectation")
        let op = BlockOperation {
            self.database.performBackgroundTask { client in
                Course.make(["id": "2", "name": "b", "courseCode": "blue"], client: client)
                let courses: [Course] = client.fetch()
                XCTAssertEqual(courses.count, 2)
                opExpectation.fulfill()
            }
        }

        let q = OperationQueue()
        q.addOperation(op)

        wait(for: [opExpectation], timeout: 0.1)

        p.refresh()
        frc.performFetch()
        let objs = frc.fetchedObjects ?? []
        XCTAssertEqual(objs.count, 2)
    }
}

extension FetchedResultsControllerTests: FetchedResultsControllerDelegate {
    func controllerDidChangeContent<T>(_ controller: FetchedResultsController<T>) {
        resultsDidChange = true
        expectation.fulfill()
    }

}
