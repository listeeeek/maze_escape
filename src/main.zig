const std = @import("std");
const terminal = @import("terminal.zig");
const plr = @import("player.zig");
const yazap = @import("yazap");
const version = @import("version.zig");
const stages = @import("stages.zig");

const allocator = std.heap.page_allocator;
const App = yazap.App;
const Arg = yazap.Arg;
const c = @cImport({
    @cInclude("termios.h");
});

const map_settings = @import("map.zig");
pub fn main() !void {
    clearTerminal();

    var app = App.init(allocator, "myls", "My custom ls");
    defer app.deinit();

    var myls = app.rootCommand();
    try myls.addArg(Arg.booleanOption("version", 'v', "Display version"));

    const stages_names = try stages.Stage.allToString(allocator);
    defer allocator.free(stages_names);
    try myls.addArg(Arg.singleValueOptionWithValidValues("stage", 's', "Select stage", stages_names));

    const matches = try app.parseProcess();

    if (matches.containsArg("version")) {
        std.debug.print(version.version, .{});
        return;
    }

    var selected_stage = stages.Stage.Warmup;

    if (matches.containsArg("stage")) {
        const s_name = matches.getSingleValue("stage").?;

        selected_stage = std.meta.stringToEnum(stages.Stage, s_name) orelse {
            std.debug.print("Error parsing string to enum\n", .{});
            return;
        };
    }

    const loc = try selected_stage.location(allocator);
    defer allocator.free(loc);

    var settings = map_settings.getMap(allocator, loc) catch |err| {
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

        clearTerminal();

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

fn clearTerminal() void {
    std.debug.print("\x1B[2J\x1B[H", .{}); // clear terminal.  wtf?!
}
