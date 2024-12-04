const std = @import("std");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    // const input_path = "input_sample.txt";
    const input_path = "input.txt";

    const stdout = std.io.getStdOut().writer();

    const buffer = try fileToBuffer(allocator, input_path);
    defer allocator.free(buffer);

    const lines = try bufferToLines(allocator, buffer);
    defer allocator.free(lines);

    const locations = try find(allocator, lines, 'X');
    defer allocator.free(locations);

    var sum: i64 = 0;
    for (locations) |location| {
        const matches = testAll(lines, location);
        sum += matches;
    }
    try stdout.print("{d}\n", .{sum});

    // part 2:

    const locationsPart2 = try find(allocator, lines, 'A');
    defer allocator.free(locationsPart2);

    var matches: i64 = 0;
    for (locationsPart2) |location| {
        const match = testPart2(lines, location);
        if (match) {
            matches += 1;
        }
    }
    try stdout.print("{d}\n", .{matches});
}

fn fileToBuffer(allocator: std.mem.Allocator, path: []const u8) ![]const u8 {
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    const file_size = try file.getEndPos();
    const buffer = try allocator.alloc(u8, file_size);

    _ = try file.readAll(buffer);

    return buffer;
}

fn bufferToLines(allocator: std.mem.Allocator, buffer: []const u8) ![][]const u8 {
    var line_list = std.ArrayList([]const u8).init(allocator);
    defer line_list.deinit();

    var iter = std.mem.split(u8, buffer, "\n");
    while (iter.next()) |line| {
        try line_list.append(line);
    }

    const slice = try line_list.toOwnedSlice();

    return slice;
}

fn find(allocator: std.mem.Allocator, lines: [][]const u8, needle: u8) ![]const [2]usize {
    var result = std.ArrayList([2]usize).init(allocator);
    defer result.deinit();

    var y: usize = 0;
    while (y < lines.len): (y+=1) {
        const line = lines[y];
        var x: usize = 0;
        while(x < line.len): (x+=1) {
            if (line[x] == needle) {
                try result.append([2]usize{x, y});
            }
        }
    }

    return result.toOwnedSlice();
}

const xmas = "XMAS";

fn testAll(lines: [][]const u8, location: [2]usize) i64 {
    var matches: i64 = 0;

    var x: i64 = -1;
    while (x <= 1): (x+=1) {
        var y: i64 = -1;
        while (y <= 1): (y+=1) {
            if (x == 0 and y == 0) {
                continue;
            }

            if (testGoing(lines, location, x, y)) {
                matches += 1;
            }
        }
    }

    return matches;
}

fn testPart2(lines: [][]const u8, location: [2]usize) bool {
    const x: i64 = @intCast(location[0]);
    const y: i64 = @intCast(location[1]);

    const leftX = x-1;
    const rightX = x+1;
    const topY = y-1;
    const bottomY = y+1;

    if (leftX < 0 or topY < 0) {
        return false;
    }

    const yMax = lines.len - 1;
    if (bottomY > yMax) {
        return false;
    }

    const bottomLineLen = lines[@intCast(bottomY)].len;
    if (bottomLineLen == 0) {
        return false;
    }

    const xMax = bottomLineLen - 1;
    if (rightX > xMax) {
        return false;
    }

    const topLeft = lines[@intCast(topY)][@intCast(leftX)];
    const topRight = lines[@intCast(topY)][@intCast(rightX)];
    const bottomLeft = lines[@intCast(bottomY)][@intCast(leftX)];
    const bottomRight = lines[@intCast(bottomY)][@intCast(rightX)];

    // dir top-left to bottom-right
    if (topLeft != 'M' and topLeft != 'S') {
        return false;
    }
    if (topLeft == 'M' and bottomRight != 'S') {
        return false;
    }
    if (topLeft == 'S' and bottomRight != 'M') {
        return false;
    }

    // dir bottom-left to top-right
    if (bottomLeft != 'M' and bottomLeft != 'S') {
        return false;
    }
    if (bottomLeft == 'M' and topRight != 'S') {
        return false;
    }
    if (bottomLeft == 'S' and topRight != 'M') {
        return false;
    }

    return true;
}

fn testGoing(lines: [][]const u8, location: [2]usize, xStep: i64, yStep: i64) bool {
    const x: i64 = @intCast(location[0]);
    const y: i64 = @intCast(location[1]);

    const steps: i64 = @intCast(xmas.len-1);

    const lastLocationX = x + (steps*xStep);
    const lastLocationY = y + (steps*yStep);

    // bound checks
    // up
    if (lastLocationY < 0) {
        return false;
    }
    // left
    if (lastLocationX < 0) {
        return false;
    }
    // down
    if (lastLocationY > lines.len - 1) {
        return false;
    }
    // right
    const lastLineLen = lines[@intCast(lastLocationY)].len;
    if (lastLineLen == 0) {
        return false;
    }
    if (lastLocationX > lastLineLen - 1) {
        return false;
    }


    var i: i64 = 1;
    while (i <= steps): (i+=1) {
        const xCurr: usize = @intCast(x + (i * xStep));
        const yCurr: usize = @intCast(y + (i * yStep));

        if (lines[yCurr][xCurr] != xmas[@intCast(i)]) {
            return false;
        }
    }

    return true;
}
