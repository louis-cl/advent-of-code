use std::collections::HashSet;
use std::fmt::{Debug, Formatter};
use itertools::Itertools;

type Point = [i32; 3];

fn parse(s: &str) -> Vec<Vec<Point>> {
    s.split("\n\n").map(|block| {
        block.lines().skip(1).map(|l| {
            let mut coords = l.splitn(3, ',')
                .map(|d| i32::from_str_radix(d, 10).unwrap());
            let mut c = || coords.next().unwrap();
            [c(), c(), c()]
        }).collect()
    }).collect()
}

fn rotate([x,y,z]: Point, rot: u8) -> Point {
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

fn main() {
    let scans = parse(include_str!("../../input/day19"));
    let sol = scans;
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
            vec![[1,2,3], [4,5,6]],
            vec![[-1,-2,-3], [-4,-5,-6]],
        ]);
    }
}