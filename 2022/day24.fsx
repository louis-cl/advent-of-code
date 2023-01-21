open System.IO

let sample =
    Path.Combine(__SOURCE_DIRECTORY__, "./inputs/day24_s.txt") |> File.ReadAllLines

let input =
    Path.Combine(__SOURCE_DIRECTORY__, "./inputs/day24.txt") |> File.ReadAllLines

type V2 = int * int

type Dir =
    | Up
    | Right
    | Left
    | Down

type Valley =
    { size: V2
      bliz: Set<V2 * Dir>
      start: V2
      goal: V2 }

let parse (input: string[]) =
    let H = input.Length - 2
    let W = input[0].Length - 2
    let start = (-1, input[ 0 ].IndexOf(".") - 1)
    let goal = (H, input[ H + 1 ].IndexOf(".") - 1)

    let bliz =
        input
        |> Seq.skip 1
        |> Seq.mapi (fun x line ->
            line
            |> Seq.skip 1
            |> Seq.mapi (fun y c ->
                match c with
                | '>' -> Some((x, y), Right)
                | '<' -> Some((x, y), Left)
                | '^' -> Some((x, y), Up)
                | 'v' -> Some((x, y), Down)
                | _ -> None)
            |> Seq.choose id)
        |> Seq.concat
        |> Set.ofSeq

    { size = (W, H)
      goal = goal
      start = start
      bliz = bliz }

let dist (x, y) (a, b) = abs (x - a) + abs (y - b)

let pmod x n = (x % n + n) % n

let isFree (v: Valley) step (x, y) : bool =
    (x, y) = v.start
    || (x, y) = v.goal
    || let W, H = v.size in

       seq { // go in the past
           (x + step, y), Up
           (x - step, y), Down
           (x, y + step), Left
           (x, y - step), Right
       }
       |> Seq.map (fun ((x, y), d) -> (pmod x H, pmod y W), d)
       |> Seq.filter (fun b -> Set.contains b v.bliz)
       |> Seq.isEmpty

let inValley (v: Valley) (x, y) =
    (x, y) = v.goal
    || (x, y) = v.start
    || let (W, H) = v.size in
       (x >= 0 && x < H && y >= 0 && y < W)

let neighbors (v: Valley) step (x, y) =
    seq {
        (x, y)
        (x - 1, y)
        (x + 1, y)
        (x, y - 1)
        (x, y + 1)
    }
    |> Seq.filter (fun p -> inValley v p && isFree v step p)

let pathCost (v: Valley) startSteps start goal =
    let rec r (queue: Set<int * int * V2>) =
        let q = Set.minElement queue
        // printfn $"exploring {q}"
        let steps, _, current = q

        if current = goal then
            steps
        else
            let queue = Set.remove q queue
            let steps = steps + 1

            neighbors v steps current
            |> Seq.fold
                (fun queue p ->
                    // printfn $"trying to go to {p}"
                    queue |> Set.add (steps, (dist goal p), p))
                queue
            |> r

    r (Set.empty.Add((startSteps, dist start goal, start)))

let p1 input =
    let valley = parse input
    // neighbors valley 17 (3, 5)
    pathCost valley 0 valley.start valley.goal

let p2 input =
    let valley = parse input
    // neighbors valley 17 (3, 5)
    let g1 = pathCost valley 0 valley.start valley.goal
    let g2 = pathCost valley g1 valley.goal valley.start
    let g3 = pathCost valley g2 valley.start valley.goal
    g3
