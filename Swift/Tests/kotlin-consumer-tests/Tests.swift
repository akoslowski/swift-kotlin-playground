import Testing

@testable import Kotlib

@Test func testExamples() {
    #expect(KotlibKt.greet() == "Hello from Kotlin Multiplatform!")
    #expect(KotlibKt.calculate(a: 12, b: 12) == 24)
    #expect(Person(name: "Alice", age: 30).getDescription() == "Alice is 30 years old")
    #expect(Foo(name: "Bob").name == "Bob")
    #expect(Foo(name: "Alice") != Foo(name: "Bob"))
}
