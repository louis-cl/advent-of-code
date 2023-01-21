use itertools::Itertools;
use crate::State::{Complete, Corrupted, Incomplete};

#[allow(dead_code)]
const SAMPLE: &str = r#"
[({(<(())[]>[[{[]{<()<>>
[(()[<>])]({[<{<<[]>>(
{([(<{}[<>[]}>{[]{[(<()>
(((({<>}<{<{<>}{[]{[]{}
[[<[([]))<([[{}[[()]]]
[{[{({}]{}}([{[{{{}}([]
{<[[]]>}<{[{[{[]{()[[[]
[<(<(<(<{}))><([]([]()
<{([([[(<>()){}]>(<<{{
<{([{{}}[<[[[<>{}]]]>[]]
"#;

#[derive(Debug)]
enum State {
    Incomplete(Vec<char>),
    Corrupted(u32),
    Complete,
}

fn main() {
    let lines: Vec<_> =
        // SAMPLE
        include_str!("../../input/day10")
            .lines()
            .filter(|l| !l.is_empty())
            .collect()
    ;

    fn points(c: &char) -> u32 {
        match c {
            ')' => 3,
            ']' => 57,
            '}' => 1197,
            '>' => 25137,
            _ => panic!("wtf is {}", c)
        }
    }

    fn matching(o: &char, c: &char) -> bool {
        match (o,c) {
            ('(',')') | ('[',']') | ('{','}') | ('<','>') => true,
            _ => false
        }
    }

    let analysis = lines.iter().map(|line| {
        let mut stack = Vec::with_capacity(line.len());
        for c in line.chars() {
            match c {
                '('|'['|'{'|'<' => stack.push(c),
                ')'|']'|'}'|'>' => {
                    match stack.last() {
                        None => return Incomplete(stack),
                        Some(o) => {
                            if matching(o, &c) {
                                stack.pop();
                            } else {
                                return Corrupted(points(&c));
                            }
                        }
                    }
                },
                _ => panic!("unknown char")
            }
        }
        if stack.is_empty() {
            return Complete;
        }
        Incomplete(stack)
    }).collect_vec();

    let p1 = {
        analysis.iter().map(|s| match s {
            Corrupted(s) => *s,
            _ => 0
        }).sum::<u32>()
    };
    println!("p1 = {:?}", p1);

    let p2 = {
        let score2 = |c: &char| {
            match c {
                '(' => 1,
                '[' => 2,
                '{' => 3,
                '<' => 4,
                _ => panic!("? {}", c)
            }
        };
        let v = analysis.iter().filter_map(|s| match s {
            Incomplete(s) => {
                Some(s.iter().rev().fold(0u64, |acc, x| {
                    acc * 5 + score2(x)
                }))
            }
            _ => None
        }).sorted().collect_vec();
        v[v.len()/2]
    };
    println!("p2 = {:?}", p2);
}
