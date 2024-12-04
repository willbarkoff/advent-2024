import * as fs from "fs/promises"

const main = async () => {

    const regex = /mul\((\d+),(\d+)\)/g
    const regex2 = /(mul|do|don't)\(((\d+),(\d+))?\)/g

    const file = await fs.readFile("./input.txt")
    const input = file.toString()

    const sum_of_products = [...input.matchAll(regex)].map(match => parseInt(match[1]) * parseInt(match[2])).reduce((a, b) => a + b, 0)
    console.log("part1:", sum_of_products)

    const result2 = [...input.matchAll(regex2)]
        .reduce((acc, cv) => {
            if (cv[1] == "do") return { ...acc, enabled: true }
            if (cv[1] == "don't") return { ...acc, enabled: false }
            if (cv[1] == "mul" && acc.enabled) {
                return {
                    ...acc,
                    sum: acc.sum + parseInt(cv[3]) * parseInt(cv[4])
                }
            }
            return acc
        }, { enabled: true, sum: 0 }).sum

    console.log("part2:", result2)
}

main()