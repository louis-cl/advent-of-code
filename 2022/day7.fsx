open System.IO

let sample = Path.Combine(__SOURCE_DIRECTORY__, "./inputs/day7_s.txt")
            |> File.ReadAllLines

let input = Path.Combine(__SOURCE_DIRECTORY__, "./inputs/day7.txt")
            |> File.ReadAllLines

type FileSystem = File of size:int | Dir of Map<string, FileSystem>

let (|Prefix|_|) (p:string) (s:string) =
    if s.StartsWith(p) then Some(s.Substring(p.Length)) else None


let rec add (part:FileSystem) (path:string list) (into:FileSystem) : FileSystem =
    match into with
    | File _ -> failwith "trying to add into a file"
    | Dir m ->
        match path with
        | [x] -> Dir (Map.add x part m)
        | x :: rest ->
            let fs = match Map.tryFind x m with
                     | Some fs -> fs
                     | None -> Dir Map.empty        
            let added = add part rest fs
            Dir (Map.add x added m)
            
let rec parse (lines:string list) (path:string list) (r:FileSystem) = 
    match lines with
    | [] -> r
    | "$ cd /" :: rest -> parse rest [] r
    | "$ cd .." :: rest -> parse rest (List.tail path) r
    | "$ ls" :: rest -> parseLs rest path r
    | (Prefix "$ cd " dir) :: rest -> parse rest (dir::path) r
    | _ -> failwith "unknown line"

and parseLs lines path r =
    match lines with
    | [] -> r
    | line :: rest ->
        match line with
        | Prefix "dir " name ->
            add (Dir Map.empty) (name::path |> List.rev) r
            |> parseLs rest path
        | Prefix "$" _ -> parse lines path r
        | file ->
            let [|size; name|] = file.Split(" ", 2)
            add (File (int size)) (name::path |> List.rev) r
            |> parseLs rest path

let rec dirSize name (acc:(string * int)list) (fs:FileSystem) =
    match fs with
    | File size -> acc, size
    | Dir m ->
        let accN, sizeN =
            Map.fold (fun (accS,sizeS) n v ->
            let accT,sizeT = dirSize n accS v
            accT, sizeS + sizeT
            ) (acc,0) m
        (name,sizeN)::accN, sizeN

let dirs, size =
    parse (Array.toList input) [] (Dir Map.empty)
    |> dirSize "/" []

let p1 =
    dirs
    |> List.map snd
    |> List.filter (fun s -> s <= 100000)
    |> List.sum

let p2 =
    let needed = 30000000 - (70000000 - size)
    dirs
    |> List.map snd
    |> List.sort
    |> List.find (fun s -> s >= needed)

