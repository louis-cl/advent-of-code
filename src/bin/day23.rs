use std::cmp::Ordering;
use std::collections::{BinaryHeap, HashSet};

#[derive(Debug, Copy, Clone, Eq, PartialEq)]
struct State {
    cost: usize,
    rooms: [[char; 2]; 4],
    hallway: [char; 11],
}
// empty space is '.'

impl PartialOrd<Self> for State {
    fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
        Some(self.cmp(other))
    }
}
impl Ord for State {
    fn cmp(&self, other: &Self) -> Ordering {
        other.cost.cmp(&self.cost)
    }
}

fn is_goal(rooms: [[char; 2]; 4]) -> bool {
    for (i,&r) in rooms.iter().enumerate() {
        for c in r {
            if c == '.' || room_of(c) != i {
                return false;
            }
        }
    }
    true
}

fn room_of(c: char) -> usize {
    ((c as u8) - b'a') as usize
}

fn steps_move_to(start: usize, end: usize, hallway: [char; 11]) -> Option<usize> {
    let range = if end > start { start+1..end+1 } else { end..start };
    for i in range {
        if hallway[i] != '.' {
            return None
        }
    }
    Some((end as i32 - start as i32).abs() as usize)
}

fn steps_move_in(room: [char; 2]) -> Option<usize> {
    room.into_iter().enumerate().rev()
        .filter(|(_, c)| *c == '.')
        .next()
        .map(|(s, _)| s + 1)
}

fn cost_of(c: char) -> usize {
    10usize.pow(room_of(c) as u32)
}

fn room_entry(room_i: usize) -> usize {
    2*room_i + 2
}

fn shortest_cost(initial_rooms: [[char; 2]; 4]) -> usize {
    let mut heap = BinaryHeap::new();
    let mut seen = HashSet::new();

    heap.push(State {
        cost: 0,
        rooms: initial_rooms,
        hallway: ['.'; 11]
    });
    while let Some(State { cost, rooms, hallway }) = heap.pop() {
        // println!("cost {} for {:?},{:?}", cost, hallway, rooms);
        if seen.contains(&(rooms, hallway)) { continue }
        seen.insert((rooms, hallway));
        if is_goal(rooms) {
            return cost;
        }
        // move any pod in hallway to his room
        for (hall_i, &c) in hallway.iter().enumerate() {
            if c == '.' { continue }
            let room_i = room_of(c);
            if let Some(in_move) = steps_move_in(rooms[room_i]) {
                if let Some(s_move) = steps_move_to(hall_i, room_entry(room_i), hallway) {
                    // println!("take out {} from hall {}", c, hall_i);
                    let mut new_hallway = hallway.clone();
                    new_hallway[hall_i] = '.';
                    let mut new_rooms = rooms.clone();
                    assert_eq!(new_rooms[room_i][in_move-1], '.');
                    new_rooms[room_i][in_move-1] = c;
                    heap.push(State {
                        cost: cost + cost_of(c) * (s_move + in_move),
                        rooms: new_rooms,
                        hallway: new_hallway
                    })
                }
            }
        }
        // move any pod in room to hallway
        for (room_i, r) in rooms.into_iter().enumerate() {
            if r.iter().all(|&c| c == '.' || room_of(c) == room_i) {
                continue; // nothing to change in this room
            }
            // println!("free top of room {} = {:?}", room_i, r);
            // top element of the room
            let (i, c) = r.into_iter().enumerate().filter(|(_, c)| *c != '.').next().unwrap();
            // hallway pos where it can go
            for k in [0,1,3,5,7,9,10] { // not in front of room
                if let Some(s_move) = steps_move_to(room_entry(room_i), k, hallway) {
                    // println!("can go to hall = {}", k);
                    let mut new_hallway = hallway.clone();
                    new_hallway[k] = c; // occupy hallway
                    let mut new_rooms = rooms.clone();
                    assert_ne!(new_rooms[room_i][i], '.');
                    new_rooms[room_i][i] = '.'; // free the room
                    let new_cost = cost + cost_of(c) * (s_move + i+1);
                    // println!("=> new state {} {:?} {:?}", new_cost, new_hallway, new_rooms);
                    heap.push(State {
                        cost: new_cost,
                        rooms: new_rooms,
                        hallway: new_hallway
                    })
                }
            }
        }
    }
    panic!("unreacheable goal")
}


fn main() {
    println!("p1 = {:?}", {
        shortest_cost([['b','c'],['b','a'],['d','a'],['d','c']])
    });
    println!("p2 = {:?}", {

    });
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test() {
        let c = shortest_cost([['b','a'],['c','d'],['b','c'],['d','a']]);
        assert_eq!(12521, c);
    }
}