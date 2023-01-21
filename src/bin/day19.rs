use std::collections::HashSet;
use std::fmt::{Debug, Formatter};
use itertools::Itertools;

#[derive(Eq, PartialEq, Hash, Copy, Clone)]
struct Point {
    x: i32,
    y: i32,
    z: i32
}

impl Debug for Point {
    fn fmt(&self, f: &mut Formatter<'_>) -> std::fmt::Result {
        write!(f, "({},{},{})", self.x, self.y, self.z)
    }
}

impl Point {
    fn new(x: i32, y: i32, z: i32) -> Self {
        Point { x, y, z}
    }
    fn dist(&self, p: &Self) -> u32 {
        ((self.x - p.x).abs() + (self.y - p.y).abs() + (self.z - p.z).abs()) as u32
    }
    fn minus(&self, p: &Self) -> Self {
        Point { x: self.x - p.x, y: self.y - p.y, z: self.z - p.z}
    }
}

type Scan = Vec<Point>;

fn parse(s: &str) -> Vec<Scan> {
    s.split("\n\n").map(|block| {
        block.lines().skip(1).map(|l| {
            let mut coords = l.splitn(3, ',')
                .map(|d| i32::from_str_radix(d, 10).unwrap());
            let mut c = || coords.next().unwrap();
            Point::new(c(), c(), c())
        }).collect()
    }).collect()
}

fn rotate([x,y,z]: [i32;3], rot: u8) -> [i32;3] {
    match rot {
        0  => [ x,  y,  z],
        1  => [ x,  z, -y],
        2  => [ x, -y, -z],
        3  => [ x, -z,  y],
        4  => [ y,  x, -z],
        5  => [ y,  z,  x],
        6  => [ y, -x,  z],
        7  => [ y, -z, -x],
        8  => [ z,  x,  y],
        9  => [ z,  y, -x],
        10 => [ z, -x, -y],
        11 => [ z, -y,  x],
        12 => [-x,  y, -z],
        13 => [-x,  z,  y],
        14 => [-x, -y,  z],
        15 => [-x, -z, -y],
        16 => [-y,  x,  z],
        17 => [-y,  z, -x],
        18 => [-y, -x, -z],
        19 => [-y, -z,  x],
        20 => [-z,  x, -y],
        21 => [-z,  y,  x],
        22 => [-z, -x,  y],
        23 => [-z, -y, -x],
        _ => unreachable!()
    }
}
fn transform(p: &Point, case: u8) -> Point {
    let [x,y,z] = rotate([p.x, p.y, p.z], case);
    Point { x, y, z}
}

// 2 scans that overlap
fn align(map: &HashSet<Point>, s: &Scan) -> Option<(Scan, Point)> {
    for t_case in 0..24 {
        let rotated = s.iter().map(|p| transform(p, t_case))
            .collect_vec();
        for delta in rotated.iter().cartesian_product(map)
            .map(|(a,b)| a.minus(b)) {
            let aligned = rotated.iter().map(|p| p.minus(&delta)).collect_vec();
            if aligned.iter().filter(|p| map.contains(p)).count() >= 12 {
                return Some((aligned, delta));
            }
        }
    }
    None
}

fn solve(scans: &Vec<Scan>) -> (usize, u32) {
    let mut map = HashSet::new();
    // scan 0 is assumed to be at (0,0,0)
    map.extend(scans[0].iter());
    let mut to_align: HashSet<_> = (1..scans.len()).collect();
    let mut positions = Vec::new();
    while !to_align.is_empty() {
        for &i in to_align.clone().iter() {
            if let Some((scan, pos)) = align(&map, &scans[i]) {
                println!("found scan for {}", i);
                map.extend(scan.iter());
                to_align.remove(&i);
                positions.push(pos);
            }
        }
    }
    let max_dist = positions.iter().tuple_combinations::<(&Point, &Point)>()
        .map(|(a,b)| a.dist(b))
        .max().unwrap();
    (map.len(), max_dist)
}

fn main() {
    let scans = parse(include_str!("../../input/day19"));
    let sol = solve(&scans);
    println!("sol = {:?}", sol);
}


#[cfg(test)]
mod tests {
    use indoc::indoc;
    use super::*;

    #[test]
    fn test_parse() {
        let s = indoc! {"
            --- scanner 0 ---
            1,2,3
            4,5,6

            --- scanner 1 ---
            -1,-2,-3
            -4,-5,-6
        "};
        assert_eq!(parse(s), vec![
            vec![Point::new(1,2,3), Point::new(4,5,6)],
            vec![Point::new(-1,-2,-3), Point::new(-4,-5,-6)],
        ]);
    }
}