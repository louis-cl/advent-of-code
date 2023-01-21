use std::cmp::max;
use std::collections::HashMap;
use itertools::Itertools;

#[derive(Debug)]
struct Result {
    score: [u32; 2],
    rolls: u32
}

fn next_pos(mut pos: u32, steps: u32) -> u32 {
    pos += steps % 10;
    if pos <= 10 { pos } else { pos - 10 }
}

fn play(mut pos: [u32; 2]) -> Result {
    let mut die = (1..=100).cycle().tuples::<(_, _, _)>()
        .map(|(a,b,c)| a+b+c);
    let mut rolls = 0;
    let mut turn = 0;
    let mut score = [0,0];

    while score.iter().all(|&s| s < 1000) {
        let roll = die.next().unwrap();
        rolls += 3;
        let next_p = next_pos(pos[turn], roll);
        score[turn] += next_p;
        pos[turn] = next_p;
        turn = 1 - turn;
    }
    Result { rolls, score }
}

fn part1(res: &Result) -> u32 {
    res.score.iter().filter(|&&a| a < 1000).next().unwrap() * res.rolls
}

type State = (u8, u8, u8, u8);
// m[(a,b,sa,sb)] = (wa, wb)
// from state of player a with score sa and player b with score sb
// player a wins wa times, and b wins wb times
// player a has turn
fn wins(state: State, m: &mut HashMap<State, (u64, u64)>) -> (u64, u64) {
    let (a,b,sa,sb) = state;
    // end case
    if sa >= 21 { (1, 0) }
    else if sb >= 21 { (0, 1) }
    // recursive case
    else {
        match m.get(&state) {
            Some(&r) => r, // known
            None => {
                let mut total = (0,0);
                for (die, freq) in [(3, 1), (4, 3), (5, 6), (6, 7), (7, 6), (8, 3), (9, 1)] {
                    let next_pos = next_pos(a as u32, die) as u8;
                    let next_state = (b, next_pos, sb, sa+next_pos);
                    let (wb, wa) = wins(next_state, m);
                    total.0 += wa * freq;
                    total.1 += wb * freq;
                }
                m.insert(state, total);
                total
            }
        }
    }
}

fn main() {
    let res = play([4, 10]);
    println!("p1 = {:?}", part1(&res));
    println!("p2 = {:?}", {
        let mut m = HashMap::new();
        let wins = wins((4,10,0,0), &mut m);
        max(wins.0, wins.1)
    })
}


#[cfg(test)]
mod tests {
    use std::cmp::max;
    use super::*;

    #[test]
    fn test_next() {
        assert_eq!(next_pos(4, 6), 10);
        assert_eq!(next_pos(6, 60), 6);
        assert_eq!(next_pos(4, 276), 10);
    }

    #[test]
    fn test_part1() {
        assert_eq!(part1(&play([4,8])), 739785);
    }

    #[test]
    fn test_part2() {
        let mut m = HashMap::new();
        let wins = wins((4,8,0,0), &mut m);
        assert_eq!(444356092776315, max(wins.0, wins.1));
    }
}