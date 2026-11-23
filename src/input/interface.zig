pub const Key = enum(u8) {
    k1 = 1,
    k2 = 2,
    k3 = 3,
    k4 = 4,
    k5 = 5,
    k6 = 6,
    k7 = 7,
    k8 = 8,
    k9 = 9,
    k10 = 10,
    k11 = 11,
    k12 = 12,
    k13 = 13,
    k14 = 14,
    k15 = 15,
    k16 = 16,
    k17 = 17,
    k18 = 18,
    k19 = 19,
    k20 = 20,
    k21 = 21,
    k22 = 22,
    k23 = 23,
    k24 = 24,
    k25 = 25,
    k26 = 26,
    k27 = 27,
    k28 = 28,
    k29 = 29,
    k30 = 30,
    k31 = 31,
    k32 = 32,
    k33 = 33,
    k34 = 34,
    k35 = 35,
    k36 = 36,
    k37 = 37,
    k38 = 38,
    k39 = 39,
    k40 = 40,
    k41 = 41,
    k42 = 42,
    k43 = 43,
    k44 = 44,
    k45 = 45,
    k46 = 46,
    k47 = 47,
    k48 = 48,
    k49 = 49,
    k50 = 50,
    k51 = 51,
    k52 = 52,
    k53 = 53,
    k54 = 54,
    k55 = 55,
    k56 = 56,
    k57 = 57,
    k58 = 58,
    k59 = 59,
    k60 = 60,
};

pub const Interface = struct {
    isPressedFn: *const fn (*const Interface, Key) bool,

    pub fn isPressed(self: *const Interface, key: Key) bool {
        return self.isPressedFn(self, key);
    }
};

test "all 60 keys exist" {
    try @import("std").testing.expectEqual(60, @import("std").meta.tags(Key).len);
}

test "arrow key mapping values" {
    try @import("std").testing.expectEqual(@as(u8, 1), @intFromEnum(Key.k1));
    try @import("std").testing.expectEqual(@as(u8, 11), @intFromEnum(Key.k11));
    try @import("std").testing.expectEqual(@as(u8, 12), @intFromEnum(Key.k12));
    try @import("std").testing.expectEqual(@as(u8, 2), @intFromEnum(Key.k2));
}

test "enter maps to SW56 and equals to SW36" {
    try @import("std").testing.expectEqual(@as(u8, 56), @intFromEnum(Key.k56));
    try @import("std").testing.expectEqual(@as(u8, 36), @intFromEnum(Key.k36));
}
