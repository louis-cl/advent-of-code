type V2 = (i32, i32);

struct State {
    pos: V2,
    speed: V2
}

fn next(s: State) -> State {
    let State { pos: (x,y), speed: (vx, vy)  } = s;
    let dx = if vx < 0 { 1 } else if vx > 0 { -1 } else { 0 };
    State { pos: (x+vx, y+vy),  speed: (vx+dx, vy-1)}
}

fn is_in(p: &V2, xr: &V2, yr: &V2) -> bool {
    let (x,y) = p;
    let (minx, maxx) = xr;
    let (miny, maxy) = yr;
    x >= minx && x <= maxx && y >= miny && y <= maxy
}

fn missed(p: &State, xr: &V2, yr: &V2) -> bool {
    let (x,y) = p.pos;
    let (vx, _) = p.speed;
    let (minx, maxx) = *xr;
    let (miny, _) = *yr;
    y < miny || (x < minx && vx == 0) || (x > maxx && vx == 0)
}

fn hits(v: V2, xr: &V2, yr: &V2) -> bool {
    let mut s = State { pos: (0,0), speed: v};
    while !is_in(&s.pos, xr, yr) {
        if missed(&s, xr, yr) { return false; }
        s = next(s);
    }
    true
}

fn find(xr: V2, yr: V2) -> V2 {
    let (_, maxx) = xr;
    let (miny, maxy) = yr;
    for vy in (-maxy..=-miny).rev() {
        for vx in 1..=maxx {
            // println!("trying {:?}", (vx, vy));
            if hits((vx, vy), &xr, &yr) {
                return (vx, vy);
            }
        }
    }
    panic!("failed");
}

fn count(xr: V2, yr: V2) -> u32 {
    let (_, maxx) = xr;
    let (miny, _) = yr;
    let mut total = 0;
    for vy in miny..=-miny {
        for vx in 1..=maxx {
            if hits((vx, vy), &xr, &yr) {
                total += 1;
            }
        }
    }
    total
}

fn main() {
    // target area: x=277..318, y=-92..-53;
    let p1 = {
        let speed = find((277, 318), (-92, -53));
        speed.1 * (speed.1 + 1) / 2
    };
    println!("p1 = {:?}", p1);

    let p2 = count((277, 318), (-92, -53));
    println!("p2 = {}", p2);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_hits() {
        // target area: x=20..30, y=-10..-5
        // ans: (6,9) , max y = 45
        let xr = &(20, 30);
        let yr = &(-10, -5);
        assert!(hits((6, 9), xr, yr));
        assert!(hits((7,2), xr, yr));
        assert!(hits((6,3), xr, yr));
        assert!(hits((9,0), xr, yr));
        assert!(!hits((17,-4), xr, yr));
    }

    #[test]
    fn part1() {
        let speed = find((20,30), (-10, -5));
        assert_eq!((6,9), speed);
        let p1 = speed.1 * (speed.1 + 1) / 2;
        assert_eq!(45, p1);
    }

    #[test]
    fn part2() {
        let total = count((20,30), (-10, -5));
        assert_eq!(112, total);
    }
}