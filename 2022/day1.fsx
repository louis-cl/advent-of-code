open System.IO
let input = Path.Combine(__SOURCE_DIRECTORY__, "./inputs/day1.txt")
            |> File.ReadAllLines    
 
let parse s = match s with
              | "" -> None
              | x ->  Some (int x)
 
let rec chunk acc ll = match ll with
                       | None :: xs -> acc :: chunk [] xs
                       | Some x :: xs -> chunk (x :: acc) xs
                       | [] -> [acc]
 
let calories = input
            |> Array.map parse
            |> Array.toList
            |> chunk []
            |> List.map List.sum

let p1 = List.max calories
let p2 = calories
        |> List.sortDescending
        |> List.take 3
        |> List.sum
