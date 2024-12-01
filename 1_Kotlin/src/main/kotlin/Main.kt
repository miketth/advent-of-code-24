package industries.disappointment

import java.io.File
import kotlin.math.abs

fun main() {
    val left = mutableListOf<Int>()
    val right = mutableListOf<Int>()

    File("input.txt").forEachLine { line ->
        val nums = line
            .split(" ")
            .filter { it.isNotBlank() }
            .map { it.toInt() }
        left += nums[0]
        right += nums[1]
    }

    left.sort()
    right.sort()

    val solution = left
        .zip(right)
        .sumOf { (left, right) -> abs(left - right) }

    println(solution)

}
