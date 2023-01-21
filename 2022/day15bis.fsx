open System
open System.IO

let sample = Path.Combine(__SOURCE_DIRECTORY__, "./inputs/day15_s.txt")
            |> File.ReadAllLines

let input = Path.Combine(__SOURCE_DIRECTORY__, "./inputs/day15.txt")
            |> File.ReadAllLines

type Pos = int * int

let parse (line:string) =
    let s = line.Split([|"=";",";":"|], StringSplitOptions.None)
    (int s[1], int s[3]),(int s[5], int s[7])

let dist (a,b) (c,d) = abs (a-c) + abs (b-d)

let rangeAtY ((x,y):Pos) (r:int) (y2:int) =
    let rem = r - abs (y2 - y)
    if rem < 0 then None // too far
    else Some (x-rem,x+rem)

let rec disjoint = function
    | [] -> [] 
    | [x] -> [x]
    | (a,b) :: (c,d) :: rest ->
        if c > b+1 then (a,b) :: disjoint ((c,d) :: rest)
        elif b >= d then disjoint ((a,b) :: rest)
        else disjoint ((a,d) :: rest)

let rangesAtY sd y =
    sd
    |> Seq.choose (fun (s,r) -> rangeAtY s r y)
    |> Seq.sort
    |> (fun s -> disjoint (Seq.toList s))

let p1 input Y = 
    let SB = input |> Array.map parse
    let SD = SB |> Array.map (fun (s,b) -> (s, dist s b))
    let xmin, xmax = rangesAtY SD Y |> Seq.exactlyOne
    let used =
        SB
        |> Array.map (fun (s,b) -> [s;b]) |> Seq.concat
        |> Seq.distinct
        |> Seq.filter (fun (_,y) -> y = Y)
        |> Seq.length
    xmax - xmin + 1 - used

p1 sample 10 // 26
p1 input 2000000 // 5240818

let p2 input XY =
    let SB = input |> Array.map parse
    let SD = SB |> Array.map (fun (s,b) -> (s, dist s b))
    
    let emptySpotInY y =
        let range = rangesAtY SD y
        if range.Length = 1 then None
        elif range.Length > 2 then failwith "?"
        else Some (range[0] |> snd |> (+) 1, y)
        
    seq { 0..XY }
    |> Seq.choose emptySpotInY
    |> Seq.head
    |> (fun (x,y) -> int64 x * 4000000L + int64 y)

p2 sample 20 // 56000011L
p2 input 4000000 // 13213086906101L
