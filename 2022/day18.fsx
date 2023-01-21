open System.IO

let sample = Path.Combine(__SOURCE_DIRECTORY__, "./inputs/day18_s.txt")
            |> File.ReadAllLines
let input = Path.Combine(__SOURCE_DIRECTORY__, "./inputs/day18.txt")
            |> File.ReadAllLines

type P = int * int * int

let parse (line:string) = line.Split(',') |> Array.map int |> (fun [|x;y;z|] -> x,y,z)

let add (x,y,z) (a,b,c) = (x+a, y+b, z+c)

let dirs = seq {(1,0,0);(0,1,0);(0,0,1);(-1,0,0);(0,-1,0);(0,0,-1)}

let surface cubes p =
     dirs
     |> Seq.map (add p)
     |> Seq.filter (fun q -> Set.contains q cubes |> not)
     |> Seq.length

let p1 input =
    let points = input |> Seq.map parse |> Set.ofSeq
    let surface p =
         dirs
         |> Seq.map (add p)
         |> Seq.filter (fun q -> Set.contains q points |> not)
         |> Seq.length
    points |> Seq.map surface |> Seq.sum

let fmap f (x,y,z) (a,b,c) = (f x a, f y b, f z c)

let boundingBox cubes =
    Seq.reduce (fmap min) cubes,
    Seq.reduce (fmap max) cubes

let p2 input =
    let points = input |> Seq.map parse |> Set.ofSeq
    let mini,maxi = points |> boundingBox |> (fun (a,b) -> add a (-1,-1,-1), add b (1,1,1))
    let inBox p = (fmap min p mini) = mini && (fmap max p maxi) = maxi
    
    let rec outPoints seen = function
        | [] -> seen
        | p :: ps ->
            let next =  dirs |> Seq.map (add p)
                      |> Seq.filter (fun x -> inBox x
                                              && Set.contains x seen |> not
                                              && Set.contains x points |> not)
                      |> Seq.toList
            outPoints (Set.union seen (Set.ofList next)) (ps @ next)
            
    let out = outPoints (Set.singleton mini) [mini]
    
    points
    |> Seq.map (fun p ->
        dirs |> Seq.map (add p)
        |> Seq.filter (fun q -> Set.contains q out)
        |> Seq.length)
    |> Seq.sum
