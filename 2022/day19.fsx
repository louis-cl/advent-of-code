open System.IO
open System.Text.RegularExpressions
let sample = Path.Combine(__SOURCE_DIRECTORY__, "./inputs/day19_s.txt")
            |> File.ReadAllLines
            
let input = Path.Combine(__SOURCE_DIRECTORY__, "./inputs/day19.txt")
            |> File.ReadAllLines

// ore, clay, obsidian, geode
type Blueprint = {
    id: int
    cost: int[][] // 4x3
}

let parse (t:string) =
    Regex.Matches(t, @"\d+")
    |> Seq.map (fun m -> int m.Value)
    |> Seq.toArray
    |> (fun s -> {id = s[0]
                  cost = [|[|s[1]; 0; 0|]
                           [|s[2]; 0; 0|]
                           [|s[3]; s[4]; 0|]
                           [|s[5]; 0; s[6]|]|]})

type State = {
    money: int[] // 3
    robots: int[] // 3
}

let fmap f a b = Array.zip a b |> Array.map (fun (x,y) -> f x y)
let add = fmap (+)
let sub a b = fmap (-) b a
let times a c = Array.map ((*) c) a


let timeToBuild (cost:int[]) (s:State) =
    Array.zip3 cost s.money s.robots
    |> Seq.filter (fun (c,_,_) -> c > 0)
    |> Seq.map (fun (c,m,r) -> 
        if r = 0 then None // can't build this
        else
            let needed = max 0 (c - m)
            Some (needed / r + sign (needed % r)))
    |> Seq.reduce (Option.map2 max)

let maxGeodes n (b:Blueprint) =
    let upperBound time = time * (time - 1) / 2 // build a geode robot each step
    let maxRobots = b.cost |> Array.transpose |> Array.map (Array.reduce max) // not gonna need more
    let rec f lowerBound total time (s:State) =
        if lowerBound >= total + upperBound time then lowerBound
        else
            seq {3..-1..0}
            |> Seq.filter (fun i -> i = 3 || maxRobots[i] > s.robots[i])
            |> Seq.fold (fun lowerBound i ->
                 match timeToBuild (b.cost[i]) s with
                    | None -> lowerBound // inf time (missing some robots)
                    | Some t when t+1 >= time -> lowerBound // don't have enough time
                    | Some t ->
                       let geodes = if i = 3 then time - t - 1 else 0                   
                       let newState = {
                           robots = s.robots |> Array.mapi (fun j x -> if j=i then x+1 else x)
                           money =  s.money |> add (times s.robots (t+1)) |> sub b.cost[i]
                       }
                       f lowerBound (total+geodes) (time-t-1) newState)
                (max lowerBound total) // do nothing till end
        
    f 0 0 n {money = [|0;0;0|]; robots = [|1;0;0|] }


let p1 input = 
    input
    |> Seq.map parse
    |> Seq.map (fun b -> b.id * maxGeodes 24 b)
    |> Seq.sum

let p2 input =
    input
    |> Seq.map parse
    |> Seq.truncate 3
    |> Seq.map (maxGeodes 32)
    |> Seq.reduce (*)
