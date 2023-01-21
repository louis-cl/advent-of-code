open System
open System.IO

let input =
    Path.Combine(__SOURCE_DIRECTORY__, "./inputs/day5.txt") |> File.ReadAllText

let stateAndMoves (text: string) =
    let s = text.Split("\n\n", 2) in (s[0], s[1])

let parseStateLine = Seq.chunkBySize 4 >> Seq.map (Seq.item 1)

let parseState (state: string) =
    state.Split("\n")
    |> Array.map (parseStateLine >> Seq.toArray)
    |> Array.transpose
    |> Array.map (Array.filter (fun c -> c >= 'A' && c <= 'Z'))

let parseMoves (moves: string) =
    moves.Split("\n", StringSplitOptions.RemoveEmptyEntries)
    |> Array.map (fun s ->
        s.Split([| "move "; " from "; " to " |], 3, StringSplitOptions.RemoveEmptyEntries)
        |> Array.map int
        |> (fun s -> (s[0], s[1], s[2])))

let parse text =
    let (state, moves) = stateAndMoves text
    (parseState state, parseMoves moves)

let move (v2: bool) (cols: char[][]) (n, src, dest) =
    let (taken, rem) = Array.splitAt n cols[src - 1]
    let res = Array.append (if v2 then taken else Array.rev taken) cols[dest - 1]

    cols
    |> Array.mapi (fun i old ->
        if i + 1 = src then rem
        elif i + 1 = dest then res
        else old)

let (state, moves) = parse input in

moves |> Array.fold (move false) state |> Array.map Array.head |> String,
moves |> Array.fold (move true) state |> Array.map Array.head |> String
