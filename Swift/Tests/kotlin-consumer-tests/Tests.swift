import Testing
@testable import Kotlib

@Test func testExample() {
        #expect(KotlibKt.greet() == "Hello from Kotlin Multiplatform!")
        #expect(KotlibKt.calculate(a: 12, b: 12) == 24)
        #expect(Person(name: "Alice", age: 30).name == "Alice")
        #expect(Person(name: "Alice", age: 30).age == 30)
}