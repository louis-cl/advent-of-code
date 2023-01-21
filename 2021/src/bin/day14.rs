use std::collections::HashMap;
use itertools::{Itertools, MinMaxResult};

type Pair = (char, char);
type Poly = HashMap<Pair, i64>;

fn step(poly: Poly, rules: &HashMap<Pair, char>) -> Poly {
    poly.into_iter().fold(HashMap::new(), |mut m, (p, v) | {
        match rules.get(&p) {
            None => { m.insert(p, v); }
            Some(&res) => {
                let (a,b) = p;
                *m.entry((a, res)).or_insert(0) += v;
                *m.entry((res, b)).or_insert(0) += v;
            }
        }
        m
    })
}

fn part(poly: Poly, rules: &HashMap<Pair, char>, poly_s: &str, n: u32) -> i64 {
    let mut res = poly;
    for _ in 0..n {
        res = step(res, &rules);
    }
    let freq = {
        let mut m = res.into_iter().fold(HashMap::new(), |mut m, ((a, b), v)| {
            *m.entry(a).or_insert(0) += v;
            *m.entry(b).or_insert(0) += v;
            m
        });
        *m.entry(poly_s.chars().next().unwrap()).or_default() += 1;
        *m.entry(poly_s.chars().last().unwrap()).or_default() += 1;
        m.iter_mut().for_each(|(_, v)| *v /= 2);
        m
    };
    let minimax = freq.iter().minmax_by_key(|(_, v)| **v);
    match minimax {
        MinMaxResult::MinMax((_, mini), (_, maxi)) => maxi - mini,
        _ => panic!("fail")
    }
}

fn solve(inp: &str) -> (i64, i64) {
    let (poly_s, rules_s) = inp.split_once("\n\n").unwrap();

    let poly = poly_s.chars().tuple_windows::<(char,char)>()
        .fold(HashMap::new(), |mut m, x| {
           *m.entry(x).or_insert(0) += 1;
            m
        });

    let rules = rules_s.lines().map(|l| {
        let (a, b) = l.split_once(" -> ").unwrap();
        (a.chars().collect_tuple::<(_,_)>().unwrap(),b.chars().next().unwrap())
    }).fold(HashMap::new(), |mut m, (k, v) | {
        m.insert(k, v);
        m
    });

    let p1 = {
        part(poly.clone(), &rules, &poly_s, 10)
    };

    let p2 = {
        part(poly, &rules, &poly_s, 40)
    };
    (p1,p2)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test() {
        let inp = r#"NNCB

CH -> B
HH -> N
CB -> H
NH -> C
HB -> C
HC -> B
HN -> C
NN -> C
BH -> H
NC -> B
NB -> B
BN -> B
BB -> N
BC -> B
CC -> N
CN -> C
"#;
        let (p1, p2) = solve(inp);
        assert_eq!(p1, 1588);
        assert_eq!(p2, 2188189693529);
    }
}

fn main() {
    let (p1, p2) = solve(include_str!("../../input/day14"));
    println!("p1 = {}", p1);
    println!("p2 = {}", p2);
}