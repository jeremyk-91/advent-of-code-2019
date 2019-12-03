import System.Environment
import Data.List

type WireInstruction = (Char, Int)
type Coordinate = (Int, Int)

-- Splits elements in a list based on a delimiter
splitOn :: (Eq a) => [a] -> a -> [[a]]
splitOn [] _ = []
splitOn list@(x:xs) a
  | x == a    = splitOn xs a
  | otherwise = head:(splitOn tail a)
    where (head, tail) = break (\x -> x == a) list

parseInt = read :: String -> Int

parseWireInstruction :: String -> WireInstruction
parseWireInstruction str = (x, parseInt y)
  where x:y = str

findWirePoints :: [WireInstruction] -> [Coordinate]
findWirePoints ws = trace ws 0 0

trace :: [WireInstruction] -> Int -> Int -> [Coordinate]
trace [] _ _ = []
trace (w:ws) x y = points ++ (trace ws x' y')
  where points = getPoints w x y
        (x', y') = last points

getPoints :: WireInstruction -> Int -> Int -> [Coordinate]
getPoints (dir, len) x y
  | dir == 'R' = [(x, y + t) | t <- offsets]
  | dir == 'L' = [(x, y - t) | t <- offsets]
  | dir == 'U' = [(x - t, y) | t <- offsets]
  | dir == 'D' = [(x + t, y) | t <- offsets]
  | otherwise  = error "Illegal direction in getPoints"
  where offsets = [1, 2..len]

-- Precondition: lists are sorted
sortedIntersection :: (Ord a) => [a] -> [a] -> [a]
sortedIntersection [] _ = []
sortedIntersection _ [] = []
sortedIntersection (x:xs) (y:ys)
  | x == y = x:(sortedIntersection xs ys)
  | x < y  = sortedIntersection xs (y:ys)
  | x > y  = sortedIntersection (x:xs) ys

manhattanDistance :: Coordinate -> Int
manhattanDistance (x, y) = abs x + abs y

main :: IO()
main = do
  input <- readFile "input-3"
  let wireInstructions = map (\x -> splitOn x ',') (lines input)
  let parsedInstructions = map (\x -> map (parseWireInstruction) x) wireInstructions
  let traces = map (sort . findWirePoints) parsedInstructions
  let intersections = sortedIntersection (traces!!0) (traces!!1)
  let answer = minimum (map manhattanDistance intersections)
  putStrLn (show answer)
