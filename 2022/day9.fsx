open System.IO

let sample = Path.Combine(__SOURCE_DIRECTORY__, "./inputs/day9_s.txt")
            |> File.ReadAllLines

let input = Path.Combine(__SOURCE_DIRECTORY__, "./inputs/day9.txt")
            |> File.ReadAllLines

let parse (line:string) : char * int =
    let [|dir; n|] = line.Split()
    dir.Chars(0), int n

type Point = int * int
let add (a,b) (c,d) = (a+c, b+d)

let delta = function
    | 'U' -> (0,1)
    | 'D' -> (0,-1)
    | 'R' -> (1,0)
    | 'L' -> (-1,0)

let moveTail ((hx,hy):Point) ((tx,ty):Point) : Point =
    if max (abs (tx - hx)) (abs (ty - hy)) <= 1 then tx,ty
    else tx + compare hx tx, ty + compare hy ty

type State = {
    rope: List<Point>
    seen: Set<Point>
}

let rec move (s:State) ((dir, n): char * int) : State =
    let s = if n > 1 then move s (dir, n-1) else s
    let newHead = add (List.head s.rope) (delta dir)
    let newRope = List.scan moveTail newHead (List.tail s.rope)
    { rope = newRope; seen = Set.add (List.last newRope) s.seen }

let solve n moves =
    moves
    |> Seq.fold move {rope = List.replicate n (0,0); seen = Set.singleton (0,0)}
    |> (fun s -> s.seen.Count)
    
let p1 = input |> Seq.map parse |> solve 2
let p2 = input |> Seq.map parse |> solve 10
