open System.IO

let sample = Path.Combine(__SOURCE_DIRECTORY__, "./inputs/day8_s.txt")
            |> File.ReadAllLines

let input = Path.Combine(__SOURCE_DIRECTORY__, "./inputs/day8.txt")
            |> File.ReadAllLines

type Point = int * int            
type Grid = { n: int; data: Map<Point, int> }

let dirs = [(-1,0);(0,-1);(1,0);(0,1)] : Point list

let add (a,b) (c,d) = (a+c, b+d)

let parse (lines:string[]) =
    { n = Array.length lines;
      data = lines
        |> Seq.mapi (fun i line ->
            line |> Seq.mapi (fun j char -> (i, j), int char - int '0'))
        |> Seq.concat
        |> Map.ofSeq }

let edge (dir:Point) n =
    seq { 0..n-1 }
    |> Seq.map (
        match dir with
        | (1,0) -> fun i -> (0,i)
        | (-1,0) -> fun i -> (n-1,i)
        | (0,1) -> fun i -> (i,0)
        | (0,-1) -> fun i -> (i,n-1))

let rec visibleFrom (start:Point) (dir:Point) currentMaxHeight (g:Grid) : Point list =
    match Map.tryFind start g.data with
    | None -> []
    | Some height ->
        if height > currentMaxHeight then
            start :: visibleFrom (add start dir) dir height g
        else
            visibleFrom (add start dir) dir currentMaxHeight g

let visible (g:Grid) (dir:Point): seq<Point> =
    edge dir g.n
    |> Seq.map (fun e -> visibleFrom e dir -1 g)
    |> Seq.concat

let countVisible grid =
    dirs
    |> Seq.map (visible grid)
    |> Seq.concat
    |> Seq.distinct
    |> Seq.length

let viewDistance (p:Point) (dir:Point) (g:Grid) =
    let pHeight = Map.find p g.data
    p |> Seq.unfold (fun s ->
        let next = add s dir
        Map.tryFind next g.data |> Option.map (fun x -> x,next))
      |> Seq.fold (fun (t,over) h ->
            if over then t,over
            elif h < pHeight then t+1,over
            else t+1,true
          ) (0,false)
      |> fst

let score (p:Point) (g:Grid) =
    dirs
    |> Seq.map (fun d -> viewDistance p d g)
    |> Seq.reduce (*)
    
let maxScore (g:Grid) =
    Map.keys g.data
    |> Seq.map (fun p -> score p g)
    |> Seq.max
    
let g = parse sample in (countVisible g, maxScore g)
