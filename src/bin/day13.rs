use std::collections::HashSet;
use std::str::FromStr;
use itertools::Itertools;

#[derive(Debug)]
enum Fold {
    X(i32),
    Y(i32)
}

fn fold_axis(e: i32, f: i32) -> i32 {
    f - (f - e).abs()
}

fn fold_once(coords: HashSet<(i32, i32)>, fold: &Fold) -> HashSet<(i32, i32)> {
    coords.into_iter().map(|(x, y)| {
        match fold {
            Fold::X(fx) => (fold_axis(x, *fx), y),
            Fold::Y(fy) => (x, fold_axis(y, *fy))
        }
    }).collect()
}

fn solve(inp: &str) -> (u32, String) {
    let (coords_in, folds_in) = inp.split_once("\n\n").unwrap();
    let coords: HashSet<_> = coords_in.lines()
        .map(|l| {
            let (x, y) = l.split_once(',').unwrap();
            (i32::from_str(x).unwrap(), i32::from_str(y).unwrap())
        }).collect();
    let folds = folds_in.lines()
        .map(|l| {
            let (left, right) = l.split_once('=').unwrap();
            match left {
                "fold along x" => Fold::X(right.parse().unwrap()),
                "fold along y" => Fold::Y(right.parse().unwrap()),
                _ => panic!("unknown fold expr")
            }
        }).collect_vec();

    let p1 = {
        let fold = folds.first().unwrap();
        let fold_res: HashSet<_> = fold_once(coords.clone(), fold);
        fold_res.len() as u32
    };

    let p2 = {
        let res = folds.iter().fold(coords, fold_once);
        let max_x = *res.iter().map(|(x,_)| x).max().unwrap();
        let max_y = *res.iter().map(|(_,y)| y).max().unwrap();
        let mut s = String::new();
        for y in 0..=max_y {
            for x in 0..=max_x {
                s.push(match res.get(&(x, y)) {
                    None => { '.'}
                    Some(_) => { '#' }
                });
            }
            s.push('\n');
        }
        s
    };
    (p1,p2)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test() {
        let inp = r#"6,10
0,14
9,10
0,3
10,4
4,11
6,0
6,12
4,1
0,13
10,12
3,4
3,0
8,4
1,10
2,14
8,10
9,0

fold along y=7
fold along x=5"#;
        let (p1, p2) = solve(inp);
        assert_eq!(p1, 17);
        println!("{}", p2);
    }
}

fn main() {
    let (p1, p2) = solve(include_str!("../../input/day13"));
    println!("p1 = {:?}", p1);
    println!("p2 = \n{}", p2);
}