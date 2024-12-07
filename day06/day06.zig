const std = @import("std");

const Position = struct { x: i32, y: i32 }; // needs to be an i32 so that we can go off the board.
const Direction = enum {
    up,
    right,
    down,
    left,

    fn rotate(self: *Direction) void {
        self.* = switch (self.*) {
            Direction.up => Direction.right,
            Direction.right => Direction.down,
            Direction.down => Direction.left,
            Direction.left => Direction.up,
        };
    }

    fn getDirectionBitmap(self: Direction) u4 {
        switch (self) {
            Direction.up => return 0b0001,
            Direction.down => return 0b0010,
            Direction.left => return 0b0100,
            Direction.right => return 0b1000,
        }
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const inputFile = try std.fs.cwd().openFile("./input.txt", .{});
    defer inputFile.close();

    const reader = inputFile.reader();

    var lines = std.ArrayList([]u8).init(allocator);
    defer lines.deinit();

    var startPosition: Position = undefined;

    while (try reader.readUntilDelimiterOrEofAlloc(allocator, '\n', 256)) |line| {
        for (line, 0..) |char, i| {
            if (char == '^') {
                startPosition = Position{ .x = @intCast(lines.items.len), .y = @intCast(i) };
            }
        }

        const newLine = try lines.addOne();
        newLine.* = line;
    }

    // added for part 2
    var part1PositionsOccupied = std.ArrayList(Position).init(allocator);
    defer part1PositionsOccupied.deinit();

    // Part 1
    {
        var map = try copy2dArray(lines.items, allocator);
        defer free2dArray(map, allocator);
        var currentPosition = startPosition;
        var currentDirection = Direction.up;
        var positionsOccupied: i32 = 0;

        while (isInBounds(map, currentPosition)) {
            markPosition(&positionsOccupied, &map, currentPosition);
            (try part1PositionsOccupied.addOne()).* = currentPosition; // added for part 2
            move(map, &currentPosition, &currentDirection);
        }

        std.debug.print("Part 1: {}\n", .{positionsOccupied});
    }

    // Part 2
    // There's definitley a smart, mathematical way to do it, but I can't think of it, so brute force it is!

    {
        var loopsFound: u32 = 0;

        each_map: for (part1PositionsOccupied.items) |obsPos| {
            if (obsPos.x == startPosition.x and obsPos.y == startPosition.y) continue;

            var map = try copy2dArray(lines.items, allocator);
            defer free2dArray(map, allocator);
            map[@intCast(obsPos.x)][@intCast(obsPos.y)] = '#';

            // printBoard(map, startPosition, Direction.up);

            var currentPosition = startPosition;
            var currentDirection = Direction.up;

            var visited = std.AutoHashMap(Position, u4).init(allocator);
            defer visited.deinit();

            while (isInBounds(map, currentPosition)) {
                move(map, &currentPosition, &currentDirection);
                const previousVisits = visited.get(currentPosition);
                // std.debug.print("Direction bitmap {} / {any} \n", .{ currentDirection.getDirectionBitmap(), previousVisits });
                if (previousVisits orelse 0 & currentDirection.getDirectionBitmap() != 0) {
                    // it's a loop!
                    loopsFound += 1;
                    continue :each_map;
                } else {
                    try visited.put(currentPosition, previousVisits orelse 0 | currentDirection.getDirectionBitmap());
                }
            }
        }

        std.debug.print("Part 2: {}\n", .{loopsFound});
    }

    // Before only checking places that guard would actually hit:
    // real    1m42.551s
    // user    1m32.456s
    // sys     0m9.184s

    // after only checking places that guard would actually hit:
    // real    0m32.340s
    // user    0m28.393s
    // sys     0m3.633s
}

fn markPosition(positionsOccupied: *i32, map: *[][]u8, position: Position) void {
    const x: usize = @intCast(position.x);
    const y: usize = @intCast(position.y);

    if (map.*[x][y] != 'X') {
        map.*[x][y] = 'X';
        positionsOccupied.* += 1;
    }
}

fn move(map: [][]u8, position: *Position, direction: *Direction) void {
    const nextSquare: Position = switch (direction.*) {
        Direction.up => Position{ .x = position.x - 1, .y = position.y },
        Direction.down => Position{ .x = position.x + 1, .y = position.y },
        Direction.left => Position{ .x = position.x, .y = position.y - 1 },
        Direction.right => Position{ .x = position.x, .y = position.y + 1 },
    };

    if (!isInBounds(map, nextSquare)) {
        position.* = nextSquare;
        return;
    }

    const nextX: usize = @intCast(nextSquare.x);
    const nextY: usize = @intCast(nextSquare.y);

    if (map[nextX][nextY] == '#') {
        direction.rotate();
        move(map, position, direction); // tail call! this is equivalent to iteration.
        return;
    }

    position.* = nextSquare;
}

var boundsChecks: u32 = 0;

fn isInBounds(map: [][]u8, position: Position) bool {
    boundsChecks += 1;
    // std.debug.print("checking if in bounds: {}, {any}\n", .{ boundsChecks, position });
    return (position.x >= 0 and position.x < map.len) and (position.y >= 0 and position.y < map[@intCast(position.x)].len);
}

fn printBoard(map: [][]u8, position: Position, direction: Direction) void {
    const dirSymbol: u8 = switch (direction) {
        Direction.up => '^',
        Direction.down => 'v',
        Direction.left => '<',
        Direction.right => '>',
    };

    for (map, 0..) |row, i| {
        for (row, 0..) |cell, j| {
            if (position.x == i and position.y == j) {
                std.debug.print("{c}", .{dirSymbol});
            } else {
                std.debug.print("{c}", .{cell});
            }
        }
        std.debug.print("\n", .{});
    }
    std.debug.print("\n\n", .{});
}

fn copy2dArray(src: [][]u8, allocator: std.mem.Allocator) ![][]u8 {
    var dst = try allocator.alloc([]u8, src.len);

    for (src, 0..) |row, i| {
        dst[i] = try allocator.alloc(u8, row.len);
        std.mem.copyForwards(u8, dst[i], row);
    }

    return dst;
}

fn free2dArray(arr: [][]u8, allocator: std.mem.Allocator) void {
    for (arr) |row| {
        allocator.free(row);
    }
    allocator.free(arr);
}
