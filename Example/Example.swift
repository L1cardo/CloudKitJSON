//
//  Example.swift
//  CloudKitJSON
//
//  Example usage of CloudKitJSON with SwiftData
//

import Foundation
import SwiftData
import CloudKitJSON

// MARK: - Example Data Models

struct JobModel: Codable {
    var company: String
    var salary: Double
    var remote: Bool
    var startDate: Date
    var benefits: [String]
    var department: Department
}

struct Department: Codable {
    var name: String
    var location: String
    var budget: Double
}

struct Address: Codable {
    var street: String
    var city: String
    var state: String
    var zipCode: String
    var country: String
}

struct PersonalInfo: Codable {
    var age: Int
    var address: Address
    var phone: String
    var email: String
    var socialProfiles: [String: String]
}

// MARK: - SwiftData Models

@Model
class Employee {
    var id: UUID
    var name: String
    var job: CloudKitJSON<JobModel>
    var personalInfo: CloudKitJSON<PersonalInfo>
    var skills: CloudKitJSON<[String]>
    var createdAt: Date

    init(name: String, job: JobModel, personalInfo: PersonalInfo, skills: [String]) {
        self.id = UUID()
        self.name = name
        self.job = CloudKitJSON(job)
        self.personalInfo = CloudKitJSON(personalInfo)
        self.skills = CloudKitJSON(skills)
        self.createdAt = Date()
    }
}

// MARK: - Convenience Extensions for Easy Access

extension Employee {
    // Job-related computed properties
    var jobCompany: String {
        get { job.get(\.company) }
        set {
            var j = job.wrappedValue
            j.company = newValue
            job.wrappedValue = j
        }
    }

    var jobSalary: Double {
        get { job.get(\.salary) }
        set {
            var j = job.wrappedValue
            j.salary = newValue
            job.wrappedValue = j
        }
    }

    var isRemote: Bool {
        get { job.get(\.remote) }
        set {
            var j = job.wrappedValue
            j.remote = newValue
            job.wrappedValue = j
        }
    }

    var department: String {
        get { job.get(\.department.name) }
        set {
            var j = job.wrappedValue
            j.department.name = newValue
            job.wrappedValue = j
        }
    }

    // Personal info computed properties
    var city: String {
        get { personalInfo.get(\.address.city) }
        set {
            var info = personalInfo.wrappedValue
            info.address.city = newValue
            personalInfo.wrappedValue = info
        }
    }

    var email: String {
        get { personalInfo.get(\.email) }
        set {
            var info = personalInfo.wrappedValue
            info.email = newValue
            personalInfo.wrappedValue = info
        }
    }

    var age: Int {
        get { personalInfo.get(\.age) }
        set {
            var info = personalInfo.wrappedValue
            info.age = newValue
            personalInfo.wrappedValue = info
        }
    }

    // Skills access
    var skillList: [String] {
        get { skills.wrappedValue }
        set { skills.wrappedValue = newValue }
    }
}

// MARK: - Usage Examples

class EmployeeManager {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func createExampleEmployee() {
        // Create job data
        let job = JobModel(
            company: "Apple",
            salary: 120000,
            remote: true,
            startDate: Date(),
            benefits: ["Health Insurance", "Stock Options", "401k"],
            department: Department(
                name: "Software Engineering",
                location: "Cupertino",
                budget: 1000000
            )
        )

        // Create personal info
        let personalInfo = PersonalInfo(
            age: 30,
            address: Address(
                street: "1 Infinite Loop",
                city: "Cupertino",
                state: "CA",
                zipCode: "95014",
                country: "USA"
            ),
            phone: "+1-555-0123",
            email: "john.doe@company.com",
            socialProfiles: [
                "linkedin": "linkedin.com/in/johndoe",
                "github": "github.com/johndoe"
            ]
        )

        // Create skills array
        let skills = ["Swift", "SwiftUI", "Combine", "Core Data", "SwiftData"]

        // Create employee
        let employee = Employee(
            name: "John Doe",
            job: job,
            personalInfo: personalInfo,
            skills: skills
        )

        // Save to SwiftData
        modelContext.insert(employee)
        try? modelContext.save()

        print("Created employee: \(employee.name)")
    }

    func demonstrateAccess() {
        // Fetch employees
        let fetchDescriptor = FetchDescriptor<Employee>()
        guard let employees = try? modelContext.fetch(fetchDescriptor),
              let employee = employees.first else {
            print("No employees found")
            return
        }

        // Demonstrate simple property access
        print("=== Simple Property Access ===")
        print("Name: \(employee.name)")
        print("Company: \(employee.jobCompany)")  // Using computed property
        print("Salary: \(employee.jobSalary)")     // Using computed property
        print("City: \(employee.city)")            // Using computed property
        print("Age: \(employee.age)")              // Using computed property

        // Demonstrate dot syntax access
        print("\n=== Dot Syntax Access ===")
        print("Department: \(employee.job.department.name)")
        print("Location: \(employee.job.department.location)")
        print("Phone: \(employee.personalInfo.phone)")
        print("Email: \(employee.personalInfo.email)")

        // Demonstrate nested access
        print("\n=== Nested Access ===")
        print("Street: \(employee.personalInfo.address.street)")
        print("Zip Code: \(employee.personalInfo.address.zipCode)")
        print("Country: \(employee.personalInfo.address.country)")

        // Demonstrate array access
        print("\n=== Array Access ===")
        print("Skills: \(employee.skillList)")
        print("Benefits: \(employee.job.benefits)")

        // Demonstrate social profiles access
        print("\n=== Dictionary Access ===")
        let socialProfiles = employee.personalInfo.socialProfiles
        for (platform, url) in socialProfiles {
            print("\(platform): \(url)")
        }

        // Demonstrate modifications
        print("\n=== Modifications ===")

        // Modify using computed properties
        employee.jobSalary = 130000
        employee.city = "San Francisco"
        employee.email = "john.doe@updated.com"

        print("Updated Salary: \(employee.jobSalary)")
        print("Updated City: \(employee.city)")
        print("Updated Email: \(employee.email)")

        // Modify using setting method
        employee.job = employee.job.setting(\.company, to: "Google")
        print("Updated Company: \(employee.job.get(\.company))")

        // Add a skill
        var currentSkills = employee.skillList
        currentSkills.append("CloudKit")
        employee.skillList = currentSkills
        print("Updated Skills: \(employee.skillList)")

        // Save changes
        try? modelContext.save()
        print("Changes saved!")
    }

    func demonstrateDataAccess() {
        guard let employees = try? modelContext.fetch(FetchDescriptor<Employee>()),
              let employee = employees.first else { return }

        // Demonstrate raw data access
        print("\n=== Raw Data Access ===")

        // Access the raw JSON data
        let jobData = employee.job.projectedValue
        print("Job JSON data size: \(jobData.count) bytes")

        // Get JSON string representation
        if let jobJSON = employee.job.jsonString {
            print("Job JSON string length: \(jobJSON.characters.count)")
            print("Job JSON preview: \(String(jobJSON.prefix(100)))...")
        }

        // Demonstrate creating new instances from JSON
        if let jobJSON = employee.job.jsonString,
           let newJobInstance = CloudKitJSON<JobModel>(jsonString: jobJSON) {
            print("Created new instance from JSON: \(newJobInstance.get(\.company))")
        }
    }
}

// MARK: - Main Usage Example

func main() {
    // Setup SwiftData container
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Employee.self, configurations: config)
    let context = ModelContext(container)

    // Create manager and run examples
    let manager = EmployeeManager(modelContext: context)

    print("🚀 CloudKitJSON Example")
    print("======================")

    manager.createExampleEmployee()
    manager.demonstrateAccess()
    manager.demonstrateDataAccess()

    print("\n✅ Example completed successfully!")
}

// Uncomment to run the example
// main()