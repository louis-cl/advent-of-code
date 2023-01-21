use crate::Content::{Literal, Operator};

#[derive(Debug, PartialEq, Clone)]
struct Packet {
    v: u8,
    c: Content
}
#[derive(Debug, PartialEq, Clone)]
enum Content {
    Literal(u64),
    Operator(Operation),
}
#[derive(Debug, PartialEq, Clone)]
struct Operation {
    id: u8,
    sub: Vec<Packet>,
}

fn to_binary(c: char) -> &'static str {
    match c {
        '0' => "0000",
        '1' => "0001",
        '2' => "0010",
        '3' => "0011",
        '4' => "0100",
        '5' => "0101",
        '6' => "0110",
        '7' => "0111",
        '8' => "1000",
        '9' => "1001",
        'A' => "1010",
        'B' => "1011",
        'C' => "1100",
        'D' => "1101",
        'E' => "1110",
        'F' => "1111",
        _ => panic!("?"),
    }
}
fn from_bin(bin: &[u8]) -> u64 {
    bin.iter().fold(0, |x, b| (x << 1) | *b as u64)
}
fn parse_value(bin: &[u8]) -> (usize, u64) {
    let mut v = 0;
    let mut i = 0;
    let mut cont = true;
    while cont {
        v <<= 4;
        cont = bin[i] == 1;
        v |= from_bin(&bin[i+1..i+5]);
        i += 5;
    }
    (i, v)
}

fn p_parse(bin: &[u8]) -> (usize, Packet) {
    // println!("parsing from {:?}", bin);
    let mut i = 0;
    let v = from_bin(&bin[0..3]) as u8;
    let t = from_bin(&bin[3..6]) as u8;
    i += 6;
    match t {
        4 => {
            let (n, value) = parse_value(&bin[i..]);
            (n+i, Packet { v, c: Literal(value) })
        },
        id => {
            // println!("to parse as op {:?}", &bin[i..i+16]);
            let length_in_packets = bin[i] == 1;
            i += 1;
            let to_read = if !length_in_packets { 15 } else { 11 };
            let l= from_bin(&bin[i..i+to_read]) as usize;
            i += to_read;
            // println!("{:?}", length);

            let sub = {
                let mut packets = Vec::new();
                if length_in_packets {  // num of sub packets
                    for _ in 0..l {
                        let (n, p) = p_parse(&bin[i..]);
                        // println!("sub packet {:?} of size {}", p, n);
                        i += n;
                        packets.push(p);
                    }
                } else { // length in bits
                    let mut j = 0;
                    while j < l {
                        let (n, p) = p_parse(&bin[i+j..]);
                        // println!("sub packet {:?} of size {}", p, n);
                        j += n;
                        packets.push(p);
                    }
                    assert_eq!(j, l);
                    i += j;
                }
                packets
            };
            (i, Packet { v, c: Operator(Operation { id, sub}) })
        }
    }
}

fn decode(s: &str) -> Vec<u8> {
    s.chars().map(|c| to_binary(c).chars()).flatten()
        .map(|c| c.to_digit(2).unwrap() as u8).collect()
}

fn parse(s: &str) -> Packet {
    p_parse(&decode(s)).1
}

#[cfg(test)]
mod parse_test {
    use super::*;

    #[test]
    fn value() {
        let p = parse("D2FE28");
        assert_eq!(p, Packet { v: 6, c: Literal(2021)});
    }

    #[test]
    fn operator1() {
        let p = parse("38006F45291200");
        assert_eq!(p, Packet {
            v: 1,
            c: Operator(Operation { id: 6, sub: vec![
                Packet { v: 6, c: Literal(10) },
                Packet { v: 2, c: Literal(20) }
            ] })
        });
    }

    #[test]
    fn operator2() {
        let p = parse("EE00D40C823060");
        assert_eq!(p, Packet {
            v: 7,
            c: Operator(Operation { id: 3, sub: vec![
                Packet { v: 2, c: Literal(1) },
                Packet { v: 4, c: Literal(2) },
                Packet { v: 1, c: Literal(3) }
            ] })
        });
    }
}

fn sum_version(packet: &Packet) -> u64 {
    let Packet{ v, c} = packet;
    match c {
        Literal(_) => *v as u64,
        Operator(Operation {sub, .. }) => {
            sub.iter().map(sum_version).sum::<u64>() + *v as u64
        }
    }
}

fn value(packet: &Packet) -> u64 {
    match &packet.c {
        Literal(value) => *value,
        Operator(Operation {sub, id }) => {
            let mut sub = sub.iter().map(value);
            match id {
                0 => sub.sum::<u64>(),
                1 => sub.product::<u64>(),
                2 => sub.min().unwrap(),
                3 => sub.max().unwrap(),
                5 => if sub.next().unwrap() > sub.next().unwrap() { 1 } else { 0 },
                6 => if sub.next().unwrap() < sub.next().unwrap() { 1 } else { 0 },
                7 => if sub.next().unwrap() == sub.next().unwrap() { 1 } else { 0 },
                _ => panic!("unknown")
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn part1() {
        let solve = |inp: &str| sum_version(&parse(inp));
        assert_eq!(solve("8A004A801A8002F478"), 16);
        assert_eq!(solve("620080001611562C8802118E34"), 12);
        assert_eq!(solve("C0015000016115A2E0802F182340"), 23);
        assert_eq!(solve("A0016C880162017C3686B18A3D4780"), 31);
    }
    #[test]
    fn part2() {
        let solve = |inp: &str| value(&parse(inp));
        assert_eq!(solve("C200B40A82"), 3);
        assert_eq!(solve("04005AC33890"), 54);
        assert_eq!(solve("880086C3E88112"), 7);
        assert_eq!(solve("CE00C43D881120"), 9);
        assert_eq!(solve("D8005AC2A8F0"), 1);
        assert_eq!(solve("F600BC2D8F"), 0);
        assert_eq!(solve("9C005AC2F8F0"), 0);
        assert_eq!(solve("9C0141080250320F1802104A08"), 1);

    }
}

fn main() {
    let inp = include_str!("../../input/day16").lines().next().unwrap();
    let packet = parse(inp);
    let p1 = sum_version(&packet);
    println!("p1 = {}", p1);

    let p2 = value(&packet);
    println!("p2 = {}", p2);
}