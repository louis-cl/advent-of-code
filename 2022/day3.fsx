open System.IO

let sample = Path.Combine(__SOURCE_DIRECTORY__, "./inputs/day3_s.txt")
            |> File.ReadAllLines   

let input = Path.Combine(__SOURCE_DIRECTORY__, "./inputs/day3.txt")
            |> File.ReadAllLines
let value c =
    if c >= 'a' then int (c - 'a') + 1
    else int (c - 'A') + 27

let splitHalf (s:string) =
    let n = s.Length / 2
    s.Substring(0, n), s.Substring(n)

let p1 =
    input
    |> Seq.map (
            splitHalf
            >> (fun (a,b) -> [Set.ofSeq a; Set.ofSeq b])
            >> Set.intersectMany
            >> Seq.exactlyOne
            >> value
        )
    |> Seq.sum

let p2 =
    input
    |> Seq.chunkBySize 3
    |> Seq.map (
            (Array.map Set.ofSeq)
            >> Set.intersectMany
            >> Seq.exactlyOne
            >> value
    )
    |> Seq.sum
