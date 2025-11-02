<div align="center">
  <h1>CloudKitJSON</h1>
  <p>
    一个无缝集成JSON编码/解码与SwiftData的Swift包，让您无需重构数据模型即可在SwiftData模型中存储复杂的Codable对象。
  </p>

  <p>
    <strong>🇨🇳中文</strong>  | <strong><a href="./README.md">🇬🇧English</a></strong>
  </p>

<p>
    <img src="https://img.shields.io/badge/Platforms-iOS%20%7C%20macOS%20%7C%20watchOS%20%7C%20visionOS-lightgrey.svg">
    <img src="https://img.shields.io/badge/license-MIT-blue?style=flat-square" alt="License: MIT">
    <img src="https://img.shields.io/badge/Swift-6.2-orange?style=flat-square&logo=swift" alt="Swift 6.2">
  </p>
</div>

---

## 特性

- 🎯 **直接点语法访问** - 使用`person.job.company`进行直观的属性访问
- 🔄 **无缝SwiftData集成** - 将任何Codable对象存储为SwiftData模型中的JSON数据
- 🚀 **零样板代码** - 简单的一行初始化：`CloudKitJSON(yourObject)`
- 📱 **现代Swift** - 基于Swift 6、`@dynamicMemberLookup`和现代Swift最佳实践构建
- 🔧 **类型安全** - 完整的类型安全和编译时检查
- ⚡ **性能优化** - 高效的JSON编码/解码，最小开销
- 🌊 **不可变设计** - 安全、可预测的函数式更新行为

## 安装

将CloudKitJSON添加到您的`Package.swift`文件中：

```swift
dependencies: [
    .package(url: "https://github.com/your-username/CloudKitJSON.git", from: "1.0.0")
]
```

或者在Xcode中通过`File → Add Package Dependencies...`添加。

## 快速开始

### 基础用法

```swift
import SwiftData
import CloudKitJSON

// 定义您的复杂数据模型
struct JobModel: Codable {
    var company: String
    var salary: Double
    var remote: Bool
    var startDate: Date
}

// 在SwiftData模型中使用
@Model
class Person {
    var name: String
    var job: CloudKitJSON<JobModel>

    init(name: String, job: JobModel) {
        self.name = name
        self.job = CloudKitJSON(job)  // 一行初始化！
    }
}

// 创建实例
let person = Person(
    name: "张三",
    job: JobModel(
        company: "苹果",
        salary: 120000,
        remote: true,
        startDate: Date()
    )
)
```

### 直观的属性访问

```swift
// 🌟 使用简单的点语法访问属性 - 就像原生属性一样！
let company = person.job.company     // "苹果"
let salary = person.job.salary       // 120000.0
let isRemote = person.job.remote     // true
let startDate = person.job.startDate // Date对象

// 🌟 嵌套访问也完美工作
print(person.job.company)           // "苹果"
print(person.job.salary)            // 120000.0
print(person.job.remote)            // true
```

### 修改属性

CloudKitJSON提供多种修改属性的方式，从最简单到最灵活：

#### 方式1：使用Mutable代理（推荐用于SwiftData模型）

```swift
// ✅ 在SwiftData模型中使用mutable代理进行直接修改
@Model
class Person {
    var name: String
    var job: CloudKitJSON<JobModel>

    init(name: String, job: JobModel) {
        self.name = name
        self.job = CloudKitJSON(job)
    }
}

// 直接通过mutable代理修改属性
var person = Person(name: "张三", job: job)
person.job.mutable.company = "谷歌"      // 直接赋值！
person.job.mutable.salary = 150000        // 直接赋值！
person.job.mutable.remote = false         // 直接赋值！

// 读取仍然很简单
let company = person.job.company           // "谷歌"
let salary = person.job.salary             // 150000
```

#### 方式2：直接修改整个对象

```swift
// ✅ 直接修改整个对象
var fullJob = person.job.wrappedValue
fullJob.company = "微软"
fullJob.salary = 160000
person.job.wrappedValue = fullJob
```

### 最佳实践：便捷扩展

```swift
extension Person {
    // 提供最直观的API
    var jobCompany: String {
        get { job.company }
        set { job.mutable.company = newValue }  // 使用mutable代理
    }

    var jobSalary: Double {
        get { job.salary }
        set { job.mutable.salary = newValue }  // 使用mutable代理
    }

    var jobRemote: Bool {
        get { job.remote }
        set { job.mutable.remote = newValue }  // 使用mutable代理
    }
}

// 现在拥有了完美的API体验！
let person = Person(name: "张三", job: job)

print(person.jobCompany)      // "苹果"
print(person.jobSalary)       // 120000

person.jobCompany = "谷歌"    // 直接赋值！
person.jobSalary = 150000     // 直接赋值！
person.jobRemote = false       // 直接赋值！

print(person.jobCompany)      // "谷歌"
print(person.jobSalary)       // 150000
```

## 高级用法

### 处理复杂嵌套结构

```swift
struct Address: Codable {
    var street: String
    var city: String
    var zipCode: String
}

struct PersonWithAddress: Codable {
    var name: String
    var age: Int
    var address: Address
}

@Model
class Contact {
    var info: CloudKitJSON<PersonWithAddress>

    init(info: PersonWithAddress) {
        self.info = CloudKitJSON(info)
    }
}

// 使用漂亮的点语法访问嵌套属性
let contact = Contact(info: PersonWithAddress(
    name: "李四",
    age: 30,
    address: Address(street: "主街123号", city: "库比蒂诺", zipCode: "95014")
))

let name = contact.info.name                    // "李四"
let city = contact.info.address.city           // "库比蒂诺"
let street = contact.info.address.street       // "主街123号"

// 修改嵌套属性
contact.info = contact.info.setting(\.address.city, to: "旧金山")
```

### 处理数组和字典

```swift
@Model
class Project {
    var name: String
    var skills: CloudKitJSON<[String]>
    var metadata: CloudKitJSON<[String: Any]>

    init(name: String, skills: [String], metadata: [String: Any]) {
        self.name = name
        self.skills = CloudKitJSON(skills)
        self.metadata = CloudKitJSON(metadata)
    }
}

let project = Project(
    name: "移动应用",
    skills: ["Swift", "SwiftUI", "Combine"],
    metadata: ["version": 1.0, "priority": "high"]
)

// 直接访问数组元素
let skillList = project.skills.wrappedValue
let firstSkill = skillList.first  // "Swift"

// 直接访问字典值
let version = project.metadata.wrappedValue["version"] as? Double  // 1.0
```

### 原始数据访问

```swift
// 访问原始JSON数据
let jsonData = person.job.projectedValue
print("JSON数据大小: \(jsonData.count) 字节")

// 获取JSON字符串表示
if let jsonString = person.job.jsonString {
    print("JSON: \(jsonString)")
}

// 从JSON字符串初始化
if let newPersonJob = CloudKitJSON<JobModel>(jsonString: jsonString) {
    print("从JSON获取的公司: \(newPersonJob.company)")
}
```

## 性能

CloudKitJSON使用现代Swift模式进行了性能优化：

- **编码**：1000次操作约7ms
- **解码**：1000次缓存操作约3ms
- **内存高效**：不可变设计，最小开销
- **零拷贝访问**：直接属性访问，无中间拷贝

## API参考

### 属性包装器

```swift
@propertyWrapper
@dynamicMemberLookup
public struct CloudKitJSON<T: Codable>: Codable
```

### 初始化器

```swift
// 使用Codable对象初始化
public init(_ object: T)

// 使用包装值初始化（属性包装器语法）
public init(wrappedValue: T)

// 从原始数据初始化
public init(data: Data)

// 从JSON字符串初始化
public init?(jsonString: String)
```

### 属性

```swift
// 包装的Codable对象
public var wrappedValue: T { get set }

// 原始JSON数据访问
public var projectedValue: Data { get }

// JSON字符串表示
public var jsonString: String? { get }

// 用于直接读写的可变代理
public var mutable: MutableProxy<T>
```

### 方法

```swift
// 创建刷新实例
public func refreshed() -> CloudKitJSON<T>
```

### 动态成员查找

```swift
// 使用点语法的直接属性访问（只读）
public subscript<U>(dynamicMember keyPath: KeyPath<T, U>) -> U

// 用于直接读写的可变代理
public var mutable: MutableProxy<T>
```

### 可变代理

```swift
// 通过可变代理进行读写访问
public class MutableProxy<T: Codable>: @dynamicMemberLookup {
    public subscript<U>(dynamicMember keyPath: KeyPath<T, U>) -> U { get }
    public subscript<U>(dynamicMember keyPath: WritableKeyPath<T, U>) -> U { get set }
}
```

### 类型别名

```swift
// 为了更好的可读性
public typealias JSONField<T: Codable> = CloudKitJSON<T>
```

## 使用模式

### 推荐模式：便捷扩展

```swift
@Model
class UserProfile {
    var id: UUID
    var name: String
    var settings: CloudKitJSON<UserSettings>
    var preferences: CloudKitJSON<UserPreferences>

    init(id: UUID = UUID(), name: String, settings: UserSettings, preferences: UserPreferences) {
        self.id = id
        self.name = name
        self.settings = CloudKitJSON(settings)
        self.preferences = CloudKitJSON(preferences)
    }
}

// 添加便捷扩展
extension UserProfile {
    // 设置访问
    var theme: String {
        get { settings.theme }
        set { settings.mutable.theme = newValue }
    }

    var notificationsEnabled: Bool {
        get { settings.notificationsEnabled }
        set { settings.mutable.notificationsEnabled = newValue }
    }

    // 偏好访问
    var language: String {
        get { preferences.language }
        set { preferences.mutable.language = newValue }
    }

    var timezone: String {
        get { preferences.timezone }
        set { preferences.mutable.timezone = newValue }
    }
}

// 使用变得极其直观：
let profile = UserProfile(name: "张三",
                         settings: UserSettings(theme: "dark", notificationsEnabled: true),
                         preferences: UserPreferences(language: "zh", timezone: "Asia/Shanghai"))

print(profile.theme)                    // "dark"
print(profile.notificationsEnabled)     // true
profile.theme = "light"                 // 轻松修改
```

## 系统要求

- Swift 6.0+
- iOS 17+, macOS 14+, watchOS 10+, visionOS 1+
- Xcode 15+

## 示例

查看此仓库中的`Example.swift`文件，获取全面示例，展示：

- SwiftData模型的基础用法
- 复杂嵌套结构
- 数组和字典处理
- 性能优化技术
- 实际项目模式和最佳实践

## 贡献

欢迎贡献！请随时提交Pull Request。对于重大更改，请先开issue讨论您想要更改的内容。

## 许可证

CloudKitJSON使用MIT许可证。更多信息请参见[LICENSE](LICENSE)文件。

## 支持

如果您有任何问题或建议，请开[issue](https://github.com/your-username/CloudKitJSON/issues)。我们在这里帮助您！

---

**使用Swift 6和现代Swift最佳实践制作 ❤️**