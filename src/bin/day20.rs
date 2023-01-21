use std::collections::HashMap;

type Coord = [i32; 2];

#[derive(Debug)]
struct Image {
    top_left: Coord,
    bottom_right: Coord,
    outside: bool,
    pixels: HashMap<Coord, bool>,
}

impl Image {
    fn window(&self, coord: Coord) -> usize {
        let [x, y] = coord;
        let mut res = 0;
        for i in -1..=1 {
            for j in -1..=1 {
                let p = if *self.pixels.get(&[x+i, y+j]).unwrap_or(&self.outside) { 1 } else { 0 };
                res = if i == -1 && j == -1 { p } else { (res << 1) | p }
            }
        }
        res
    }

    fn conv(&self, table: &Vec<bool>) -> Image {
        let [x,y] = self.top_left;
        let [xx, yy] = self.bottom_right;
        let mut pixels = HashMap::new();
        for i in x-1..=xx+1 {
            for j in y-1..=yy+1 {
                pixels.insert([i,j], table[self.window([i,j])]);
            }
        }
        Image {
            top_left: [x-1, y-1],
            bottom_right: [xx+1, yy+1],
            outside: table[if self.outside { table.len() - 1 } else { 0 }],
            pixels,
        }
    }
}

fn parse(s: &str) -> (Vec<bool>, Image) {
    let mut lines = s.lines();
    let table = lines.next().unwrap().chars().map(|c| c == '#').collect();
    let pixels: HashMap<Coord, bool> = lines.skip(1).enumerate()
        .map(|(i, l)| {
            l.chars().enumerate()
                .map(move |(j, c)| ([i as i32, j as i32], c == '#'))
        })
        .flatten()
        .collect();
    let top_left = [0, 0];
    let bottom_right = *pixels.iter().map(|(c, _)| c).max().unwrap();
    (table, Image { pixels, top_left, outside: false, bottom_right })
}

#[allow(dead_code)]
fn print(img: &Image) {
    let [x,y] = img.top_left;
    let [xx, yy] = img.bottom_right;
    for i in x..=xx {
        for j in y..=yy {
            print!("{}", if *img.pixels.get(&[i, j]).unwrap() { '#' } else { '.' })
        }
        println!();
    }
}

fn solve(img: &Image, table: &Vec<bool>, n: u32) -> usize {
    let mut r = img.conv(&table);
    for _ in 1..n {
        r = r.conv(&table);
    }
    r.pixels.values().filter(|&&b| b).count()
}


fn main() {
    let (table, img) = parse(include_str!("../../input/day20"));
    let sol = solve(&img, &table, 2);
    println!("sol = {:?}", sol);
    let sol2 = solve(&img, &table, 50);
    println!("sol = {:?}", sol2);
}


#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_sample() {
        let (table, img) = parse(include_str!("../../input/day20_sample"));
        assert_eq!(36, img.window([0,1]));
        assert_eq!(34, img.window([2,2]));
        // print(img.conv(&table).conv(&table));
        assert_eq!(35, solve(&img, &table, 2));
        assert_eq!(3351, solve(&img, &table, 50));
    }
}