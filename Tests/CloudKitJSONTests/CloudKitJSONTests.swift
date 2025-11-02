//
//  CloudKitJSONTests.swift
//  CloudKitJSONTests
//
//  Created by Licardo on 2025/11/2.
//

import XCTest
import SwiftData
@testable import CloudKitJSON

final class CloudKitJSONTests: XCTestCase {

    // MARK: - Test Models

    struct JobModel: Codable, Equatable {
        var company: String
        var salary: Double
        var remote: Bool
        var startDate: Date

        static let sample = JobModel(
            company: "Apple",
            salary: 120000.0,
            remote: true,
            startDate: Date()
        )
    }

    @Model
    class TestPerson {
        var name: String
        var job: CloudKitJSON<JobModel>

        init(name: String, job: JobModel) {
            self.name = name
            self.job = CloudKitJSON(job)
        }
    }

    // MARK: - Basic Encoding/Decoding Tests

    func testBasicEncodingDecoding() throws {
        let job = JobModel.sample
        let cloudKitJSON = CloudKitJSON(job)

        // Test wrapped value
        XCTAssertEqual(cloudKitJSON.wrappedValue, job)

        // Test data access
        let decodedJob = try JSONDecoder().decode(JobModel.self, from: cloudKitJSON.projectedValue)
        XCTAssertEqual(decodedJob, job)
    }

    func testJSONStringConversion() throws {
        let job = JobModel.sample
        let cloudKitJSON = CloudKitJSON(job)

        let jsonString = cloudKitJSON.jsonString
        XCTAssertNotNil(jsonString)

        // Test JSON string parsing
        let cloudKitJSONFromString = CloudKitJSON<JobModel>(jsonString: jsonString!)
        XCTAssertNotNil(cloudKitJSONFromString)
        XCTAssertEqual(cloudKitJSONFromString?.wrappedValue, job)
    }

    // MARK: - Property Access Tests

    func testPropertyAccess() throws {
        let job = JobModel.sample
        var cloudKitJSON = CloudKitJSON(job)

        // Test property access using dot syntax
        XCTAssertEqual(cloudKitJSON.company, job.company)
        XCTAssertEqual(cloudKitJSON.salary, job.salary)
        XCTAssertEqual(cloudKitJSON.remote, job.remote)

        // Test property modification using functional style
        var modifiedCloudKitJSON = CloudKitJSON(cloudKitJSON.wrappedValue)
        var modifiedJob = modifiedCloudKitJSON.wrappedValue
        modifiedJob.company = "Google"
        modifiedCloudKitJSON.wrappedValue = modifiedJob

        XCTAssertEqual(modifiedCloudKitJSON.company, "Google")
        XCTAssertEqual(modifiedCloudKitJSON.wrappedValue.company, "Google")

        modifiedJob.salary = 150000.0
        modifiedCloudKitJSON.wrappedValue = modifiedJob
        XCTAssertEqual(modifiedCloudKitJSON.salary, 150000.0)
        XCTAssertEqual(modifiedCloudKitJSON.wrappedValue.salary, 150000.0)
    }

    func testConvenienceAccess() throws {
        let job = JobModel.sample
        let cloudKitJSON = CloudKitJSON(job)

        // Test property access using dot syntax
        XCTAssertEqual(cloudKitJSON.company, job.company)
        XCTAssertEqual(cloudKitJSON.salary, job.salary)
    }

    func testDotSyntaxAccess() throws {
        let job = JobModel.sample
        let cloudKitJSON = CloudKitJSON(job)

        // Test direct dot syntax access (read-only)
        XCTAssertEqual(cloudKitJSON.company, job.company)
        XCTAssertEqual(cloudKitJSON.salary, job.salary)
        XCTAssertEqual(cloudKitJSON.remote, job.remote)
        XCTAssertEqual(cloudKitJSON.startDate, job.startDate)
    }

    func testMutableProxyAccess() throws {
        let job = JobModel.sample
        var cloudKitJSON = CloudKitJSON(job)

        // Test mutable proxy for direct read/write access
        XCTAssertEqual(cloudKitJSON.mutable.company, job.company)
        XCTAssertEqual(cloudKitJSON.mutable.salary, job.salary)

        // Test direct modification through mutable proxy
        cloudKitJSON.mutable.company = "Google"
        XCTAssertEqual(cloudKitJSON.mutable.company, "Google")
        XCTAssertEqual(cloudKitJSON.company, "Google") // Original should be updated

        cloudKitJSON.mutable.salary = 150000.0
        XCTAssertEqual(cloudKitJSON.mutable.salary, 150000.0)
        XCTAssertEqual(cloudKitJSON.salary, 150000.0)

        cloudKitJSON.mutable.remote = false
        XCTAssertEqual(cloudKitJSON.mutable.remote, false)
        XCTAssertEqual(cloudKitJSON.remote, false)
    }

    // MARK: - Codable Conformance Tests

    func testCodableConformance() throws {
        let job = JobModel.sample
        let cloudKitJSON = CloudKitJSON(job)

        // Test encoding
        let encodedData = try JSONEncoder().encode(cloudKitJSON)
        XCTAssertFalse(encodedData.isEmpty)

        // Test decoding
        let decodedCloudKitJSON = try JSONDecoder().decode(CloudKitJSON<JobModel>.self, from: encodedData)
        XCTAssertEqual(decodedCloudKitJSON.wrappedValue, job)
    }

    // MARK: - Cache Management Tests

    func testCacheManagement() throws {
        let job = JobModel.sample
        var cloudKitJSON = CloudKitJSON(job)

        // Test initial state
        let initialCompany = cloudKitJSON.company

        // Test refresh functionality
        let refreshedCloudKitJSON = cloudKitJSON.refreshed()
        XCTAssertEqual(refreshedCloudKitJSON.company, job.company)
    }

    // MARK: - SwiftData Integration Tests

    func testSwiftDataIntegration() throws {
        // Create a temporary container for testing
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: TestPerson.self, configurations: config)
        let context = ModelContext(container)

        // Create a person with CloudKitJSON field
        let job = JobModel.sample
        let person = TestPerson(name: "John Doe", job: job)

        // Test property access using dot syntax
        XCTAssertEqual(person.job.company, job.company)
        XCTAssertEqual(person.job.salary, job.salary)

        // Modify through mutable proxy
        person.job.mutable.company = "Swift Corp"
        XCTAssertEqual(person.job.company, "Swift Corp")
        XCTAssertEqual(person.job.mutable.company, "Swift Corp")

        // Save to SwiftData
        context.insert(person)
        try context.save()

        // Fetch from SwiftData
        let fetchDescriptor = FetchDescriptor<TestPerson>()
        let fetchedPersons = try context.fetch(fetchDescriptor)
        XCTAssertEqual(fetchedPersons.count, 1)

        let fetchedPerson = fetchedPersons.first!
        XCTAssertEqual(fetchedPerson.name, "John Doe")
        XCTAssertEqual(fetchedPerson.job.company, "Swift Corp")
        XCTAssertEqual(fetchedPerson.job.salary, job.salary)
        XCTAssertEqual(fetchedPerson.job.remote, job.remote)

        // Test that mutable proxy works on fetched objects too
        XCTAssertEqual(fetchedPerson.job.mutable.company, "Swift Corp")
    }

    // MARK: - Performance Tests

    func testPerformanceEncodingDecoding() throws {
        let job = JobModel.sample
        let cloudKitJSON = CloudKitJSON(job)

        measure {
            // Test multiple access operations using dot syntax
            for _ in 0..<1000 {
                _ = cloudKitJSON.company
                _ = cloudKitJSON.salary
                _ = cloudKitJSON.remote
            }
        }
    }

    func testPerformanceCacheHit() throws {
        let job = JobModel.sample
        let cloudKitJSON = CloudKitJSON(job)

        // Warm up cache
        _ = cloudKitJSON.wrappedValue

        measure {
            // Test cached access
            for _ in 0..<1000 {
                _ = cloudKitJSON.wrappedValue
            }
        }
    }

    // MARK: - Edge Cases Tests

    func testEmptyDataHandling() throws {
        let emptyData = Data()
        let cloudKitJSON = CloudKitJSON<JobModel>(data: emptyData)

        // This should throw when accessing wrappedValue
        XCTAssertThrowsError(try JSONDecoder().decode(JobModel.self, from: emptyData))
    }

    func testComplexNestedStructures() throws {
        struct Address: Codable, Equatable {
            var street: String
            var city: String
            var zipCode: String
        }

        struct PersonWithAddress: Codable, Equatable {
            var name: String
            var age: Int
            var address: Address
        }

        let address = Address(street: "123 Main St", city: "Cupertino", zipCode: "95014")
        let person = PersonWithAddress(name: "Jane Doe", age: 30, address: address)

        var cloudKitJSON = CloudKitJSON(person)

        // Test nested access
        XCTAssertEqual(cloudKitJSON.name, person.name)
        XCTAssertEqual(cloudKitJSON.address.city, address.city)

        // Test nested modification
        var modifiedCloudKitJSON = CloudKitJSON(cloudKitJSON.wrappedValue)
        var modifiedPerson = modifiedCloudKitJSON.wrappedValue
        modifiedPerson.address.city = "San Francisco"
        modifiedCloudKitJSON.wrappedValue = modifiedPerson
        XCTAssertEqual(modifiedCloudKitJSON.address.city, "San Francisco")
    }

    // MARK: - Thread Safety Tests

    func testConcurrentAccess() throws {
        let job = JobModel.sample
        var cloudKitJSON = CloudKitJSON(job)

        let expectation = XCTestExpectation(description: "Concurrent access")
        expectation.expectedFulfillmentCount = 10

        // Test concurrent read access
        for i in 0..<10 {
            DispatchQueue.global(qos: .background).async {
                _ = cloudKitJSON.company
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 5.0)
    }
}