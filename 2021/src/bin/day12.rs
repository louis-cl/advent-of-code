use std::collections::{HashMap, HashSet};

fn paths<'a>(x: &'a str,
             edges: &HashMap<&'a str, HashSet<&'a str>>,
             used: &mut HashSet<&'a str>,
             extra_time: bool) -> u32 {
    if x == "end" { return 1 }
    let mut use_extra = false;
    if used.contains(&x) {
        if !extra_time { return 0 }
        use_extra = true;
    }
    let is_small = x.chars().next().unwrap().is_lowercase();
    if is_small && !use_extra { used.insert(x); }
    let mut count = 0;
    for &end in edges.get(&x).unwrap() {
        count += paths(end, edges, used, extra_time && !use_extra);
    }
    if is_small && !use_extra { used.remove(x); }
    count
}

fn solve(inp: &str) -> (u32, u32) {
    let edges = inp.lines()
        .map(|l| l.trim())
        .filter(|l| !l.is_empty())
        .map(|l| l.split_once('-').unwrap())
        .fold(HashMap::new(), |mut m, (from, to)| {
            if from != "end" && to != "start" {
                m.entry(from).or_insert(HashSet::new()).insert(to);
            }
            if to != "end" && from != "start" {
                m.entry(to).or_insert(HashSet::new()).insert(from);
            }
            m
        });

    let p1 = {
        let mut used = HashSet::new(); // used small caves
        paths("start", &edges, &mut used, false)
    };
    let p2 = {
        let mut used = HashSet::new(); // used small caves
        paths("start", &edges, &mut used, true)
    };
    (p1,p2)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test() {
        let inp = r#"
            start-A
            start-b
            A-c
            A-b
            b-d
            A-end
            b-end
        "#;
        let (p1, p2) = solve(inp);
        assert_eq!(p1, 10);
        assert_eq!(p2, 36);
    }

    #[test]
    fn test1() {
        let inp = r#"
            dc-end
            HN-start
            start-kj
            dc-start
            dc-HN
            LN-dc
            HN-end
            kj-sa
            kj-HN
            kj-dc
        "#;
        let (p1, p2) = solve(inp);
        assert_eq!(p1, 19);
        assert_eq!(p2, 103);
    }

    #[test]
    fn test2() {
        let inp = r#"
            fs-end
            he-DX
            fs-he
            start-DX
            pj-DX
            end-zg
            zg-sl
            zg-pj
            pj-he
            RW-he
            fs-DX
            pj-RW
            zg-RW
            start-pj
            he-WI
            zg-he
            pj-fs
            start-RW
        "#;
        let (p1, p2) = solve(inp);
        assert_eq!(p1, 226);
        assert_eq!(p2, 3509);
    }
}

fn main() {
    let (p1, p2) = solve(include_str!("../../input/day12"));
    println!("p1 = {:?}", p1); // 440 is to low => 4304
    println!("p2 = {:?}", p2);
}