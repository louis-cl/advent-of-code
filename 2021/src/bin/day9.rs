use std::collections::{HashMap, HashSet};
use itertools::Itertools;

#[allow(dead_code)]
const SAMPLE: &str = r#"
2199943210
3987894921
9856789892
8767896789
9899965678
"#;

const DIRS: [(i32, i32); 4] = [(1, 0),(-1, 0),(0, 1),(0, -1)];

// stop at 9, guaranteed partition of basins
fn basin_size(((x,y), v): (&(i32, i32), &u32),
              map: &HashMap<(i32, i32), u32>,
              used: &mut HashSet<(i32, i32)>) -> i32 {
    let mut total = 1; // current point in basin
    used.insert((*x,*y));
    for (dx, dy) in DIRS {
        let p2 = (x + dx, y+dy);
        if used.contains(&p2) { continue }
        let p2_v = *map.get(&p2).unwrap_or(&9);
        if p2_v != 9 && p2_v > *v {
            total += basin_size((&p2, &p2_v), map, used);
        }
    }
    total
}

fn main() {
    let values: Vec<Vec<u32>> =
        // SAMPLE
        include_str!("../../input/day9")
            .lines()
            .filter(|l| !l.is_empty())
            .map(|l| l.chars().map(|c| c.to_digit(10).unwrap()).collect())
            .collect()
    ;

    let map = values.into_iter().enumerate()
        .map(|(i, v)|
            v.into_iter().enumerate().map(move |(j, e)| (i, j, e)))
        .flatten()
        .fold(HashMap::new(), |mut acc, (i, j, e)| {
            acc.insert((i as i32, j as i32), e);
            acc
        });

    let low_points: Vec<_> = map.iter()
        .filter(|((x,y),v)| {
            for (dx,dy) in DIRS {
                if map.get(&(x + dx, y + dy)).unwrap_or(&10) <= v {
                    return false;
                }
            }
            true
        }).collect();

    let p1 = {
        low_points.iter()
            .map(|((_,_), v)| *v+1)
            .sum::<u32>()
    };
    println!("p1 = {:?}", p1);

    let p2 = {
        let mut used = HashSet::new();
        low_points.into_iter().map(|p| -basin_size(p.clone(), &map, &mut used))
            .sorted()
            .take(3)
            .fold(1, |acc, x| acc * -x)
    };
    println!("p2 = {:?}", p2);
}
