open System.IO

let sample = Path.Combine(__SOURCE_DIRECTORY__, "./inputs/day14_s.txt")
            |> File.ReadAllLines

let input = Path.Combine(__SOURCE_DIRECTORY__, "./inputs/day14.txt")
            |> File.ReadAllLines

type Point = int * int
type Line = Point list

let parseLine (line:string) =
    line.Split(" -> ")
    |> Seq.map (fun s ->
        let [|x;y|] = s.Split(",", 2)
        (int x, int y))
    |> Seq.toList

let rec span (line: Line) : Point list =
    match line with
    | p1::p2::ps when p1 = p2 -> span (p2::ps)
    | (ax,ay)::(bx,by)::ps ->
        let next = (ax + sign(bx-ax), ay + sign(by-ay))
        (ax,ay) :: span (next::(bx,by)::ps)
    | x -> x

let rocks lines =
    lines
    |> Seq.map span
    |> Seq.concat
    |> Set.ofSeq

type Grid = {
    rock: Set<Point>
    sand: Set<Point>
}

let free g p = not (Set.contains p g.rock) && not (Set.contains p g.sand)
    
let rec path (g:Grid) (x,y as p:Point): seq<Point> =
    match seq { x,y+1 ; x-1,y+1 ; x+1,y+1 } |> Seq.tryFind (free g) with
    | None -> seq { p }
    | Some q -> seq { p; yield! path g q }
    
let p1 input =
    let rs = input |> Seq.map parseLine |> rocks
    let maxY = rs |> Set.toSeq |> Seq.map snd |> Seq.max
    let rec allSand (g:Grid) start : Grid =
        let ps = path g start
                  |> Seq.takeWhile (fun (_,y) -> y <= maxY)
        if Seq.isEmpty (ps |> Seq.pairwise) then failwith ("boom" + $"{ps}")
        else
        let p,q = ps |> Seq.pairwise |> Seq.last
        if snd q = maxY then g
        else allSand {g with sand = Set.add q g.sand} p    
    allSand {rock = rs; sand = Set.empty} (500,0)
    |> (fun g -> g.sand.Count)
    
p1 sample


let rec sand2 yLimit (g:Grid) ((x,y):Point): Point =
    let next = seq { x,y+1 ; x-1,y+1 ; x+1,y+1 }
               |> Seq.tryFind (fun (x,y) -> y < yLimit && free g (x,y))
    match next with
    | None -> (x,y)
    | Some p -> sand2 yLimit g p

let p2 input =
    let rs = input |> Seq.map parseLine |> rocks
    let yLimit = 2 + (rs |> Set.toSeq |> Seq.map snd |> Seq.max)
    let rec allSand (g:Grid) : Grid =
        match sand2 yLimit g (500,0) with
        | 500,0 -> g
        | p -> allSand {g with sand = Set.add p g.sand}
    allSand {rock = rs; sand = Set.empty}
    |> (fun g -> g.sand.Count + 1)

// 24957 to low
p2 sample

