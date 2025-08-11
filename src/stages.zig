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
        const base = "./src/";
        const ext = ".stage";

        return try std.fmt.allocPrint(allocator, "{s}{s}{s}", .{ base, self.toString(), ext });
    }
};
