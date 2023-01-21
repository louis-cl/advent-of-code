use itertools::Itertools;

fn main() {
    let nums: Vec<_> = include_str!("../../input/day1").lines()
        .map(|line| line.parse::<i32>().unwrap()).collect();

    let p1 = nums.windows(2)
        .filter(|x| x[0] < x[1])
        .count();
    println!("p1 = {:?}", p1);

    let p2 = nums.iter().tuple_windows()
        .map(|(x,y,z)| x + y + z)
        .tuple_windows()
        .filter(|(x,y)| x < y)
        .count();
    println!("p2 = {}", p2);
}
