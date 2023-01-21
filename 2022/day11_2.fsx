type Monkey = {
    items: int64 list
    op: int64 -> int64
    next: int64 -> int64
    passes: int64
}

let divisible (d:int64) (n:int64) = n % d = 0
let nextdiv (d:int64) (a:int64) (b:int64) (n:int64) = if divisible d n then a else b

let input =  [|
    { items = [50; 70; 89; 75; 66; 66]
      op = (fun x -> x*5L)
      next = nextdiv 2L 2L 1L
      passes = 0}
    { items = [85]
      op = (fun x -> x*x)
      next = nextdiv 7 3 6
      passes = 0}
    { items = [66; 51; 71; 76; 58; 55; 58; 60]
      op = (fun x -> x+1L)
      next = nextdiv 13 1 3
      passes = 0}
    { items = [79; 52; 55; 51]
      op = (fun x -> x+6L)
      next = nextdiv 3 6 4
      passes = 0}
    { items = [69; 92]
      op = (fun x -> x*17L)
      next = nextdiv 19 7 5
      passes = 0}
    { items = [71; 76; 73; 98; 67; 79; 99]
      op = (fun x -> x+8L)
      next = nextdiv 5 0 2
      passes = 0}
    { items = [82; 76; 69; 69; 57]
      op = (fun x -> x+7L)
      next = nextdiv 11 7 4
      passes = 0}
    { items = [65; 79; 86]
      op = (fun x -> x+5L)
      next = nextdiv 17 5 0
      passes = 0};
|]

// returns (nextMonkey, worryLevel)
let step (m:Monkey) : (int * int64) list =
  m.items
  |> List.map (fun w ->
    let nextW = (m.op w) % 9699690L // 2*7*13*3*19*5*11*17
    int (m.next nextW), nextW)

let turn mi (monkeys:Monkey[]) : Monkey[] =
  let st = step monkeys[mi]
  let items = monkeys |> Array.map (fun m -> m.items)
  let newItems =
      (items, st) ||> List.fold (fun its (nm, w) ->
        let toSet = its[nm] @ [w]
        Array.updateAt nm toSet its)
  Array.zip monkeys newItems
  |> Array.mapi (fun i (m,items) ->
    if i = mi then {m with items = []; passes = m.passes + int64 (List.length st)}
    else {m with items = items})

let round (monkeys:Monkey[]) : Monkey[] =
  (monkeys, {0..monkeys.Length-1}) ||> Seq.fold (fun mks i -> turn i mks) 


{1..10000}
|> Seq.fold (fun s _ -> round s) input
|> Seq.map (fun m -> m.passes)
|> Seq.sortDescending
|> Seq.take 2
|> Seq.reduce (*)
