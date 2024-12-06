package main

import (
	"bufio"
	"fmt"
	"os"
	"slices"
	"strconv"
	"strings"
)

func parseIntList(input string) []int {
	list := []int{}
	for _, nStr := range strings.Split(input, ",") {
		n, err := strconv.Atoi(nStr)
		if err != nil {
			panic(err)
		}
		list = append(list, n)
	}
	return list
}

func main() {
	scanner := bufio.NewScanner(os.Stdin)

	mustBeBefore := make(map[int][]int)
	mustBeAfter := make(map[int][]int)

	for scanner.Scan() {
		line := scanner.Text()

		if len(line) == 0 {
			break
		}

		var a, b int

		fmt.Sscanf(line, "%d|%d", &a, &b)

		// a must be before b
		mustBeBefore[b] = append(mustBeBefore[b], a)
		mustBeAfter[a] = append(mustBeAfter[a], b)
	}

	pageLists := [][]int{}
	for scanner.Scan() {
		line := scanner.Text()

		if len(line) == 0 {
			break
		}

		pageLists = append(pageLists, parseIntList(line))
	}

	sortPages := func(a, b int) int {
		// negative number when a < b
		// a positive number when a > b
		// zero when a == b
		if slices.Contains(mustBeAfter[b], a) {
			return 1
		} else if slices.Contains(mustBeAfter[a], b) {
			return -1
		}
		return 0
	}

	// Part 1
	answer1 := 0
	for _, list := range pageLists {
		if slices.IsSortedFunc(list, sortPages) {
			if len(list) % 2 != 1 {
				panic("List incorrect size.")
			}
			answer1 += list[len(list)/2]
		}
	}

	fmt.Printf("Part 1: %d\n", answer1)

	answer2 := 0
	for _, list := range pageLists {
		if !slices.IsSortedFunc(list, sortPages) {
			slices.SortFunc(list, sortPages)
			if len(list) % 2 != 1 {
				panic("List incorrect size.")
			}
			answer2 += list[len(list)/2]
		}
	}

	fmt.Printf("Part 2: %d\n", answer2)

}