open System.IO
let sample = Path.Combine(__SOURCE_DIRECTORY__, "./inputs/day4_s.txt")
            |> File.ReadAllLines   

let input = Path.Combine(__SOURCE_DIRECTORY__, "./inputs/day4.txt")
            |> File.ReadAllLines

let parse (s:string) =
    let [a;b;c;d] = [for x in s.Split(',') do
                     for y in x.Split('-') -> int y]
    ((a,b),(c,d))

let contains (a,b) (c,d) = c >= a && d <= b

let p1 =
    input
    |> Seq.map parse
    |> Seq.filter (fun (a,b) -> contains a b || contains b a)
    |> Seq.length

let overlaps (a,b) (c,d) = max a c <= min b d

let p2 =
    input
    |> Seq.map parse
    |> Seq.filter (fun (a,b) -> overlaps a b)
    |> Seq.length

