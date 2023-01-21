open System
open System.IO

let sample = Path.Combine(__SOURCE_DIRECTORY__, "./inputs/day10_s.txt")
            |> File.ReadAllLines
let input = Path.Combine(__SOURCE_DIRECTORY__, "./inputs/day10.txt")
            |> File.ReadAllLines
            
type Instr = Noop | Addx of int

let parseLine (line:string) =
    match line.Split() with
    | [|_|] -> Noop
    | [|_; n|] -> Addx (int n)

let rec register x = function
    | [] -> []
    | Noop :: rest -> x :: register x rest
    | Addx n :: rest -> x :: x :: register (x+n) rest

let strength xs =
    xs |> List.mapi (fun i x ->
        if (i+1) % 40 = 20 then Some ((i+1) * x)
        else None)
       |> List.choose id

let xs = input
        |> Array.toList
        |> List.map parseLine
        |> register 1

xs |> strength |> List.sum
 
xs |> List.mapi (fun i x -> abs (x % 40 - i % 40) < 2)
   |> List.map (fun lit -> if lit then '#' else ' ')
   |> List.chunkBySize 40
   |> List.map (fun x -> String (List.toArray x))
