use std::collections::VecDeque;

#[allow(dead_code)]
const SAMPLE: &str = r#"
3,4,3,1,2
"#;

fn fish(mut counts: VecDeque<u64>, t: i32) -> u64{
    for _ in 0..t {
        counts.rotate_left(1);
        counts[6] += counts[8];
    }
    counts.iter().sum()
}

fn main() {
    let counts: [u64; 9] =
        // SAMPLE
        include_str!("../../input/day6")
            .lines()
            .filter(|l| !l.is_empty())
            .next().unwrap()
            .split(',')
            .map(|x| x.parse().unwrap())
            .fold([0u64; 9], |mut acc, x: usize| { acc[x] += 1; acc });

    let p1 = {
        fish(VecDeque::from(counts), 80)
    };
    println!("p1 = {:?}", p1);

    let p2 = {
        fish(VecDeque::from(counts), 256)
    };
    println!("p2 = {:?}", p2);
}
