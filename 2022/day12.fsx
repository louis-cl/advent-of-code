open System.IO

let input = Path.Combine(__SOURCE_DIRECTORY__, "./inputs/day12.txt")
            |> File.ReadAllLines

let sample = Path.Combine(__SOURCE_DIRECTORY__, "./inputs/day12_s.txt")
            |> File.ReadAllLines

type Cell = Start | End | El of int
type Pos = int * int

let cell = function
    | 'S' -> Start
    | 'E' -> End
    | c -> El (int (c - 'a'))

let parse (text:string[]) : Map<Pos,Cell> =
    text
    |> Seq.mapi (fun i line ->
        line |> Seq.mapi (fun j char ->
            (i,j), cell char))
    |> Seq.concat
    |> Map.ofSeq

let add (x,y) (a,b) = (x+a, y+b)

let rec bfs (hMap:Map<Pos,int>) (goal:Pos) (visited:Set<Pos>) = function
        | [] -> None
        | (cost, pos) :: _ when pos = goal -> Some cost
        | (cost, pos) :: rest ->
            let h = Map.find pos hMap
            let neigh = [(1,0);(0,1);(-1,0);(0,-1)]
                       |> List.map (add pos)
                       |> List.filter (fun p ->
                           not (Set.contains p visited) &&
                           Map.tryFind p hMap
                           |> Option.filter (fun h2 -> h2 <= h+1)
                           |> Option.isSome)
            bfs hMap goal
                         (neigh |> Seq.fold (fun s p -> Set.add p s) visited)
                         (rest @ (neigh |> List.map (fun p -> (cost+1, p))))
                
let steps m =
    let startPos = Map.findKey (fun _ s -> s = Start) m

    
input
|> parse
|> steps

let minSteps m =
    let endPos = Map.findKey (fun _ s -> s = End) m
    let heightMap = Map.map (fun _ cell ->
                             match cell with
                             | Start -> 0 // a elevation
                             | End -> 25 // z elevation
                             | El h -> h) m
    heightMap
    |> Map.toSeq
    |> Seq.filter (fun (_,h) -> h = 0)
    |> Seq.map fst
    |> Seq.toList
    |> Seq.map (fun p -> bfs heightMap endPos Set.empty [(0,p)])
    |> Seq.choose id
    |> Seq.min

input
|> parse
|> minSteps
