open System
open System.IO

let sample = Path.Combine(__SOURCE_DIRECTORY__, "./inputs/day21_s.txt")
            |> File.ReadAllLines
let input = Path.Combine(__SOURCE_DIRECTORY__, "./inputs/day21.txt")
            |> File.ReadAllLines

type Op = Add | Sub | Mul | Div
type Expr = Const of int64 | Binary of op:Op * left:string * right:string

let parse (line:string) =
    match line.Split([|":"; " "|], StringSplitOptions.RemoveEmptyEntries) with
    | [|lhs; rhs|] -> lhs, Const (int64 rhs)
    | [|lhs; l; "*"; r|] -> lhs, Binary (Mul,l,r)
    | [|lhs; l; "/"; r|] -> lhs, Binary (Div,l,r)
    | [|lhs; l; "+"; r|] -> lhs, Binary (Add,l,r)
    | [|lhs; l; "-"; r|] -> lhs, Binary (Sub,l,r)

let mathOp = function
    | Add -> (+)
    | Sub -> (-)
    | Mul -> (*)
    | Div -> (/)
    
// eval m var = m2 | m2[var] = Const 
let rec eval (rules:Map<string, Expr>) var : Map<string, Expr> =
    match rules[var] with
    | Const _ -> rules
    | Binary(op, left, right) ->
        let partial = eval rules left
        let (Const l) = Map.find left partial
        let (Const r) = eval partial right |> Map.find right
        let res = mathOp op l r 
        Map.add var (Const res) rules

let p1 input =
    input
    |> Array.map parse |> Map.ofArray
    |> (fun r -> eval r "root")
    |> Map.find "root"

type Expr2 = Unknown | Literal of int64 | Math of op:Op * l:Expr2 * r:Expr2

let rec resolve (rules:Map<string, Expr>) var : Expr2 =
    match rules[var] with
    | _ when var = "humn" -> Unknown
    | Const l -> Literal l
    | Binary(op, left, right) -> Math(op, resolve rules left, resolve rules right)

let rec eval2 (e:Expr2) : Expr2 =
    match e with
    | Literal _ | Unknown -> e
    | Math(op, left, right) ->
        match (eval2 left, eval2 right) with
        | (Literal l, Literal r) -> Literal (mathOp op l r)
        | (l, r) -> Math(op, l , r)

let rec solve (t:int64) = function
    | Unknown -> t
    | Math(Add, Literal l, other) | Math(Add, other, Literal l) -> solve (t-l) other
    | Math(Mul, Literal l, other) | Math(Mul, other, Literal l) -> solve (t/l) other
    | Math(Div, Literal l, other) -> solve (l/t) other
    | Math(Div, other, Literal l) -> solve (t*l) other
    | Math(Sub, Literal l, other) -> solve (l-t) other
    | Math(Sub, other, Literal l) -> solve (t+l) other
    
let p2 input = 
    let rules = input |> Array.map parse |> Map.ofArray
    let (Math (_, left, right)) = resolve rules "root"
    match (eval2 left, eval2 right) with
    | Literal target, other | other, Literal target -> solve target other
