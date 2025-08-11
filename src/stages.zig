const std = @import("std");

pub const Stage = enum {
    Warmup,
    OneWayToGo,

    pub fn toString(self: Stage) []const u8 {
        return @tagName(self);
    }
    const all_stages: [std.meta.fields(Stage).len]Stage = blk: {
        const fields = std.meta.fields(Stage);
        var vals: [fields.len]Stage = undefined;
        for (fields, 0..) |fld, i| {
            vals[i] = @field(Stage, fld.name);
        }
        break :blk vals;
    };

    pub fn all() []const Stage {
        return &all_stages;
    }

    pub fn allToString(allocator: std.mem.Allocator) ![][]const u8 {
        var list = try allocator.alloc([]const u8, std.meta.fields(Stage).len);

        const all_levels = all();

        for (all_levels, 0..) |s, i| {
            list[i] = s.toString();
        }

        return list;
    }

    pub fn location(self: Stage, allocator: std.mem.Allocator) ![]const u8 {
        var exe_path_buf: [std.fs.max_path_bytes]u8 = undefined;
        const exe_path = try std.fs.selfExePath(exe_path_buf[0..]);

        const exe_dir_path = std.fs.path.dirname(exe_path) orelse ".";

        return try std.fs.path.join(allocator, &.{ exe_dir_path, self.toString() });
    }
};
