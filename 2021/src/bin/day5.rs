use std::collections::HashMap;
use std::fmt::{Debug, Formatter};
use std::str::FromStr;

#[allow(dead_code)]
const SAMPLE: &str = r#"
0,9 -> 5,9
8,0 -> 0,8
9,4 -> 3,4
2,2 -> 2,1
7,0 -> 7,4
6,4 -> 2,0
0,9 -> 2,9
3,4 -> 1,4
0,0 -> 8,8
5,5 -> 8,2
"#;

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
struct Point {
    x: i32,
    y: i32
}

struct Line {
    from: Point,
    to: Point
}

impl FromStr for Line {
    type Err = ();

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let split: Vec<_> = s.split(|c| c == ',' || c == ' ').collect();
        Ok(Line {
            from: Point { x: split[0].parse().unwrap(), y: split[1].parse().unwrap() },
            to: Point { x: split[3].parse().unwrap(), y: split[4].parse().unwrap() }
        })
    }
}

impl Debug for Line {
    fn fmt(&self, f: &mut Formatter<'_>) -> std::fmt::Result {
        write!(f, "Line[{},{} -> {},{}]", self.from.x, self.from.y, self.to.x, self.to.y)
    }
}

impl Line {
    fn is_carthesian(&self) -> bool {
        self.from.x == self.to.x || self.from.y == self.to.y
    }

    fn points(&self) -> Vec<Point>{
        let d_x = (self.to.x - self.from.x).signum();
        let d_y = (self.to.y - self.from.y).signum();

        let mut current = self.from;
        let mut result = Vec::new();
        result.push(current);

        while current != self.to {
            current = Point { x: current.x + d_x, y: current.y + d_y};
            result.push(current);
        }
        result
    }
}


fn main() {
    let lines: Vec<_> =
        // SAMPLE
        include_str!("../../input/day5")
            .lines()
            .filter(|l| !l.is_empty())
            .map(Line::from_str)
            .map(|l| l.unwrap())
            .collect();

    let p1 = {
        let freqs = lines
            .iter()
            .filter(|line| line.is_carthesian())
            .map(|line| line.points())
            .flatten()
            .fold(HashMap::new(), |mut acc, x| {
                *acc.entry(x).or_insert(0) += 1;
                acc
            });
        freqs.iter()
            .filter(|&(_, v)| *v >= 2)
            .count()
    };
    println!("p1 = {:?}", p1);

    let p2 = {
        let freqs = lines
            .iter()
            .map(|line| line.points())
            .flatten()
            .fold(HashMap::new(), |mut acc, x| {
                *acc.entry(x).or_insert(0) += 1;
                acc
            });
        freqs.iter()
            .filter(|&(_, v)| *v >= 2)
            .count()
    };
    println!("p2 = {:?}", p2);
}
