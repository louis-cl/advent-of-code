use std::fmt::{Debug, Display, Formatter};
use std::ops::{Index, IndexMut};
use std::str::FromStr;

type Cell = Option<u32>;
// store snail number as [vec<option<u32>; 4]
// snail[i][j] is the jth element of the ith level of the tree

#[derive(Debug)]
struct Snail {
    data: [Cell; 64]
}

impl Snail {
    fn new() -> Snail {
        Snail { data: [None; 64] }
    }
    fn print(&self, idx: Idx) -> Option<String> {
        if idx.0 > 4 { return None }
        match self[idx] {
            Some(v) => Some(v.to_string()),
            None => {
                self.print(left(idx))
                    .map(|ls| {
                        format!("[{},{}]", ls, self.print(right(idx)).unwrap())
                    })
            },
        }
    }
}

type Idx = (usize, usize);
impl Index<Idx> for Snail {
    type Output = Cell;
    fn index(&self, (level, rank): Idx) -> &Self::Output {
        &self.data[(1 << level) + rank]
    }
}
impl IndexMut<Idx> for Snail {
    fn index_mut(&mut self, (level, rank): Idx) -> &mut Self::Output {
        &mut self.data[(1 << level) + rank]
    }
}

fn left((level, rank): Idx) -> Idx {
    (level+1, 2*rank)
}
fn right((level, rank): Idx) -> Idx {
    (level+1, 2*rank+1)
}
fn parent((level, rank): Idx) -> Idx {
    (level-1, rank/2)
}

impl Display for Snail {
    fn fmt(&self, f: &mut Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.print((0,0)).unwrap())
    }
}

impl FromStr for Snail {
    type Err = ();
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let mut snail = Snail::new();
        let mut bytes = s.bytes();
        let mut idx = (0,0);
        while let Some(b) = bytes.next() {
            match b {
                b'[' => { idx = left(idx) }
                b']' => { idx = parent(idx) }
                b',' => { idx.1 += 1 },
                digit => snail[idx] = Some((digit - b'0') as u32)
            }
        }
        Ok(snail)
    }
}

fn parse(s: &str) -> Vec<Snail> {
    s.lines()
        .map(|l| l.trim())
        .filter(|l| !l.is_empty())
        .map(|l| Snail::from_str(l).unwrap())
        .collect()
}

fn main() {
    let nums = parse(include_str!("../../input/day18"));
    nums.iter().for_each(|n| println!("{}", n));
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_index() {
        let mut s = Snail::new();
        s[(1,0)] = Some(2);
        assert_eq!(s.data[2], Some(2));
    }

    #[test]
    fn test_parse() {
        let s = Snail::from_str("[1,2]").unwrap();
        assert_eq!(s.data[2], Some(1));
        assert_eq!(s.data[3], Some(2));
    }

    #[test]
    fn test_parse2() {
        let s = Snail::from_str("[[1,2],3]").unwrap();
        assert_eq!(s.data[3], Some(3));
        assert_eq!(s.data[4], Some(1));
        assert_eq!(s.data[5], Some(2));
    }

    #[test]
    fn test_parse_display() {
        let s = Snail::from_str("[[1,2],3]").unwrap();
        assert_eq!("[[1,2],3]", s.to_string());
    }

    #[test]
    fn test_parse_display_hard() {
        let s = Snail::from_str("[[[[2,2],7],[[9,2],[5,2]]],[4,[[8,9],9]]]").unwrap();
        assert_eq!("[[[[2,2],7],[[9,2],[5,2]]],[4,[[8,9],9]]]", s.to_string());
    }

}