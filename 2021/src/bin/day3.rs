use std::collections::HashSet;
use itertools::Itertools;

const SAMPLE: &str = r#"
00100
11110
10110
10111
10101
01111
00111
11100
10000
11001
00010
01010
"#;

fn read_test(input: &str) -> impl Iterator<Item=&str> {
    input.lines().filter(|line| !line.is_empty())
}

fn zeros_and_ones(chars: &Vec<Vec<char>>, i: usize) -> (usize, usize) {
    let one_count = chars.iter().map(|bin| bin[i])
        .filter(|c| *c == '1')
        .count();
    (chars.len() - one_count, one_count)
}

fn reducing(lines: Vec<Vec<char>>, rule: impl Fn(usize, usize) -> char) -> String {
    let mut options: HashSet<_> = lines.into_iter().collect();
    let mut i = 0;
    while options.len() > 1 {
        let groups = options.into_iter().into_group_map_by(|line| line[i]);
        let (z,o) = (groups[&'0'].len(), groups[&'1'].len());
        options = groups[&rule(z, o)].clone().into_iter().collect();
        i += 1;
    }
    options.into_iter().next().unwrap().into_iter().collect()
}

fn main() {
    // let lines: Vec<_> = include_str!("../../input/day3").lines().collect();
    let lines: Vec<Vec<char>> =
        // read_test(SAMPLE)
        include_str!("../../input/day3").lines()
        .map(|x| x.chars().collect())
        .collect();

    let p1 = {
        let gamma: String = (0..lines[0].len()).map(|i| {
            let (z, o) = zeros_and_ones(&lines, i);
            if o >= z { '1' } else { '0' }
        }).collect();

        let g = u32::from_str_radix(gamma.as_str(), 2).unwrap();
        let e = !g & ((1 << gamma.len()) - 1);

        println!("gamma = {:?}, epsilon = {:?}", g, e);
        g * e
    };
    println!("p1 = {:?}", p1);

    let p2 = {
        let o2= reducing(lines.clone(), |z, o| if o >= z { '1' } else { '0' });
        let co2 = reducing(lines, |z, o| if z <= o { '0' } else { '1' });
        println!("o2 = {}, co2 = {}", o2, co2);
        i32::from_str_radix(o2.as_str(), 2).unwrap() *
            i32::from_str_radix(co2.as_str(), 2).unwrap()
    };
    println!("p2 = {}", p2);
}
