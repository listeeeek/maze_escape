const std = @import("std");

const c = @cImport({
    @cInclude("termios.h");
});
pub const RawTTY = struct {
    file: std.fs.File,
    orig_termios: c.struct_termios,

    pub fn init() !RawTTY {
        const file = try std.fs.cwd().openFile("/dev/tty", .{});

        var orig_termios: c.struct_termios = undefined;
        if (c.tcgetattr(file.handle, &orig_termios) != 0) {
            return error.TermiosFail;
        }

        var raw = orig_termios;
        raw.c_lflag &= ~@as(c_uint, c.ICANON | c.ECHO);
        raw.c_cc[c.VMIN] = 1;
        raw.c_cc[c.VTIME] = 0;

        if (c.tcsetattr(file.handle, c.TCSANOW, &raw) != 0) {
            return error.TermiosFail;
        }

        return RawTTY{
            .file = file,
            .orig_termios = orig_termios,
        };
    }

    pub fn deinit(self: *RawTTY) void {
        _ = c.tcsetattr(self.file.handle, c.TCSANOW, &self.orig_termios);
        self.file.close();
    }

    pub fn readByte(self: *RawTTY) !u8 {
        var buf: [1]u8 = undefined;
        const n = try self.file.read(&buf);
        if (n == 0) return error.EndOfFile;
        return buf[0];
    }
};
