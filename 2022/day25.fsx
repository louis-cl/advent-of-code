open System
open System.IO

let sample =
    Path.Combine(__SOURCE_DIRECTORY__, "./inputs/day25_s.txt") |> File.ReadAllLines

let input =
    Path.Combine(__SOURCE_DIRECTORY__, "./inputs/day25.txt") |> File.ReadAllLines

let parse (s: string) =
    s.ToCharArray()
    |> Array.map (fun c ->
        match c with
        | '=' -> -2
        | '-' -> -1
        | _ -> int c - int '0')

let rec sum (a: int list) (b: int list) =
    match (a, b) with
    | x :: xs, y :: ys -> (x + y) :: sum xs ys
    | [], ys -> ys
    | xs, [] -> xs

let rec simplify carry (xs: int list) =
    match (carry, xs) with
    | (0, []) -> []
    | (c, []) -> simplify 0 [ c ]
    | (0, x :: xs) ->
        if x >= -2 && x <= 2 then
            x :: simplify 0 xs
        elif x > 2 then
            let q = x / 5
            let r = x % 5

            if r <= 2 then
                r :: simplify q xs
            else
                (r - 5) :: simplify (q + 1) xs
        else // x < -2
            let q = x / 5
            let r = x % 5

            if r >= -2 then
                r :: simplify q xs
            else
                (r + 5) :: simplify (q - 1) xs
    | (c, x :: xs) -> simplify 0 (x + c :: xs)


let digitToC =
    function
    | -2 -> '='
    | -1 -> '-'
    | x -> '0' + char x

let p sample =
    sample
    |> Array.map (parse >> Array.rev >> List.ofArray)
    |> Array.reduce sum
    |> simplify 0
    |> Seq.rev
    |> Seq.map digitToC
    |> Seq.toArray
    |> String
