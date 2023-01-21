use itertools::Itertools;

#[allow(dead_code)]
const SAMPLE: &str = r#"
16,1,2,0,4,2,7,1,2,14
"#;

fn main() {
    let nums: Vec<i32> =
        // SAMPLE
        include_str!("../../input/day7")
            .lines()
            .filter(|l| !l.is_empty())
            .next().unwrap()
            .split(',')
            .map(|x| x.parse().unwrap())
            .collect();

    let p1 = {
        let mut vec = nums.clone();
        vec.sort();
        let n = vec.len() / 2; // n is even
        // println!("medians {:?}", (vec[n], vec[n-1]));
        let median = vec[n];
        vec.iter().map(|x| (x - median).abs()).sum::<i32>()
    };
    println!("p1 = {:?}", p1);

    let p2 = {
        let (mini, maxi) = nums.iter().minmax().into_option().unwrap();
        let dist = |x: i32, y:i32 | {
            let d = (x - y).abs();
            (d+1)*d/2
        };
        // this could be a binary search since the distance is convex
        let (_pos, cost) = (*mini..=*maxi).collect_vec().into_iter().map(|p| {
            (p, nums.iter().map(|y| dist(p, *y)).sum::<i32>())
        }).min_by_key(|(_, c)| *c).unwrap();
        cost
    };
    println!("p2 = {:?}", p2);
}
