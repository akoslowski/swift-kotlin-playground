/**
 * Main function for console applications
 */
fun main() {
    println("Hello, World!")
}

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
    /**
     * Returns a formatted description of the person
     */
    fun getDescription(): String {
        return "$name is $age years old"
    }
}
