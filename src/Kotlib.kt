/**
 * Returns a friendly greeting message from Kotlin Multiplatform
 * 
 * @return A greeting string
 */
fun greet(): String {
    return "Hello from Kotlin Multiplatform!"
}

/**
 * Calculates the sum of two integers
 * 
 * @param a The first integer
 * @param b The second integer
 * @return The sum of a and b
 */
fun calculate(a: Int, b: Int): Int {
    return a + b
}




/**
 * Data class demonstrating Swift interop
 */
data class Person(
    val name: String,
    val age: Int
) {

    @OptIn(kotlin.experimental.ExperimentalObjCName::class)

    /**
     * Returns a formatted description of the person
     */    
    @ObjCName(swiftName = "info")
    fun getDescription(): String {
        return "$name is $age years old"
    }

    @Throws(Exception::class)
    fun functionThrowsDeclaredException(){
        throw Exception("Oops!")
    }

    fun getList(): List<Int> {
        return listOf(1,2,3)
    }

    fun getArray(): Array<Int> {
        return arrayOf(1,2,3)
    }

    fun getMap(): Map<String, Int> {
        return mapOf("a" to 1, "b" to 2)
    }

    fun getSet(): Set<Int> {
        return setOf(1,1,2)
    }

    fun set(collection: List<Int>){
        println(collection)
    }
}
