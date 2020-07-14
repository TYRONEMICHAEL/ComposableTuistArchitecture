import ProjectDescription
let nameAttribute: Template.Attribute = .required("name")

let testContents = """
import Foundation
import XCTest

final class \(nameAttribute)Tests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func test_example() {
        // Add your test here
    }

}
"""

let template = Template(
    description: "Feature template",
    attributes: [
        nameAttribute,
        .optional("platform", default: "iOS")
    ],
    files: [
        .file(path: "\(nameAttribute)/Sources/\(nameAttribute).swift", templatePath: "main.stencil"),
        .string(path: "\(nameAttribute)/Tests/\(nameAttribute)Tests.swift", contents: testContents),
        .file(path: "\(nameAttribute)/Project.swift", templatePath: "project.stencil"),
    ]
)