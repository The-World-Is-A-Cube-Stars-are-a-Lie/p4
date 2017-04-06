        .ORIG   x4000

        .FILL   head

head
        .FILL   3
        .FILL   0
        .FILL   x23
        .FILL   blk1

blk1
        .FILL   3
        .FILL   1
        .FILL   x23
        .FILL   blk2

blk2
        .FILL   1
        .FILL   2
        .FILL   x45
        .FILL   blk3

blk3
        .FILL   2
        .FILL   1
        .FILL   x53
        .FILL   blk4

blk4
        .FILL   0
        .FILL   2
        .FILL   x23
        .FILL   0

        .END
