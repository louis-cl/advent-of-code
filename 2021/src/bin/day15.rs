use std::cmp::Ordering;
use std::collections::{BinaryHeap, HashMap, HashSet};

#[derive(Copy, Clone, Eq, PartialEq)]
struct State {
    cost: i32,
    position: (i32, i32),
}

impl PartialOrd<Self> for State {
    fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
        Some(self.cmp(other))
    }
}

impl Ord for State {
    fn cmp(&self, other: &Self) -> Ordering {
        other.cost.cmp(&self.cost)
            .then_with(|| self.position.cmp(&other.position))
    }
}

fn shortest_path_cost(goal: (i32, i32), map: &HashMap<(i32, i32), i32>) -> i32 {
    let mut heap = BinaryHeap::new();
    let mut seen = HashSet::new();
    heap.push(State { cost: 0, position: (0,0)}); // cost of initial doesnt count
    while let Some(State { cost, position}) = heap.pop() {
        if seen.contains(&position) { continue }
        seen.insert(position);
        if position == goal {
            return cost;
        }
        let (x,y) = position;
        for new_pos in [(x+1,y), (x-1,y), (x,y+1), (x,y-1)] {
            match map.get(&new_pos) {
                Some(c) => {
                    heap.push(State { cost: cost + c, position: new_pos });
                }
                None => {}
            }
        }
    }
    panic!("fail")
}

fn cost2<'a>(pos: &'a (i32, i32), map: &'a HashMap<(i32, i32), i32>, map_size: (i32, i32))
    -> Option<i32> {
    let (x, y) = *pos;
    let (sx, sy) = (x / map_size.0, y / map_size.1);
    if x < 0 || y < 0 || sx >= 5 || sy >= 5 { return None } // out of map
    let m = (x % map_size.0, y % map_size.1);
    let shift = sx + sy;
    let cost = map.get(&m).unwrap() + shift;
    if cost > 9 { Some(cost - 9) }
    else { Some(cost) }
}

fn shortest_path_cost2(goal: (i32, i32), map: &HashMap<(i32, i32), i32>, map_size: (i32, i32)) -> i32 {
    let mut heap = BinaryHeap::new();
    let mut seen = HashSet::new();
    heap.push(State { cost: 0, position: (0,0)}); // cost of initial doesnt count
    while let Some(State { cost, position}) = heap.pop() {
        if seen.contains(&position) { continue }
        seen.insert(position);
        if position == goal {
            return cost;
        }
        let (x,y) = position;
        for new_pos in [(x+1,y), (x-1,y), (x,y+1), (x,y-1)] {
            match cost2(&new_pos, map, map_size) {
                Some(c) => {
                    heap.push(State { cost: cost + c, position: new_pos });
                }
                None => {}
            }
        }
    }
    panic!("fail")
}

fn solve(inp: &str) -> (i32, i32) {
    let map: HashMap<(i32,i32), i32> = inp.lines().enumerate()
        .map(|(i, l)| {
            let x = i as i32;
            l.chars().enumerate().map(move |(j, c)|
                ((x ,j as i32), c.to_digit(10).unwrap() as i32))
        }).flatten()
        .collect();

    let map_size = (
        map.iter().map(|x| x.0.0).max().unwrap()+1,
        map.iter().map(|x| x.0.1).max().unwrap()+1
    );

    let p1 = {
        let goal = (map_size.0 - 1, map_size.1 -1);
        shortest_path_cost(goal, &map)
    };

    let p2 = {
        let goal = (map_size.0 * 5 - 1, map_size.1 * 5 - 1);
        // hacky unit tests
        // println!("cost (0,10) = 2 {:?}", cost2(&(0,10), &map, map_size));
        // println!("cost (0,12) = 7 {:?}", cost2(&(0,12), &map, map_size));
        // println!("cost (11,11) = 5 {:?}", cost2(&(11,11), &map, map_size));
        // println!("cost (49,49) = 9 {:?}", cost2(&(49, 49), &map, map_size));
        // println!("cost (50,50) = None {:?}", cost2(&(50,50), &map, map_size));
        shortest_path_cost2(goal, &map, map_size)
    };
    (p1,p2)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test() {
        let inp = r#"1163751742
1381373672
2136511328
3694931569
7463417111
1319128137
1359912421
3125421639
1293138521
2311944581
"#;
        let (p1, p2) = solve(inp);
        assert_eq!(p1, 40);
        assert_eq!(p2, 315);
    }
}

fn main() {
    let (p1, p2) = solve(include_str!("../../input/day15"));
    println!("p1 = {}", p1);
    println!("p2 = {}", p2);
}