import Foundation

let fileHandle = FileHandle(forReadingAtPath: "./input.txt")!
defer { try! fileHandle.close() }

let input = try! String(data: fileHandle.readToEnd()!, encoding: .utf8)!

// First, let's process the input into a grid of characters and a list of frequencies

var grid: [[Character]] = []
var antennaPositions: [Character:[(Int, Int)]] = [:]

for (i, line) in input.split(separator: "\n").enumerated() {
    for (j, char) in line.enumerated() {
        if (char != ".") {
            // we have a new antenna!
            if antennaPositions[char] != nil {
                antennaPositions[char]?.append((i, j))
            } else {
                antennaPositions[char] = [(i, j)]
            }
        }
    }
    grid.append(Array(line))
}

// hey, this is my first time writing Swift... I kinda love this language. It reminds me
// of a better python!

func isOnGrid(pos: (Int, Int)) -> Bool {
    let (i, j) = pos
    return i >= 0 && j >= 0 && i < grid.count && j < grid[0].count
}

func printGrid(grid: [[Character]]) {
    for row in grid {
        print(String(row))
    }
}

// part 1
var grid1: [[Character]] = grid.map { Array($0) }
var antinodesFound = 0
// this is O(hh shit) :(
for (_, positions) in antennaPositions {
    for (i1, j1) in positions {
        for (i2, j2) in positions {
            if (i1 == i2) && (j1 == j2) {continue}
            let (iDiff, jDiff) = (i1-i2, j1-j2)
            let newPos = (i1+iDiff, j1+jDiff)
            if isOnGrid(pos: newPos) && grid1[newPos.0][newPos.1] != "#" {
                grid1[newPos.0][newPos.1] = "#"
                antinodesFound += 1
            }
        }
    }
}

// printGrid(grid: grid1)
print("Part 1: \(antinodesFound)")

// part 2
// now even worse! O(h shit)
var resonantAntinodesFound = 0
var grid2: [[Character]] = grid.map { Array($0) }
for (_, positions) in antennaPositions {
    for (i1, j1) in positions {
        resonantAntinodesFound += 1;
        for (i2, j2) in positions {
            if (i1 == i2) && (j1 == j2) {continue}
            let (iDiff, jDiff) = (i1-i2, j1-j2)
            var newPos = (i1+iDiff, j1+jDiff)
            while (isOnGrid(pos: newPos)) {
                if grid2[newPos.0][newPos.1] == "." {
                    // we don't account for the antinodes themeselves here because
                    // that ruins the grid printing. That's handled above.
                    grid2[newPos.0][newPos.1] = "#"
                    resonantAntinodesFound += 1
                }
                newPos = (newPos.0 + iDiff, newPos.1 + jDiff)
            }
        }
    }
}

// printGrid(grid: grid2)
print("Part 2: \(resonantAntinodesFound)")
