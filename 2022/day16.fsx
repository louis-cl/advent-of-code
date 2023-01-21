open System.IO
open System.Text.RegularExpressions

let sample =
    Path.Combine(__SOURCE_DIRECTORY__, "./inputs/day16_s.txt") |> File.ReadAllLines

let input =
    Path.Combine(__SOURCE_DIRECTORY__, "./inputs/day16.txt") |> File.ReadAllLines

type Valve = { rate: int; next: string[] }
type Valves = Map<string, Valve>

let parse line : string * Valve =
    let m = Regex.Match(line, "Valve (..) has flow rate=(\d+);.* valves? (.*)$")
    let g (x: int) = m.Groups[x].Value

    g 1,
    { rate = int (g 2)
      next = (g 3).Split(", ") }


let dist (g: Map<string, Set<string>>) v1 v2 : int option =
    let rec bfs (visited: Set<string>) =
        function
        | [] -> None
        | (cost, name) :: _ when name = v2 -> Some cost
        | (cost, name) :: rest ->
            let nexts = Map.find name g |> (fun ns -> Set.difference ns visited)
            bfs (Set.union visited nexts) (rest @ (nexts |> Seq.map (fun n -> (cost + 1, n)) |> Seq.toList))

    bfs Set.empty [ (0, v1) ]

let reducedGraph valves =
    let nzValves =
        valves |> Map.toSeq |> Seq.filter (fun (_, v) -> v.rate > 0) |> Seq.map fst

    let nexts = valves |> Map.map (fun _ v -> Set.ofArray v.next)

    seq {
        yield "AA"
        yield! nzValves
    }
    |> Seq.map (fun v1 ->
        v1,
        nzValves
        |> Seq.filter ((<>) v1)
        |> Seq.choose (fun v2 -> dist nexts v1 v2 |> Option.map (fun d -> (v2, d)))
        |> Seq.toList)
    |> Map.ofSeq

let p1 input =
    let valves = input |> Array.map parse |> Map.ofArray
    let graph = reducedGraph valves

    let rec maxPressure v used press steps : int =
        // max over all nz reachable from v (with given steps) not already used
        let pressures =
            graph[v]
            |> Seq.filter (fun (v2, d) -> not (Set.contains v2 used) && d + 1 <= steps)
            |> Seq.map (fun (v2, d) ->
                let remSteps = steps - d - 1
                maxPressure v2 (Set.add v2 used) (press + remSteps * valves[v2].rate) remSteps)

        if Seq.isEmpty pressures then press else Seq.max pressures

    maxPressure "AA" Set.empty 0 30

let p2 input =
    let valves = input |> Array.map parse |> Map.ofArray
    let graph = reducedGraph valves

    let rec explore v used press steps paths : Map<Set<string>, int> =
        graph[v]
        |> Seq.filter (fun (v2, d) -> not (Set.contains v2 used) && d + 1 <= steps)
        |> Seq.fold
            (fun paths (v2, d) ->
                let remSteps = steps - d - 1
                let newPress = press + remSteps * valves[v2].rate
                explore v2 (Set.add v2 used) newPress remSteps paths)
            (paths // merge current path into max
             |> Map.change used (fun x ->
                 match x with
                 | Some current -> Some(max current press)
                 | None -> Some press))

    let ps = explore "AA" Set.empty 0 26 Map.empty |> Map.toSeq
    //find 2 non-overlapping ones
    seq {
        for (path1, press1) in ps do
            for (path2, press2) in ps do
                if Set.intersect path1 path2 |> Set.isEmpty then
                    yield press1 + press2
    }
    |> Seq.max



// p1 sample
// p1 input // 1580

// p2 sample
// p2 input // 2206 too low it's 2213
