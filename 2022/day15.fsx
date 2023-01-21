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

let inRangeAtY ((x,y):Pos) (r:int) (y2:int) =
    let rem = r - abs (y2 - y)
    if rem < 0 then [] // too far
    else [x-rem..x+rem] |> List.map (fun xi -> xi,y2)

let p1 input Y = 
    let SB = input |> Array.map parse
    let occupied = SB |> Array.map (fun (s,b) -> [s;b]) |> Seq.concat |> Set.ofSeq
    SB
    |> Seq.map (fun (sensor,beacon) ->
        let range = dist sensor beacon
        inRangeAtY sensor range Y)
    |> Seq.concat
    |> Seq.distinct
    |> Seq.filter (fun p -> not (Set.contains p occupied))
    |> Seq.length

p1 sample 10 // 26
p1 input 2000000 // 5240818

// 7.8s * 4M is 361 days need more efficient
