use std::collections::HashMap;

#[allow(dead_code)]
const SAMPLE: &str = r#"
3,4,3,1,2
"#;

/*
 fish(n, t) = # fish after t days starting with a timer of n
 fish(n, 0) = 1
 fish(0, t) = fish(6, t-1) + fish(8, t-1)
 fish(n, t) | n >= t = 1
 fish(n, t) | n <  t = fish(0, t-n)

  only cache fish(0, t) as fish(n,t) recur directly into fish(0, t) or 1
*/
fn fish(n: u32, t: u32, mem: &mut HashMap<u32, u64>) -> u64 {
    match (n, t) {
        (_, 0) => 1,
        (0, t) => {
            match mem.get(&t) {
                Some(val) => *val,
                None => {
                    let res = fish(6, t - 1, mem) + fish(8, t - 1, mem);
                    mem.insert(t, res);
                    res
                }
            }
        },
        (n, t) => if n >= t { 1 } else { fish(0, t-n, mem) }
    }
}

fn main() {
    let initial: Vec<u32> =
        // SAMPLE
        include_str!("../../input/day6")
            .lines()
            .filter(|l| !l.is_empty())
            .next().unwrap()
            .split(',')
            .map(|x| x.parse().unwrap())
            .collect();

    let mut fish_mem = HashMap::new();

    let p1 = {
        initial.iter().map(|n| fish(*n, 80, &mut fish_mem)).sum::<u64>()
    };
    println!("p1 = {:?}", p1);

    let p2 = {
        initial.iter().map(|n| fish(*n, 256, &mut fish_mem)).sum::<u64>()
    };
    println!("p2 = {:?}", p2);
}
