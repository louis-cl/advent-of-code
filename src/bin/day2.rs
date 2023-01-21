use itertools::Itertools;
use crate::Command::{Down, Forward, Up};

#[derive(Debug)]
enum Command {
    Forward(i32),
    Down(i32),
    Up(i32)
}

fn main() {
    let lines: Vec<_> = include_str!("../../input/day2").lines().collect();

    let input: Vec<_> = lines.iter()
        .map(|line| {
            let (comm, amount) = line.split_once(" ").unwrap();
            let n = amount.parse().unwrap();
            match comm {
                "forward" => Forward(n),
                "up" => Up(n),
                "down" => Down(n),
                &_ => panic!()
            }
        }).collect();

    let p1 = {
        let (mut x, mut d) = (0, 0);
        for c in &input {
            match c {
                Forward(n) =>  x += n,
                Down(n) => d += n,
                Up(n) => d -= n
            }
        }
        x * d
    };
    println!("p1 = {:?}", p1);

    let p2 = {
        let (mut x, mut d, mut aim) = (0, 0, 0i32);
        for c in &input {
            match c {
                Forward(n) =>  {
                    x += n;
                    d += aim * n;
                },
                Down(n) => aim += n,
                Up(n) => aim -= n
            }
        }
        x * d
    };
    println!("p2 = {}", p2);
}
