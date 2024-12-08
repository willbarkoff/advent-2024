import Data.Function ((&))
import Data.Int (Int64)
import Text.Printf (printf)

type Line = (Int64, [Int64])

main :: IO ()
main = do
  content <- readFile "input.txt"
  let linesOfFile = lines content
  let processedLines = map processLine linesOfFile
  let matchingLines1 = filter (uncurry solutionExists) processedLines
  let part1Sum = foldl (\acc cv -> acc + fst cv) 0 matchingLines1
  let matchingLines2 = filter (uncurry solutionExists2) processedLines
  let part2Sum = foldl (\acc cv -> acc + fst cv) 0 matchingLines2
  printf "Part 1: %d\nPart 2: %d\n" part1Sum part2Sum

getFirstNumber :: String -> Int64
getFirstNumber str = takeWhile (/= ':') str & read

getNumberList :: String -> [Int64]
getNumberList str = dropWhile (/= ':') str & tail & words & map read

processLine :: String -> Line
processLine str = (getFirstNumber str, getNumberList str)

solutionExists :: Int64 -> [Int64] -> Bool
solutionExists a b = solutionExists' a (reverse b)
  where
    solutionExists' 0 [] = True
    solutionExists' _ [] = False
    solutionExists' target [h] = target == h
    solutionExists' target (h : t) = (target `mod` h == 0 && solutionExists' (target `quot` h) t) || (target > h && solutionExists' (target - h) t) || False

solutionExists2 :: Int64 -> [Int64] -> Bool
solutionExists2 a b = solutionExists' a (reverse b)
  where
    solutionExists' 0 [] = True
    solutionExists' _ [] = False
    solutionExists' target [h] = target == h
    solutionExists' target (h : t) =
      (target `mod` h == 0 && solutionExists' (target `quot` h) t)
        || (target > h && solutionExists' (target - h) t)
        || (t /= [] && target > h && (target - h) `mod` pow10 h == 0 && solutionExists' ((target - h) `quot` pow10 h) t)

pow10 :: Int64 -> Int64
pow10 n = 10 ^ log10 n

log10 :: Int64 -> Int64
log10 n
  | n <= 0 = 0
  | otherwise = 1 + log10 (n `quot` 10)