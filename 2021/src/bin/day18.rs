use std::cmp::max;
use std::fmt::{Debug, Display, Formatter};
use std::str::FromStr;
use itertools::Itertools;
use crate::Node::{Nest, Value};

#[derive(Debug, PartialEq, Clone)]
enum Node {
    Value(u32),
    Nest(Box<Node>, Box<Node>)
}

impl FromStr for Node {
    type Err = ();
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        Ok(Node::from_bytes(&s.bytes().collect::<Vec<_>>()).1)
    }
}

impl Display for Node {
    fn fmt(&self, f: &mut Formatter<'_>) -> std::fmt::Result {
        match self {
            Value(v) => write!(f, "{}", v),
            Nest(l, r) => {
                write!(f, "[{},{}]", **l, **r)
            }
        }
    }
}

impl Node {
    fn from_bytes(bs: &[u8]) -> (usize, Node) {
        let mut i = 0;
        if bs[i] != b'[' { // number
            return (1, Node::Value((bs[i] - b'0') as u32));
        }
        i += 1;
        // nested
        let (n1, left) = Node::from_bytes(&bs[i..]);
        i += n1;

        assert_eq!(b',', bs[i]);
        i += 1; // read ,

        let (n2, right) = Node::from_bytes(&bs[i..]);
        i += n2;

        assert_eq!(b']', bs[i]);
        i += 1; // read ]
        (i, Node::Nest(Box::new(left), Box::new(right)))
    }

    fn add(self, right: Self) -> Self {
        Nest(Box::new(self), Box::new(right)).reduced()
    }

    fn reduced(self) -> Self {
        let mut done = false;
        let mut node = self;
        while !done {
            let (n2, changed) = node.explode().split();
            done = !changed; node = n2;
        }
        node
    }

    fn split(self) -> (Self, bool) {
        match self {
            Node::Value(v) => {
                if v >= 10 {
                    let h = v/2;
                    (Nest(Box::new(Node::Value(h)),
                          Box::new(Node::Value(v - h))), true)
                } else {
                    (self, false)
                }
            }
            Nest(l, r) => {
                let (nl, done) = l.split();
                if done {
                    return (Nest(Box::new(nl), r), true)
                }
                let (nr, done) = r.split();
                if done {
                    return (Nest(Box::new(nl), Box::new(nr)), true);
                }
                (Nest(Box::new(nl), Box::new(nr)), false)
            }
        }
    }

    fn explode(self) -> Self {
        self.p_explode(1, (0,0)).0
    }

    fn p_explode(self, depth: u32, (cl, cr): (u32, u32)) -> (Self, (u32, u32)) {
        match self {
            Value(v) => (Value(v + cl + cr), (0, 0)),
            Nest(l, r) => {
                if depth == 5 {
                    if let (Value(lv), Value(rv)) = (*l, *r) {
                        (Value(0), (lv+cl, rv+cr))
                    } else {
                        panic!("depth > 5");
                    }
                } else {
                    let (left, (lcl, lcr)) = l.p_explode(depth + 1, (cl, 0));
                    let (right, (rcl, rcr)) = r.p_explode(depth + 1, (lcr, cr));
                    let (left, _) = left.p_explode(depth + 1, (0, rcl));
                    (Nest(Box::new(left), Box::new(right)), (lcl, rcr))
                }
            }
        }
    }

    fn magnitude(&self) -> u32 {
        match self {
            Value(v) => *v,
            Nest(l, r) => 3 * l.magnitude() + 2 * r.magnitude()
        }
    }
}

fn parse(s: &str) -> Vec<Node> {
    s.lines()
        .map(|l| l.trim())
        .filter(|l| !l.is_empty())
        .map(|l| Node::from_str(l).unwrap())
        .collect()
}

fn part2(nodes: Vec<Node>) -> u32 {
    nodes.into_iter().combinations(2).map(|ns| {
        let mut it = ns.into_iter();
        let a = it.next().unwrap();
        let b = it.next().unwrap();
        max(a.clone().add(b.clone()).magnitude(), b.add(a).magnitude())
    }).max().unwrap()
}

fn main() {
    let nums = parse(include_str!("../../input/day18"));

    // nums.iter().for_each(|n| println!("{}", n));
    let p1 = nums.clone().into_iter()
        .reduce(|a, b| a.add(b)).unwrap().magnitude();
    println!("p1 = {:?}", p1);

    let p2 = part2(nums);
    println!("p2 = {:?}", p2);
}

#[cfg(test)]
mod tests {
    use super::Node::*;
    use super::*;

    fn val(v: u32) -> Box<Node> {
        Box::new(Value(v))
    }
    fn nest(l: Box<Node>, r: Box<Node>) -> Box<Node> {
        Box::new(Nest(l, r))
    }

    #[test]
    fn test_parse() {
        assert_eq!(Node::from_str("[1,2]").unwrap(),
                   Nest(val(1), val(2)));
        assert_eq!(Node::from_str("[[1,2],3]").unwrap(),
                   Nest(
                       nest(val(1), val(2)),
                       val(3)));
    }

    fn sum_all(s: &str) -> Node {
        parse(s).into_iter().reduce(|a, b| a.add(b)).unwrap()
    }

    fn sum_all_string(s: &str) -> String {
        sum_all(s).to_string()
    }

    #[test]
    fn test_sum() {
        assert_eq!(sum_all_string(r#"
            [1,1]
            [2,2]
            [3,3]
            [4,4]
        "#), "[[[[1,1],[2,2]],[3,3]],[4,4]]");
    }

    #[test]
    fn test_explode() {
        assert_eq!(sum_all_string(r#"
            [1,1]
            [2,2]
            [3,3]
            [4,4]
            [5,5]
        "#), "[[[[3,0],[5,3]],[4,4]],[5,5]]");

        assert_eq!(sum_all_string(r#"
            [1,1]
            [2,2]
            [3,3]
            [4,4]
            [5,5]
            [6,6]
        "#), "[[[[5,0],[7,4]],[5,5]],[6,6]]");
    }

    #[test]
    fn test_reduce() {
        assert_eq!(sum_all_string(r#"
            [[[0,[4,5]],[0,0]],[[[4,5],[2,6]],[9,5]]]
            [7,[[[3,7],[4,3]],[[6,3],[8,8]]]]
            [[2,[[0,8],[3,4]]],[[[6,7],1],[7,[1,6]]]]
            [[[[2,4],7],[6,[0,5]]],[[[6,8],[2,8]],[[2,1],[4,5]]]]
            [7,[5,[[3,8],[1,4]]]]
            [[2,[2,2]],[8,[8,1]]]
            [2,9]
            [1,[[[9,3],9],[[9,0],[0,7]]]]
            [[[5,[7,4]],7],1]
            [[[[4,2],2],6],[8,7]]
        "#), "[[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]]");
    }

    #[test]
    fn test_part1() {
        let n = sum_all(r#"
            [[[0,[5,8]],[[1,7],[9,6]]],[[4,[1,2]],[[1,4],2]]]
            [[[5,[2,8]],4],[5,[[9,9],0]]]
            [6,[[[6,2],[5,6]],[[7,6],[4,7]]]]
            [[[6,[0,7]],[0,9]],[4,[9,[9,0]]]]
            [[[7,[6,4]],[3,[1,3]]],[[[5,5],1],9]]
            [[6,[[7,3],[3,2]]],[[[3,8],[5,7]],4]]
            [[[[5,4],[7,7]],8],[[8,3],8]]
            [[9,3],[[9,9],[6,[4,9]]]]
            [[2,[[7,7],7]],[[5,8],[[9,3],[0,2]]]]
            [[[[5,2],5],[8,[3,7]]],[[5,[7,5]],[4,4]]]
        "#);

        assert_eq!(n.to_string(), "[[[[6,6],[7,6]],[[7,7],[7,0]]],[[[7,7],[7,7]],[[7,8],[9,9]]]]");
        assert_eq!(n.magnitude(), 4140);
    }

    #[test]
    fn test_part2() {
        let n = parse(r#"
            [[[0,[5,8]],[[1,7],[9,6]]],[[4,[1,2]],[[1,4],2]]]
            [[[5,[2,8]],4],[5,[[9,9],0]]]
            [6,[[[6,2],[5,6]],[[7,6],[4,7]]]]
            [[[6,[0,7]],[0,9]],[4,[9,[9,0]]]]
            [[[7,[6,4]],[3,[1,3]]],[[[5,5],1],9]]
            [[6,[[7,3],[3,2]]],[[[3,8],[5,7]],4]]
            [[[[5,4],[7,7]],8],[[8,3],8]]
            [[9,3],[[9,9],[6,[4,9]]]]
            [[2,[[7,7],7]],[[5,8],[[9,3],[0,2]]]]
            [[[[5,2],5],[8,[3,7]]],[[5,[7,5]],[4,4]]]
        "#);

        assert_eq!(part2(n), 3993);
    }
}