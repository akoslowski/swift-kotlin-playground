import Kotlib

@main
struct kotlibconsumer {
    static func main() {
        print()
        dump(KotlibKt.greet())
        print()
        dump(KotlibKt.calculate(a: 12, b: 12))
        print()
        dump(Person(name: "Alice", age: 30))
    }
}
