open System.IO
let input = Path.Combine(__SOURCE_DIRECTORY__, "./inputs/day13.txt")
            |> File.ReadAllLines
let sample = Path.Combine(__SOURCE_DIRECTORY__, "./inputs/day13_s.txt")
            |> File.ReadAllLines

type Packet = NumberPacket of int | ListPacket of Packet list

let parsePacket (line:string) =
    let rec pcsv (ll:char list) : Packet list * char list =
        let p,rest = pp ll
        match rest with
        | ',' :: rest ->
            let ps,rest = pcsv rest
            p :: ps, rest
        | _ -> [p], rest
    and pnum (ll:char list) (cur:int) : Packet * char list =
        match ll with
        | c :: rest when c >= '0' && c <= '9' -> pnum rest (cur*10 + int (c - '0'))
        | _ -> NumberPacket cur, ll
    and pp (ll:char list) : Packet * char list =
        match ll with
        | '[' :: ']' :: rest -> ListPacket [], rest
        | '[' :: rest ->
            let inside, rest = pcsv rest
            ListPacket inside, List.tail rest // consume ]
        | n -> pnum n 0
          
    pp (line.ToCharArray() |> Array.toList) |> fst


let parse (lines:string[]) =
    lines
    |> Array.chunkBySize 3
    |> Array.map (Array.take 2)
    |> Array.map (fun [|l;r|] -> parsePacket l, parsePacket r)

let rec isRightOrder = function
    | NumberPacket l, NumberPacket r when l = r -> None
    | NumberPacket l, NumberPacket r -> Some (l < r)
    | ListPacket l, ListPacket r ->
        let rec isListOrdered ll lr =
            match (ll, lr) with
            | ([],[]) -> None
            | ([],_) -> Some true
            | (_,[]) -> Some false
            | (x::xs,y::ys) -> isRightOrder (x,y) |> Option.orElse (isListOrdered xs ys)
        isListOrdered l r
    | (ListPacket _ as l), n -> isRightOrder (l, ListPacket [n])
    | n, (ListPacket _ as l) -> isRightOrder (ListPacket [n], l)

let p1 input =
    input
    |> parse
    |> Seq.mapi (fun i p -> (i+1, isRightOrder p))
    |> Seq.filter (fun (_,p) -> p = Some true)
    |> Seq.sumBy fst

let p2 input =
    let d1 = parsePacket "[[2]]"
    let d2 = parsePacket "[[6]]"
    let sorted =
        input
        |> parse
        |> Seq.map (fun (a,b) -> [a;b])
        |> Seq.concat
        |> Seq.append [d1; d2]
        |> Seq.sortWith (fun a b ->
                match isRightOrder (a,b) with
                | Some true -> -1
                | Some false -> 1
                | None -> failwith "?")
        |> Seq.toList
    let p1 = List.findIndex ((=) d1) sorted
    let p2 = List.findIndex ((=) d2) sorted
    (p1 + 1) * (p2 + 1)

(p1 input, p2 input)
