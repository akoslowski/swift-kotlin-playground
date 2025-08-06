import com.eygraber.uri.Url

/**
 * Returns a friendly greeting message from Kotlin Multiplatform
 * 
 * @return A greeting string
 */
fun greet(): String {
    return Url.parse("https://www.helloworld.com/your-name").host
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
}
