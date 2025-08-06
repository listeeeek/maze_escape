pub const Player = struct {
    positionX: usize,
    positionY: usize,

    pub const player_char = 'P';

    pub fn init(posX: usize, posY: usize) Player {
        return Player{ .positionX = posX, .positionY = posY };
    }

    pub fn move(self: *Player, direction: Move) void {
        switch (direction) {
            .Up => {
                self.positionY -= 1;
            },
            .Down => {
                self.positionY += 1;
            },

            .Right => {
                self.positionX += 1;
            },

            .Left => {
                self.positionX -= 1;
            },
        }
    }
};

pub const Move = enum { Up, Down, Right, Left };
