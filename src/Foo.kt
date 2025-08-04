public data class Foo(
    public val name: String,
) {
    protected fun bar(x: Int): String {
        return "$name x $x"
    }

    @Throws(Exception::class)
    public fun functionThrowsDeclaredException(){
        throw Exception("Oops!")
    }

    // https://github.com/kotlin-hands-on/kotlin-swift-interopedia/blob/main/docs/overview/Collections.md

    public fun getList(): List<Int> {
        return listOf(1,2,3)
    }

    public fun getArray(): Array<Int> {
        return arrayOf(1,2,3)
    }

    public fun getMap(): Map<String, Int> {
        return mapOf("a" to 1, "b" to 2)
    }

    public fun getSet(): Set<Int> {
        return setOf(1,1,2)
    }

    public fun set(collection: List<Int>){
        println(collection)
    }

    public fun withLamda(block: (String) -> Unit) {
        block("Hello from Kotlin!")
    }

}
