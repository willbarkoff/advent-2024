import * as fs from "fs/promises"

const main = async () => {

    const file = await fs.readFile("./input.txt")
    const input = file.toString()

    const reports = input.split("\n").map(report => report.split(" ").map(number => parseInt(number)))

    const hasNoMistakes = (report: number[]) => {
        for (let measurement = 0; measurement < report.length; measurement++) {
            if (measurement == 0 || measurement == 1) continue;
            const diffAB = report[measurement - 2] - report[measurement - 1]
            const diffBC = report[measurement - 1] - report[measurement]

            if (Math.sign(diffAB) != Math.sign(diffBC)) return false
            if (Math.abs(diffAB) > 3 || Math.abs(diffBC) > 3) return false
            if (diffAB == 0 || diffBC == 0) return false
        }
        return true
    }

    console.log(reports.filter(hasNoMistakes).length)


    console.log(reports.filter(report => {
        if (hasNoMistakes(report)) {
            return true
        }

        for (let i = 0; i < report.length; i++) {
            if (hasNoMistakes(report.toSpliced(i, 1))) {
                return true
            }
        }

        return false
    }).length)

}

main()