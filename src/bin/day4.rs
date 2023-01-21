use std::cmp::min;
use std::collections::HashMap;

const SAMPLE: &str = r#"7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1

22 13 17 11  0
 8  2 23  4 24
21  9 14 16  7
 6 10  3 18  5
 1 12 20 15 19

 3 15  0  2 22
 9 18 13 17  5
19  8  7 25 23
20 11 10 24  4
14 21 16 12  6

14 21 17 24  4
10 16 15  9 19
18  8 23 26 20
22 11 13  6  5
 2  0 12  3  7
"#;

fn main() {
    let mut blocks =
        // SAMPLE
        include_str!("../../input/day4")
        .split("\n\n");

    let numbers : Vec<u32> = blocks.next().unwrap().split(',')
        .map(|x| x.parse().unwrap())
        .collect();

    let boards : Vec<Vec<Vec<u32>>> = blocks.map(|block| {
        block.lines()
            .map(|line|
                line.split_whitespace()
                .map(|c| c.parse().unwrap())
                .collect())
            .collect()
    }).collect();

    let mut num_to_pos: HashMap<u32, _> = HashMap::new();
    for (i, n) in numbers.iter().enumerate() {
        num_to_pos.insert(*n, i);
    }

    // winning board is the board which has the minimum value across cols and rows
    // value for a row or column is the max pos
    let board_win_order: Vec<_> = boards.iter().map(|board| {
        let row_min = board.iter().map(|row| {
            row.iter().map(|d| num_to_pos[d]).max().unwrap()
        }).min().unwrap();
        let col_min = (0..5).map(|col_n| {
            board.iter().map(|row| &row[col_n])
                .map(|d| num_to_pos[d]).max().unwrap()
        }).min().unwrap();
        (board, min(row_min, col_min) as usize)
    }).collect();

    let score = |(board, win_index): &(&Vec<Vec<_>>, usize)| {
        let number_called = numbers[*win_index];
        let sum_unmarked: u32 = board.into_iter().flatten()
            .filter(|x| num_to_pos[x] > *win_index)
            .sum();
        number_called * sum_unmarked
    };

    let p1 = {
        let winning = board_win_order.iter()
            .min_by_key(|entry| entry.1).unwrap();
        score(winning)
    };
    println!("p1 = {:?}", p1);

    let p2 = {
        let losing = board_win_order.iter()
            .max_by_key(|entry| entry.1).unwrap();
        score(losing)
    };
    println!("p2 = {:?}", p2);
}
