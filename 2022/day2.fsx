open System.IO
let input = Path.Combine(__SOURCE_DIRECTORY__, "./inputs/day2.txt")
            |> File.ReadAllLines    
 

type Move = Rock | Paper | Scissor

let move1 (c: char) = [|Rock;Paper;Scissor|][(int c) - (int 'A')]
let move2 (c: char) = [|Rock;Paper;Scissor|][(int c) - (int 'X')]

let parse (s:string) = (move1 s[0], move2 s[2])
 
let moves = input
            |> Array.map parse
let value (m:Move) = match m with
                        | Rock -> 1
                        | Paper -> 2
                        | Scissor -> 3
// -1 if lose, 0 if draw, 1 if win
let compare (m1:Move) (m2:Move) =
    match (m1, m2) with
    | (x, y) when x = y -> 0
    | (Rock, Paper) | (Paper, Scissor) | (Scissor, Rock) -> 1
    | _ -> -1
    

let score (a,b) = (value b) + 3*(compare a b) + 3
let p1 = moves
        |> Array.map score
        |> Array.sum


type Result = Win | Lose | Draw
let plan (c: char) = [|Lose;Draw;Win|][(int c) - (int 'X')]

let parse2 (s:string) = (move1 s[0], plan s[2])
let resultValue r = match r with
                    | Lose -> 0
                    | Win -> 6
                    | Draw -> 3

let choiceValue a r = match r with
                        | Draw -> value a
                        | Win -> match a with
                                    | Rock -> value Paper
                                    | Paper -> value Scissor
                                    | Scissor -> value Rock
                        | Lose -> match a with
                                    | Rock -> value Scissor
                                    | Paper -> value Rock
                                    | Scissor -> value Paper
let score2 (a,b) = (resultValue b) + choiceValue a b

let p2 = input
        |> Array.map parse2
        |> Array.map score2
        |> Array.sum
