open System.IO
let input = Path.Combine(__SOURCE_DIRECTORY__, "./inputs/day20.txt")
            |> File.ReadAllLines
            |> Array.map int
let sample = [|1;2;-3;3;-2;0;4|]

type Node = {
    value: int64
    li: int
    ri: int
}

let inline pmod i n = ((i % n) + n) % n

let build (input:int[]) : Node[] =
    let n = input.Length
    input
    |> Array.mapi (fun i x ->
        {value = x; li = pmod (i-1) n; ri = pmod (i+1) n})

let update arr i f = Array.set arr i (f arr[i])
   
let remove (nodes:Node[]) i =
    let node = nodes[i]
    update nodes node.ri (fun r -> {r with li = node.li})
    update nodes node.li (fun l -> {l with ri = node.ri})
    
let insertRight (nodes:Node[]) i left =
    let right = nodes[left].ri
    update nodes i (fun self -> {self with li = left; ri = right})
    update nodes left (fun l -> {l with ri=i})
    update nodes right (fun r -> {r with li=i})

let walk (nodes:Node[]) i n =
    let rec run i = function
        | 0L -> i
        | n when n > 0 -> run nodes[i].ri (n-1L)
        | n -> run nodes[i].li (n+1L)
    let n = pmod n (int64 (nodes.Length - 1)) // avoid loops
    run i n

let move (nodes:Node[]) i =
    let moves = nodes[i].value
    if moves <> 0 then
        remove nodes i
        let newLeft = walk nodes i nodes[i].value
        insertRight nodes i newLeft
    
let moveAll (nodes:Node[]) =
    for i in 0..nodes.Length-1 do
        move nodes i
    
let toList (nodes:Node[]) start  =
    let rec vals i = seq {
        yield nodes[i].value
        yield! vals nodes[i].ri
    }
    vals start |> Seq.take nodes.Length |> Seq.toList

let key (nodes:Node[]) =
    let values = nodes
               |> Array.findIndex (fun n -> n.value = 0) |> toList nodes
    [1000;2000;3000]
    |> Seq.map (fun i -> values[i % values.Length])
    |> Seq.sum

let p1 input = 
    let nodes = input |> build
    for i in 0..nodes.Length-1 do
        move nodes i
    key nodes


let p2 input =
    let nodes = input |> build |> Array.map (fun n -> {n with value = n.value * 811589153L})
    for i in 1..10 do
        for i in 0..nodes.Length-1 do
            move nodes i
    key nodes
