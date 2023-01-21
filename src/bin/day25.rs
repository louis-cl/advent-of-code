use itertools::Itertools;
use crate::Cell::{Down, Empty, Right};

#[derive(Debug, Hash, Eq, Clone, PartialEq)]
enum Cell {
    Right,
    Down,
    Empty
}
type Map = Vec<Vec<Cell>>;

fn parse(s: &str) -> Map {
    s.lines().map(|l|
        l.chars().map(|c|
            match c {
                '.' => Empty,
                '>' => Right,
                'v' => Down,
                _ => panic!("unknown input")
            }).collect()
    ).collect()
}

fn part1(map: Map) -> usize {
    let height = map.len();
    let width = map[0].len();
    let mut m = map;
    let mut changed = true;
    let mut count = 0;
    let range = (0..height).cartesian_product(0..width);
    while changed {
        changed = false;
        let mut m2 = vec![vec![Empty; width]; height];
        for (i,j) in range.clone() {
            if m[i][j] == Right {
                let (ii, jj) = (i, (j + 1) % width);
                if m[ii][jj] == Empty {
                    changed = true;
                    m2[ii][jj] = Right;
                } else {
                    m2[i][j] = Right;
                }
            }
        }
        for (i,j) in range.clone() {
            if m[i][j] == Down {
                let (ii, jj) = ((i + 1) % height, j);
                if m[ii][jj] != Down && m2[ii][jj] != Right {
                    changed = true;
                    m2[ii][jj] = Down;
                } else {
                    m2[i][j] = Down;
                }
            }
        }
        m = m2;
        count += 1;
    }
    count
}


fn main() {
    println!("p1 = {:?}", {
        let m = parse(include_str!("../../input/day25"));
        part1(m)
    });
}

#[cfg(test)]
mod tests {
    use indoc::indoc;

    use super::*;

    #[test]
    fn test() {
        let m = parse(indoc! {"
            v...>>.vv>
            .vv>>.vv..
            >>.>v>...v
            >>v>>.>.v.
            v>v.vv.v..
            >.>>..v...
            .vv..>.>v.
            v.v..>>v.v
            ....v..v.>
        "});
        assert_eq!(58, part1(m));
    }

}