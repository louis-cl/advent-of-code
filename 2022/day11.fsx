type Monkey = {
    items: int list
    op: int -> int
    next: int -> int
    passes: int
}

let divisible d n = n % d = 0
let nextdiv d a b n = if divisible d n then a else b
let sample =  [|
    { items = [79;98]
      op = (fun x -> x*19)
      next = nextdiv 23 2 3
      passes = 0}
    { items = [54;65;75;74]
      op = (fun x -> x+6)
      next = nextdiv 19 2 0
      passes = 0}
    { items = [79;60;97]
      op = (fun x -> x*x)
      next = nextdiv 13 1 3
      passes = 0}
    { items = [74]
      op = (fun x -> x+3)
      next = nextdiv 17 0 1
      passes = 0};
|]

let input =  [|
    { items = [50; 70; 89; 75; 66; 66]
      op = (fun x -> x*5)
      next = nextdiv 2 2 1
      passes = 0}
    { items = [85]
      op = (fun x -> x*x)
      next = nextdiv 7 3 6
      passes = 0}
    { items = [66; 51; 71; 76; 58; 55; 58; 60]
      op = (fun x -> x+1)
      next = nextdiv 13 1 3
      passes = 0}
    { items = [79; 52; 55; 51]
      op = (fun x -> x+6)
      next = nextdiv 3 6 4
      passes = 0}
    { items = [69; 92]
      op = (fun x -> x*17)
      next = nextdiv 19 7 5
      passes = 0}
    { items = [71; 76; 73; 98; 67; 79; 99]
      op = (fun x -> x+8)
      next = nextdiv 5 0 2
      passes = 0}
    { items = [82; 76; 69; 69; 57]
      op = (fun x -> x+7)
      next = nextdiv 11 7 4
      passes = 0}
    { items = [65; 79; 86]
      op = (fun x -> x+5)
      next = nextdiv 17 5 0
      passes = 0};
|]

// returns (nextMonkey, worryLevel)
let step (m:Monkey) : (int * int) list =
  m.items
  |> List.map (fun w ->
    let nextW = (m.op w) / 3
    m.next nextW, nextW)

let turn mi (monkeys:Monkey[]) : Monkey[] =
  let st = step monkeys[mi]
  let items = monkeys |> Array.map (fun m -> m.items)
  let newItems =
      (items, st) ||> List.fold (fun its (nm, w) ->
        let toSet = its[nm] @ [w]
        Array.updateAt nm toSet its)
  Array.zip monkeys newItems
  |> Array.mapi (fun i (m,items) ->
    if i = mi then {m with items = []; passes = m.passes + List.length st}
    else {m with items = items})

let round (monkeys:Monkey[]) : Monkey[] =
  (monkeys, {0..monkeys.Length-1}) ||> Seq.fold (fun mks i -> turn i mks) 


// 3472 too low, input error...
// 151312 right
{1..20}
|> Seq.fold (fun s _ -> round s) input
|> Seq.map (fun m -> m.passes)
|> Seq.sortDescending
|> Seq.take 2
|> Seq.reduce (*)
