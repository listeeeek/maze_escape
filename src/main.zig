const std = @import("std");
const terminal = @import("terminal.zig");
const plr = @import("player.zig");

const c = @cImport({
    @cInclude("termios.h");
});

const map_settings = @import("map.zig");
pub fn main() !void {
    const allocator = std.heap.page_allocator;

    var settings = map_settings.getMap(allocator, "./src/stage_two.stage") catch |err| {
        std.debug.print("{s}\n", .{@errorName(err)});
        return;
    };

    defer settings.deinit(allocator);

    const start_position = settings.findStartingPoint() catch |err| {
        return err;
    };

    const exit_position = settings.findExitPoint() catch |err| {
        return err;
    };

    var player = plr.Player.init(start_position.startX, start_position.startY);

    // pre print map
    for (settings.map) |stage_item| {
        std.debug.print("{s}\n", .{stage_item});
    }

    var tty = try terminal.RawTTY.init();
    defer tty.deinit();

    while (true) {
        const ch = try tty.readByte();

        switch (ch) {
            'q' => {
                std.debug.print("Bye!\n", .{});
                break;
            },
            'w' => {
                if (!settings.isCollision(player, .Up)) {
                    player.move(.Up);
                }
            },

            's' => {
                if (!settings.isCollision(player, .Down)) {
                    player.move(.Down);
                }
            },

            'a' => {
                if (!settings.isCollision(player, .Left)) {
                    player.move(.Left);
                }
            },

            'd' => {
                if (!settings.isCollision(player, .Right)) {
                    player.move(.Right);
                }
            },
            else => {
                //TODO: skasowac pozniej, tylko na czas debugowania
                std.debug.print("Znak: {c} ({d})\n", .{ ch, ch });
            },
        }

        std.debug.print("\x1B[2J\x1B[H", .{}); // clear terminal.  wtf?!

        for (settings.map, 0..) |stage_item, line_idx| {
            if (player.positionY == line_idx) {
                for (stage_item, 0..) |line_c, line_c_idx| {
                    if (player.positionX == line_c_idx) {
                        std.debug.print("{c}", .{plr.Player.player_char});
                    } else {
                        std.debug.print("{c}", .{line_c});
                    }
                }
                std.debug.print("\n", .{});
            } else {
                std.debug.print("{s}\n", .{stage_item});
            }
        }

        if (player.positionX == exit_position.exitX and player.positionY == exit_position.exitY) {
            std.debug.print("Congratulations, You have WON!\n", .{});
            break;
        }
    }
}
