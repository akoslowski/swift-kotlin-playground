import Testing

@testable import Kotlib

@Test func testExamples() {
    #expect(KotlibKt.greet() == "Hello from Kotlin Multiplatform!")
    #expect(KotlibKt.calculate(a: 12, b: 12) == 24)

    #expect(Person(name: "Alice", age: 30).info() == "Alice is 30 years old")

    #expect(Foo(name: "Alice") != Foo(name: "Bob"))

    let f = Foo(name: "Bob")

    let expectedArray: KotlinArray<KotlinInt> = .init(size: 3) { index in
        // index + 1 // Cannot convert value of type 'Int' to closure result type 'KotlinInt?'

        // index + KotlinInt(int: 1) // Referencing operator function '+' on 'FloatingPoint' requires that 'KotlinInt' conform to 'FloatingPoint'

        KotlinInt(value: index.int32Value + 1)
    }

    #expect(f.getArray() == expectedArray) // Expectation failed: (f.getArray() → kotlin.Array@1b80088) == (expectedArray → kotlin.Array@1b80058)
    // KotlinArray<Value> is not equatable when the Value is equatable

    #expect(f.getArray().get(index: 0) == expectedArray.get(index: 0))

    //#expect(f.getList() == expectedArray) // Binary operator '==' cannot be applied to operands of type '[KotlinInt]' and 'KotlinArray<KotlinInt>'
    #expect(f.getList() == [1, 2, 3])

    let map = f.getMap()

    let expectedMap: [String : KotlinInt] = ["a": 1, "b": 2]
    #expect(map == expectedMap)
    #expect(map["a"] == 1)
    #expect(map["b"] == 2)

    #expect(throws: Error.self) {
        do {
            try f.functionThrowsDeclaredException()
        } catch {
            print(error) // Error Domain=KotlinException Code=0 "Oops!" UserInfo={NSLocalizedDescription=Oops!, KotlinException=kotlin.Exception: Oops!, KotlinExceptionOrigin=}
            throw error
        }
    }

    // protected fun in kotlin
    #expect(f.bar(x: 2) == "Bob x 2")

    // #expect(f.getSet() == expectedArray) // Binary operator '==' cannot be applied to operands of type 'Set<KotlinInt>' and 'KotlinArray<KotlinInt>'

    #expect(f.getSet() == [1, 2])

    var str = ""
    f.withIncomingString { string in
        str = "### \(string) ###"
    }
    #expect(str == "### Hello from Kotlin! ###")

    let value = f.withReturningInt { 123 }
    #expect(value == 1123)
}
