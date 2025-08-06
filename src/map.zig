const std = @import("std");
const plr = @import("player.zig");

const map_start_idx = 1;
const starting_char = 'S';

const blocking_chars = [_]u8{ 'X', 'W' };
const exit_char = 'E';

pub const Map = struct {
    width: usize,
    height: usize,
    map: []const []const u8,

    pub fn deinit(self: *Map, allocator: std.mem.Allocator) void {
        for (self.map) |line| {
            allocator.free(line);
        }
        allocator.free(self.map);
    }

    pub fn findStartingPoint(self: *Map) !struct { startX: usize, startY: usize } {
        for (self.map, 0..) |line, idx| {
            if (std.ascii.indexOfIgnoreCase(line, &[_]u8{starting_char})) |v| {
                return .{ .startX = v, .startY = idx };
            }
        }
        std.debug.print("Missing starting point", .{});
        return error.MissingStartingPoint;
    }

    pub fn findExitPoint(self: *Map) !struct { exitX: usize, exitY: usize } {
        for (self.map, 0..) |line, idx| {
            if (std.ascii.indexOfIgnoreCase(line, &[_]u8{exit_char})) |v| {
                return .{ .exitX = v, .exitY = idx };
            }
        }
        std.debug.print("Missing exit point", .{});
        return error.MissingExitPoint;
    }

    fn isCollisionCharacter(c: u8) bool {
        for (blocking_chars) |e| {
            if (e == c) {
                return true;
            }
        }

        return false;
    }

    pub fn isCollision(self: *Map, player: plr.Player, direction: plr.Move) bool {
        switch (direction) {
            plr.Move.Up => {
                if (player.positionY == 0) return true;

                const next_element = self.map[player.positionY - 1][player.positionX];

                if (isCollisionCharacter(next_element)) {
                    return true;
                }

                return false;
            },

            plr.Move.Down => {
                if (player.positionY == self.height) return true;

                const next_element = self.map[player.positionY + 1][player.positionX];

                if (isCollisionCharacter(next_element)) {
                    return true;
                }

                return false;
            },

            plr.Move.Left => {
                if (player.positionX == 0) return true;

                const next_element = self.map[player.positionY][player.positionX - 1];

                if (isCollisionCharacter(next_element)) {
                    return true;
                }

                return false;
            },

            plr.Move.Right => {
                if (player.positionY == self.width) return true;

                const next_element = self.map[player.positionY][player.positionX + 1];

                if (isCollisionCharacter(next_element)) {
                    return true;
                }

                return false;
            },
        }

        return true;
    }
};

pub fn getMap(allocator: std.mem.Allocator, stage_file_name: []const u8) !Map {
    const file = try std.fs.cwd().openFile(stage_file_name, .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    const reader = buf_reader.reader();

    var buffer: [1024]u8 = undefined;

    var stage = std.ArrayList([]u8).init(allocator);
    defer stage.deinit();

    while (true) {
        const maybe_line = try reader.readUntilDelimiterOrEof(&buffer, '\n');

        if (maybe_line) |l| {
            const l_copy = try allocator.dupe(u8, l);
            try stage.append(l_copy);
        } else {
            // EOF
            break;
        }
    }

    if (stage.items.len < 3) {
        std.debug.print("Incorrect stage settings. Need stage name at first line and at least one line for map.\n", .{});
        return error.IncorrectStageSettings;
    }
    //

    const map_w_h = findWidthAndHeigh(stage.items[map_start_idx..]);

    var map = std.ArrayList([]u8).init(allocator);
    try map.ensureTotalCapacity(stage.items[map_start_idx..].len);

    for (stage.items[map_start_idx..]) |item| {
        const item_copy = try allocator.dupe(u8, item);
        try map.append(item_copy);
    }

    return Map{ .width = map_w_h.w, .height = map_w_h.h, .map = map.items };
}

fn findWidthAndHeigh(map: [][]u8) struct { w: usize, h: usize } {
    var max_width: usize = 1;
    const max_heigh: usize = map.len;

    for (map) |row| {
        if (row.len > max_width) max_width = row.len;
    }

    return .{ .w = max_width, .h = max_heigh };
}
