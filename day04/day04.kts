import java.io.File
import java.io.InputStream

typealias SearchDirection = (i: Int, j: Int) -> Pair<Int, Int>

val searchUp: SearchDirection = { i, j -> Pair(i - 1, j) }
val searchDown: SearchDirection = { i, j -> Pair(i + 1, j) }
val searchLeft: SearchDirection = { i, j -> Pair(i, j - 1) }
val searchRight: SearchDirection = { i, j -> Pair(i, j + 1) }
val searchUpLeft: SearchDirection = { i, j -> Pair(i - 1, j - 1) }
val searchUpRight: SearchDirection = { i, j -> Pair(i - 1, j + 1) }
val searchDownLeft: SearchDirection = { i, j -> Pair(i + 1, j - 1) }
val searchDownRight: SearchDirection = { i, j -> Pair(i + 1, j + 1) }

val searchDirections =
    listOf(searchUp, searchDown, searchLeft, searchRight, searchUpLeft, searchUpRight, searchDownLeft, searchDownRight)

fun boundsAreValid(i: Int, j: Int, gridSize: Pair<Int, Int>): Boolean {
    val (iBound, jBound) = gridSize;
    return (i in 0..<iBound) && (j in 0..<jBound)
}

fun search(
    i: Int,
    j: Int,
    direction: SearchDirection,
    gridSize: Pair<Int, Int>,
    wordSearch: List<List<Char>>,
    searchPhrase: String,
    startAtChar: Int = 0
): Boolean {
    if (startAtChar == searchPhrase.length) {
        return true
    }

    if (!boundsAreValid(i, j, gridSize)) {
        return false
    }

    if (wordSearch[i][j] != searchPhrase[startAtChar]) {
        return false
    }

    val (newI, newJ) = direction(i, j)

    return search(newI, newJ, direction, gridSize, wordSearch, searchPhrase, startAtChar + 1) // tail call!
}


val inputStream: InputStream = File("input.txt").inputStream()
val wordSearch: MutableList<List<Char>> = mutableListOf()

inputStream.bufferedReader().forEachLine { wordSearch.add(it.toCharArray().asList()) }

val gridSize = Pair(wordSearch.size, wordSearch[0].size)

var answer = 0;

val part1SearchPhrase = "XMAS"

for (i in 0..<wordSearch.size) {
    val row = wordSearch[i]
    for (j in row.indices) {
        if (wordSearch[i][j] == part1SearchPhrase[0]) {
            answer += searchDirections.filter { search(i, j, it, gridSize, wordSearch, part1SearchPhrase) }.size
        }
    }
}

println("Part 1: $answer")

fun isMasX(i: Int, j: Int, gridSize: Pair<Int, Int>, wordSearch: List<List<Char>>): Boolean {
    val (maxI, maxJ) = gridSize;

    assert(i <= maxI - 3 && j <= maxJ - 3)

    val searchPhrase = "MAS"

    val searchResults = listOf(
        search(i, j, searchDownRight, gridSize, wordSearch, searchPhrase),
        search(i+2, j, searchUpRight, gridSize, wordSearch, searchPhrase),
        search(i, j+2, searchDownLeft, gridSize, wordSearch, searchPhrase),
        search(i+2, j+2, searchUpLeft, gridSize, wordSearch, searchPhrase)
    )

    return searchResults.filter { it }.size > 1
}

var answer2 = 0

for (i in 0..wordSearch.size-3) {
    val row = wordSearch[i]
    for (j in 0..row.size-3) {
        if (isMasX(i, j, gridSize, wordSearch)) {
            answer2 += 1
        }
    }
}

println("Part 2: $answer2")
