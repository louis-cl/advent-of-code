open System.IO

let input = Path.Combine(__SOURCE_DIRECTORY__, "./inputs/day6.txt")
            |> File.ReadAllText

let start (text:string) n =
    text
    |> Seq.windowed n
    |> Seq.findIndex (fun arr -> arr |> Seq.distinct |> Seq.length = n)
    |> (+) n

let p1 = start input 4
let p2 = start input 14
