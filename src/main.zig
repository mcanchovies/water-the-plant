const std = @import("std");
const print = std.debug.print;

// first written struct, eeeeek!
// note, vars end in ";" not ,
// putting const makes this a "container level var"
// not a field i can use with self
// also for format, remember to use try

const Plant = struct {
    n_health: u8,
    o_desire: enum {
        pet, // physical touch
        story, // acts of service? you're teaching it?
        // whatever lol talking to a plant is funny
        answer, // quality time
        show_art, // praise
        water, // gift
        lol_error_haha, // professional error handling
    },

    // duckai generated
    // this std lib function returns an optional
    // either i handle a nonexhaustive enum or every
    // possible value of day or just
    // catch errors at the source which is this func
    // this prolly could've been a switch like the other one
    pub fn setDesire(self: *@This(), day: i8) void {
        if (std.enums.fromInt(@TypeOf(self.o_desire), day)) |desire| {
            self.o_desire = desire;
        } else {
            // it forgot to add a fallback value
            // you can't print enums with no value
            self.o_desire = .lol_error_haha;
            print("invalid desire value: {d}\n", .{day});
        }
    }

    pub fn hurtPlant(self: *@This(), day: i8) void {
        //decrement health based on day number
        self.n_health -= switch (day) {
            1, 2, 3 => 3,
            else => 5,
        };
    }

    pub fn healPlant(self: *@This()) void {
        self.n_health += 1;
    }

    pub fn format(
        self: @This(),
        // the writer param is automatically passed in by zig
        // when i print() plant
        writer: *std.Io.Writer,
    ) std.Io.Writer.Error!void {
        try writer.print("plant's health: {d}\n", .{self.n_health});
        try writer.print("plant's desire: {any}\n", .{self.o_desire});
    }
};

// mostly cpy and paste from the parrot
pub fn user_input(io: std.Io, s_txt: []u8, N_MAX_CHARS: u8) ?[]const u8 { // returns arr of chars
    const stdin = std.Io.File.stdin();

    var a_buff: [1024]u8 = undefined;
    var o_reader = stdin.reader(io, &a_buff);
    const s_line = o_reader.interface.takeDelimiterExclusive('\n') catch {
        print("\n\ninput error, toodles.\n\n", .{});
        return null;
    };

    // lol so i had problems with the length of the string again
    // but that's bc i copy pasted the powershell version
    // into here, which is using linux
    // which doesn't have that problem
    var n_len: usize = 0;
    if (s_line.len > N_MAX_CHARS) {
        n_len = N_MAX_CHARS;
    } else {
        n_len = s_line.len;
    }

    std.mem.copyForwards(u8, s_txt, s_line[0..n_len]);

    return s_txt[0..n_len];
}

pub fn main(init: std.process.Init) !void {
    // putting this in main rather than the input
    // function means i can keep all the initializing here
    const io = init.io;
    const alloc = std.heap.page_allocator;
    const N_MAX_CHARS: u8 = 32;
    const s_txt_space = try alloc.alloc(u8, N_MAX_CHARS);
    defer alloc.free(s_txt_space);

    const s_user_txt = user_input(io, s_txt_space, N_MAX_CHARS) orelse return;

    print("{s}", .{s_user_txt});

    print("asdf\n", .{});

    var myplant = Plant{
        .n_health = 6,
        // value is set at the start of each day
        .o_desire = undefined,
    };
    myplant.setDesire(-5);
    print("{f}", .{myplant});
}
