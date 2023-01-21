#[allow(dead_code)]
const SAMPLE: &str = r#"
5483143223
2745854711
5264556173
6141336146
6357385478
4167524645
2176841721
6882881134
4846848554
5283751526
"#;

type Map = Vec<Vec<u32>>;

#[allow(dead_code)]
fn print(map: &Map) {
    for l in map {
        println!("{:?}", l);
    }
    println!();
}

fn light(i: i32, j: i32, map: &mut Map) -> u32 {
    let mut flashes = 0;
    for ii in i-1..=i+1 {
        for jj in j-1..=j+1 {
            if ii < 0 || jj < 0 { continue };
            let x = ii as usize;
            let y= jj as usize;
            match map.get(x).and_then(|l| l.get(y)) {
                None => {}
                Some(&v) => {
                    if v >= 10 { /* only light once */
                    } else if v == 9 {
                        map[x][y] = 11; // mark
                        flashes += light(ii, jj, map) + 1;
                    } else {
                        map[x][y] += 1;
                    }

                }
            }
        }
    }
    flashes
}

fn step(map: &mut Map) -> u32 {
    let mut flashes = 0;
    map.iter_mut().flatten().for_each(|el| *el += 1);
    for i in 0..map.len() {
        for j in 0..map[0].len() {
            if map[i][j] == 10 {
                map[i][j] = 11; // mark
                flashes += light(i as i32, j as i32, map) + 1;
            }
        }
    }
    map.iter_mut().flatten().filter(|&&mut v| v == 11).for_each(|el| *el = 0);
    flashes
}

fn main() {
    let map: Map =
        // SAMPLE
        include_str!("../../input/day11")
            .lines()
            .filter(|l| !l.is_empty())
            .map(|l| l.chars().map(|c| c.to_digit(10).unwrap()).collect())
            .collect()
    ;

    let p1 = {
        let mut light_map = map.clone();
        let mut flashes = 0;
        for _ in 0..100 {
            flashes += step(&mut light_map);
        }
        flashes
    };
    println!("p1 = {:?}", p1);

    let p2 = {
        let mut light_map = map.clone();
        let want = (map.len() * map[0].len()) as u32;
        let mut i = 1;
        while step(&mut light_map) != want { i += 1 }
        i
    };
    println!("p2 = {:?}", p2);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test() {
        let map: Map = SAMPLE.lines()
            .filter(|l| !l.is_empty())
            .map(|l| l.chars().map(|c| c.to_digit(10).unwrap()).collect())
            .collect()
        ;

        let p1 = {
            let mut light_map = map.clone();
            let mut flashes = 0;
            for _ in 0..100 {
                flashes += step(&mut light_map);
            }
            flashes
        };
        assert_eq!(p1, 1656)
    }
}