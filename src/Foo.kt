public data class Foo(
    public val name: String,
) {
    protected fun bar(x: Int): String {
        return "$name x $x"
    }
}
