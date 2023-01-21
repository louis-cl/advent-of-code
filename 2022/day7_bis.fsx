open System.IO

let sample =
    Path.Combine(__SOURCE_DIRECTORY__, "./inputs/day7_s.txt") |> File.ReadAllLines

let input =
    Path.Combine(__SOURCE_DIRECTORY__, "./inputs/day7.txt") |> File.ReadAllLines

type Path = string list
type Files = Map<Path, int>

let (|Prefix|_|) (p: string) (s: string) =
    if s.StartsWith(p) then
        Some(s.Substring(p.Length))
    else
        None

let rec parse (cwd: Path) (fs: Files) lines =
    match lines with
    | [] -> fs
    | "$ cd /" :: r -> parse [] fs r
    | "$ cd .." :: r -> parse (List.tail cwd) fs r
    | "$ ls" :: r -> parseLs cwd fs r
    | (Prefix "$ cd " dir) :: r -> parse (dir :: cwd) fs r
    | _ -> failwith "weird line"

and parseLs cwd fs lines =
    sample |> Array.toList |> parse [] Map.empty
