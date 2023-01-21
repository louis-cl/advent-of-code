open System.IO
open System.Text.RegularExpressions

let sample =
    Path.Combine(__SOURCE_DIRECTORY__, "./inputs/day22_s.txt") |> File.ReadAllLines

let input =
    Path.Combine(__SOURCE_DIRECTORY__, "./inputs/day22.txt") |> File.ReadAllLines

type V2 = int * int

type Cell =
    | Open
    | Wall

let parseMap (lines: string[]) =
    lines
    |> Seq.mapi (fun i line ->
        line
        |> Seq.mapi (fun j c ->
            match c with
            | ' ' -> None
            | '#' -> Some((i, j), Wall)
            | '.' -> Some((i, j), Open))
        |> Seq.choose id)
    |> Seq.concat
    |> Map.ofSeq

type Move =
    | R
    | L
    | F of int

let parseInstr (line: string) =
    Regex.Matches(line, @"\d+|R|L")
    |> Seq.map (fun m ->
        match m.Value with
        | "R" -> R
        | "L" -> L
        | x -> F(int x))
    |> Seq.toList


let parse (text: string[]) =
    let map = text |> Array.takeWhile (fun l -> l.Length > 0)
    let instr = text[text.Length - 1]
    parseMap map, parseInstr instr

let ccw (a, b) = (-b, a)
let cw (a, b) = (b, -a)
let add (x, y) (a, b) = (x + a, y + b)
let neg (x, y) = (-x, -y)

let rec forward map (p, d) n =
    if n = 0 then
        (p, d)
    else
        let step = add p d

        match Map.tryFind step map with
        | Some Open -> forward map (step, d) (n - 1)
        | Some Wall -> (p, d)
        | None -> // wrap around
            let wrapped =
                Seq.last
                <| Seq.unfold
                    (fun p ->
                        let back = add p (neg d)
                        if Map.containsKey back map then Some(back, back) else None)
                    p

            forward map (wrapped, d) (n - 1)

let walk (map: Map<V2, Cell>) (p, d) =
    function
    | R -> (p, cw d)
    | L -> (p, ccw d)
    | F x -> forward map (p, d) x

let facing =
    function
    | (0, 1) -> 0 // right
    | (0, -1) -> 2 // left
    | (1, 0) -> 1 // down
    | (-1, 0) -> 3 // up

let p1 input =
    let map, inst = parse input
    let start = Map.minKeyValue map |> fst, (0, 1)
    let ((x, y), d) = inst |> List.fold (walk map) start
    1000 * (x + 1) + 4 * (y + 1) + facing d

type V3 =
    { x: int
      y: int
      z: int }

    static member Zero = { x = 0; y = 0; z = 0 }

    static member (*)(c, a: V3) =
        { x = a.x * c
          y = a.y * c
          z = a.z * c }

    static member (~-)(a: V3) = -1 * a

    static member (+)(a: V3, b: V3) =
        { x = a.x + b.x
          y = a.y + b.y
          z = a.z + b.z }

    static member (-)(a: V3, b: V3) = a + -b

    static member (.*)(a: V3, b: V3) =
        { x = a.y * b.z - b.y * a.z
          y = b.x * a.z - b.z * a.x
          z = a.x * b.y - b.x * a.y }

    static member (.@)(a: V3, b: V3) = a.x * b.x + a.y * b.y + a.z * b.z

// associate 2d point to a 3d face (position + normal vector)
// vi is aligned with (1,0) of 2d, vj is aligned with (0,1)
let embed S (m2: Set<V2>) p ((v, vi, vj): (V3 * V3 * V3)) (m3: Map<V3 * V3, V2 * V3>) =
    let embedFace p ((v, vi, vj): (V3 * V3 * V3)) m3 =
        let N = vi .* vj // normal of that face

        seq { // generate the face
            for i in 0 .. S - 1 do
                for j in 0 .. S - 1 do
                    let p2 = p |> add (i, j)
                    let v2 = v + i * vi + j * vj
                    (v2, N), (p2, vi)
        }
        |> Seq.fold (fun m (k, v) -> Map.add k v m) m3

    let rec explore p ((v, vi, vj): (V3 * V3 * V3)) m3 =
        let N = vi .* vj

        if Map.containsKey (v, N) m3 || not (Set.contains p m2) then
            m3
        else
            embedFace p (v, vi, vj) m3
            |> explore (p |> add (-S, 0)) (v - (S - 1) * N, N, vj) // top
            |> explore (p |> add (0, S)) (v + (S - 1) * vj, vi, -N) // right
            |> explore (p |> add (0, -S)) (v - (S - 1) * N, vi, N) // left
            |> explore (p |> add (S, 0)) (v + (S - 1) * vi, -N, vj) // down

    explore p (v, vi, vj) m3

let rec forward3 map ((p, N), d) n =
    if n = 0 then
        ((p, N), d)
    else
        let step = p + d, N

        match Map.tryFind step map with
        | Some Open -> forward3 map (step, d) (n - 1)
        | Some Wall -> ((p, N), d)
        | None -> // wrap around
            let wrapped = p, d

            match Map.find wrapped map with
            | Wall -> ((p, N), d)
            | Open -> forward3 map (wrapped, -N) (n - 1)

let walk3 (map: Map<V3 * V3, Cell>) ((p, N), d) =
    function
    | R -> ((p, N), d .* N)
    | L -> ((p, N), N .* d)
    | F x -> forward3 map ((p, N), d) x

let p2 input =
    let map, inst = parse input
    let start = Map.minKeyValue map |> fst
    let S = Map.count map |> (fun s -> s / 6) |> float |> sqrt |> int

    let embedding =
        embed
            S
            (map |> Map.toSeq |> Seq.map fst |> Set.ofSeq)
            start
            (V3.Zero, { x = 1; y = 0; z = 0 }, { x = 0; y = 1; z = 0 })
            Map.empty

    let (p3, d) =
        inst
        |> List.fold
            (walk3 (embedding |> Map.map (fun _ (v, _) -> map[v])))
            ((V3.Zero, { x = 0; y = 0; z = 1 }), { x = 0; y = 1; z = 0 })

    let (x, y), vi = embedding[p3]
    let _, N = p3
    let d = vi .@ d, (N .* vi) .@ d
    1000 * (x + 1) + 4 * (y + 1) + facing d
