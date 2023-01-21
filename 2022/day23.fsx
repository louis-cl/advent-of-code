open System.IO

let sample = Path.Combine(__SOURCE_DIRECTORY__, "./inputs/day23_s.txt")
            |> File.ReadAllLines
let input = Path.Combine(__SOURCE_DIRECTORY__, "./inputs/day23.txt")
            |> File.ReadAllLines

type V2 = int * int

let parse (text:string[]) : Set<V2> =
    text
    |> Seq.mapi (fun i line ->
        line |> Seq.mapi (fun j char ->
            if char = '#' then Some (i,j)
            else None)
        |> Seq.choose id)
    |> Seq.concat
    |> Set.ofSeq


let none (s:seq<V2>) (m:Set<V2>) =
    s |> Seq.forall (fun x -> not <| Set.contains x m)

let around dx dy (x,y) =
    seq {
        for i in dx do
            for j in dy do
                let n = (x+i,y+j)
                if n <> (x,y) then yield n
    }

type Dir = N | S | W | E
let DIR = [|N;S;W;E|]

let look p = function
   | N -> around [-1] [-1;0;1] p
   | S -> around [1] [-1;0;1] p
   | W -> around [-1;0;1] [-1] p
   | E -> around [-1;0;1] [1] p

let move (x,y) = function
   | N -> (x-1, y)
   | S -> (x+1, y)
   | W -> (x, y-1)
   | E -> (x, y+1)

let next i (m:Set<V2>) (p:V2) =
    if none (around [-1;0;1] [-1;0;1] p) m then None
    else
        [0..3]
        |> Seq.choose (fun x ->
            let d = DIR[(x+i) % 4]
            if none (look p d) m
            then Some (move p d)
            else None)
        |> Seq.tryHead

let round i (m:Set<V2>) =
    let moves = m |> Set.map (fun p -> p, next i m p)
    let duplicated =
          moves
          |> Seq.choose snd
          |> Seq.groupBy id
          |> Seq.map (fun (k,l) -> k, Seq.length l)
          |> Seq.filter (fun (_,l) -> l >= 2)
          |> Seq.map fst
          |> Set.ofSeq
    moves
        |> Seq.map (fun (p,target) ->
            target
            |> Option.filter (fun t -> not(Set.contains t duplicated))
            |> Option.defaultValue p)
        |> Set.ofSeq
    
let bbox (m:Set<V2>) =
    m |> Seq.reduce (fun (x,y) (a,b) -> (min x a, min y b)),
    m |> Seq.reduce (fun (x,y) (a,b) -> (max x a, max y b))

let print g =
    let (minx,miny),(maxx,maxy) = bbox g
    for x in seq {minx..maxx} do
        for y in seq{miny..maxy} do
            printf (if Set.contains (x,y) g then "#" else ".")
        printf "\n"

let p1 input = 
    let map = input |> parse
    let final = seq {0..9} |> Seq.fold (fun m i -> round i m) map
    let (minx,miny),(maxx,maxy) = bbox final
    (maxx - minx + 1) * (maxy - miny + 1) - Set.count final

 // super slow version with = test
let p2 input =
    let map = input |> parse
    let rec rounds i m =
        let next = round i m
        if next = m then i+1
        else rounds (i+1) next
    rounds 0 map
