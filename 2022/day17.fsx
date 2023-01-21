open System.IO
open Microsoft.FSharp.Collections

let sample = ">>><<><>><<<>><>>><<<>>><<<><<<>><>><<>>"
let input = Path.Combine(__SOURCE_DIRECTORY__, "./inputs/day17.txt")
            |> File.ReadAllLines
            |> Array.head

type Pos = int * int
type Shape = Horizontal | Plus | L | I | Square

let rec cycle xs = seq { yield! xs; yield! cycle xs}

let maxY sh : int = sh |> Set.toSeq |> Seq.map snd |> Seq.max

let print g =
    for y in seq {maxY g .. -1 .. 1} do
        for x in seq{0..6} do
            printf (if Set.contains (x,y) g then "#" else ".")
        printf "\n"

// shape relative (0,0) is bottom-left corner
let shape s =
    match s with
    | Horizontal -> [(0,0);(1,0);(2,0);(3,0)]
    | Plus -> [(0,1);(1,0);(1,1);(1,2);(2,1)]
    | L -> [(0,0);(1,0);(2,0);(2,1);(2,2)]
    | I -> [(0,0);(0,1);(0,2);(0,3)]
    | Square -> [(0,0);(0,1);(1,0);(1,1)]
    |> Set.ofList

let add (x,y) (a,b) = (x+a, y+b)

let translate p = Set.map (add p)

let out = Set.exists (fun (x,_) -> x < 0 || x >= 7)

let overlap sh grid = Set.intersect sh grid |> (not << Set.isEmpty)

let push grid dx sh =
    let pushed = sh |> translate (dx, 0)
    if out pushed || overlap pushed grid then sh
    else pushed

let down grid sh =
    let downed = sh |> translate (0, -1)
    if overlap downed grid then None
    else Some downed

let fallOne windOf (g, i, top) (shType:Shape) =
    let rec fall i sh =
        let pushed = push g (windOf i) sh
        match down g pushed with
        | None -> pushed, i+1
        | Some downed -> fall (i+1) downed
        
    let fallen, i = shape shType |> translate (2, top+4) |> fall i
    (Set.union g fallen, i, (max top (maxY fallen)))

let floor = seq { for i in 0..6 -> (i, 0)} |> Set.ofSeq

let windOf input =
    let wind = input |> Seq.map (function | c -> if c = '<' then -1 else 1) |> Seq.toArray
    fun i -> wind[i % wind.Length]

let p1 input =
    let _, _, top =
        cycle [Horizontal; Plus; L; I; Square]
        |> Seq.take 2022
        |> Seq.fold (fallOne (windOf input)) (floor, 0, 0)
    top

let relativeTop threshY g =
    g |> Set.filter (fun (_,y) -> y >= threshY)
      |> translate (0,-threshY) 

let p2 input =
    let windN = input |> Seq.length
    let windOf = windOf input
    let shape = [|Horizontal; Plus; L; I; Square|]
    
    let rec topHeight seen g windI shapeI top =
        let newG, newWindI, newTop = fallOne windOf (g, windI, top) (shape[shapeI % 5])
        
        let relativeTop10 = relativeTop (newTop - 10) newG
        let mark = (shapeI % 5, windI % windN, relativeTop10.GetHashCode())
        
        match Map.tryFind mark seen with
        | None -> topHeight (Map.add mark (shapeI, newTop) seen) newG newWindI (shapeI+1) newTop
        | Some (loopShapeI, loopTop) ->
            let rem = 1000000000000L - int64 shapeI - 1L // -1 cause shapeI is 0 indexed
            let period = int64 (shapeI - loopShapeI)
            let n = rem / period
            let rem = rem % period
            let _, _, _, endTop =
                seq {1..int rem}
                |> Seq.fold (fun (g,windI,shapeI,top) _ ->
                    let newG, newWindI, newTop = fallOne windOf (g, windI, top) (shape[shapeI % 5])
                    (newG, newWindI, shapeI+1, newTop)) (newG, newWindI, shapeI+1, newTop)
            int64 endTop + n * (int64 (newTop - loopTop))
        
    topHeight Map.empty floor 0 0 0
