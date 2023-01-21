use std::collections::{HashMap, HashSet};
use std::str::FromStr;
use itertools::Itertools;

#[allow(dead_code)]
const SAMPLE: &str = r#"
be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | fdgacbe cefdb cefbgd gcbe
edbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec | fcgedb cgb dgebacf gc
fgaebd cg bdaec gdafb agbcfd gdcbef bgcad gfac gcb cdgabef | cg cg fdcagb cbg
fbegcd cbd adcefb dageb afcb bc aefdc ecdab fgdeca fcdbega | efabcd cedba gadfec cb
aecbfdg fbg gf bafeg dbefa fcge gcbea fcaegb dgceab fcbdga | gecf egdcabf bgf bfgea
fgeab ca afcebg bdacfeg cfaedg gcfdb baec bfadeg bafgc acf | gebdcfa ecba ca fadegcb
dbcfg fgd bdegcaf fgec aegbdf ecdfab fbedc dacgb gdcebf gf | cefg dcbef fcge gbcadfe
bdfegc cbegaf gecbf dfcage bdacg ed bedf ced adcbefg gebcd | ed bcgafe cdgba cbgef
egadfb cdbfeg cegd fecab cgb gbdefca cg fgcdab egfdb bfceg | gbdfcae bgc cg cgb
gcafb gcf dcaebfg ecagb gf abcdeg gaef cafbge fdbac fegbdc | fgae cfgab fg bagce
"#;

#[allow(dead_code)]
const SAMPLE2: &str = r#"
fbegcd cbd adcefb dageb afcb bc aefdc ecdab fgdeca fcdbega | efabcd cedba gadfec cb
"#;
type Trans = HashMap<String, char>;

fn intersect(a: &str, b: &str) -> usize {
    HashSet::<char>::from_iter(a.chars())
        .intersection(&HashSet::from_iter(b.chars()))
        .count()
}

// digits by count 2: 1, 3: 7, 4: 4, 5: (2,3,5), 6: (0,6,9), 7: 8
// we know 1,4,7,8
// 3 includes 1 in (2,3,5)
// 6 !includes 1 in (0,6,9)
// > need to diff (2,5) & (0,9)
// 9 includes 3 => we know 0
// > need to diff (2,5)
// 6 & 5 share 5 segments (6 & 2 share 4)
fn solve(unique: &Vec<String>) -> Trans {
    let mut res = Trans::new();
    let by_len = unique.iter()
        .fold(HashMap::new(), |mut m, x| {
            m.entry(x.len()).or_insert(Vec::new()).push(x);
            m
        });
    // 1, 4, 7, 8
    let mut a = HashMap::new();
    a.insert("hello", 2);
    let one = by_len[&2][0];
    res.insert(one.clone(), '1');
    res.insert(by_len[&4][0].clone(), '4');
    res.insert(by_len[&3][0].clone(), '7');
    res.insert(by_len[&7][0].clone(), '8');
    // 3 & 6
    let g3 = by_len.get(&5).unwrap();
    let three = g3.iter()
        .find(|s| intersect(s, one) == 2).unwrap().clone();
    res.insert(three.clone(), '3');
    // 6
    let g6 = by_len.get(&6).unwrap();
    let six = g6.iter()
        .find(|s| intersect(s, one) != 2).unwrap().clone();
    res.insert(six.clone(), '6');
    // 9
    let nine = g6.iter()
        .find(|s| intersect(s, three) == 5).unwrap().clone();
    res.insert(nine.clone(), '9');
    let zero = g6.iter().find(|s| s != &&nine && s != &&six).unwrap().clone();
    res.insert(zero.clone(), '0');
    // 5, 2 (3)
    g3.clone().into_iter().filter(|s| *s != three).for_each(|s| {
        if intersect(s, nine) == 5 { // 5
            res.insert(s.clone(), '5');
        } else {
            res.insert(s.clone(), '2');
        }
    });
    res
}

fn main() {
    let values: Vec<_> =
        // SAMPLE
        include_str!("../../input/day8")
            .lines()
            .filter(|l| !l.is_empty())
            .map(|l| {
                let (unique, output) = l.split_once('|').unwrap();
                (unique.split_whitespace().collect_vec(), output.split_whitespace().collect_vec())
            })
            .collect();

    let p1 = {
        // 1 is 2, 4 is 4, 7 is 3, 8 is 7
        values.iter().map(|(_, o)| o).flatten()
            .filter(|x| [2, 4, 3, 7].contains(&x.len()))
            .count()
    };
    println!("p1 = {:?}", p1);

    let p2 = {
        let repr = |a: &&str| a.chars().sorted().collect::<String>();
        values.iter()
            .map(|(u, o)| {
                (u.iter().map(repr).collect_vec(), o.iter().map(repr).collect_vec())
            })
            .map(|(u, o)| {
                let trans = solve(&u);
                o.iter().map(|so| trans.get(so).unwrap_or(&'?')).collect::<String>()
            })
            .map(|s| i32::from_str(&*s).unwrap())
            .sum::<i32>()
    };
    println!("p2 = {:?}", p2);
}
