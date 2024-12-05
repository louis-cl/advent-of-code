const std = @import("std");
const mem = std.mem;

input: []const u8,
allocator: mem.Allocator,

const Solution = struct { p1: u32, p2: u32 };
const Rule = struct { before: u8, after: u8 };

pub fn solve(this: *const @This()) !Solution {
    var rules: [100][100]bool = undefined;
    var iter = mem.splitScalar(u8, this.input, '\n');
    // rules
    while (iter.next()) |line| {
        if (line.len == 0) break;
        const rule = parseRule(line);
        rules[rule.before][rule.after] = true;
    }
    // updates
    var p1: u32 = 0;
    var p2: u32 = 0;
    while (iter.next()) |line| {
        if (line.len == 0) break;
        const pages = parseLine(this.allocator, line);
        defer this.allocator.free(pages);
        if (followsRules(rules, pages)) {
            p1 += pages[pages.len / 2];
        } else {
            mem.sort(u8, pages, rules, before);
            p2 += pages[pages.len / 2];
        }
    }
    return Solution{ .p1 = p1, .p2 = p2 };
}

fn before(rules: [100][100]bool, lhs: u8, rhs: u8) bool {
    return rules[lhs][rhs];
}

fn followsRules(rules: [100][100]bool, pages: []const u8) bool {
    for (0.., pages) |i, page| {
        for (pages[i + 1 ..]) |after_page| {
            if (rules[after_page][page]) return false;
        }
    }
    return true;
}

fn parseLine(allocator: mem.Allocator, line: []const u8) []u8 {
    // length of a line of n numbers is 3n - 1 (because split removes the new line)
    std.debug.assert((line.len + 1) % 3 == 0);
    const n = (line.len + 1) / 3;
    var pages: []u8 = allocator.alloc(u8, n) catch unreachable;
    for (0..n) |i| pages[i] = parse2Digits(line[3 * i ..]);
    return pages;
}

fn parseRule(line: []const u8) Rule {
    std.debug.assert(line.len == 5);
    return Rule{ .before = parse2Digits(line), .after = parse2Digits(line[3..]) };
}

fn parse2Digits(data: []const u8) u8 {
    return (data[0] - '0') * 10 + data[1] - '0';
}

test "parseRule" {
    const rule = parseRule("23|45");
    try std.testing.expectEqual(23, rule.before);
    try std.testing.expectEqual(45, rule.after);
}

test "simple" {
    const input =
        \\11|22
        \\22|44
        \\
        \\11,22,33
        \\33,44,22
        \\
    ;
    const problem: @This() = .{
        .input = input,
        .allocator = std.testing.allocator,
    };
    const sol = try problem.solve();
    try std.testing.expectEqual(22, sol.p1);
}

test "sample" {
    const input =
        \\47|53
        \\97|13
        \\97|61
        \\97|47
        \\75|29
        \\61|13
        \\75|53
        \\29|13
        \\97|29
        \\53|29
        \\61|53
        \\97|53
        \\61|29
        \\47|13
        \\75|47
        \\97|75
        \\47|61
        \\75|61
        \\47|29
        \\75|13
        \\53|13
        \\
        \\75,47,61,53,29
        \\97,61,53,29,13
        \\75,29,13
        \\75,97,47,61,53
        \\61,13,29
        \\97,13,75,29,47
        \\
    ;
    const problem: @This() = .{
        .input = input,
        .allocator = std.testing.allocator,
    };
    const sol = try problem.solve();
    try std.testing.expectEqual(143, sol.p1);
    try std.testing.expectEqual(123, sol.p2);
}
