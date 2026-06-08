# program.asm  (documentation only, not loaded)

00500093  # addi x1,  x0, 5
00a00113  # addi x2,  x0, 10
002081b3  # add  x3,  x1, x2
40110233  # sub  x4,  x2, x1
0020f2b3  # and  x5,  x1, x2
0020e333  # or   x6,  x1, x2
0020a3b3  # slt  x7,  x1, x2
00302023  # sw   x3,  0(x0)
00002403  # lw   x8,  0(x0)
00108463  # beq  x1,  x1, +8
3e700493  # addi x9,  x0, 999  <- skipped by beq
07b00513  # addi x10, x0, 123
00c005ef  # jal  x11, +12
3e700613  # addi x12, x0, 999  <- skipped
37800613  # addi x12, x0, 888  <- skipped
02a00613  # addi x12, x0, 42
008006ef  # jal  x13, +8
3e700713  # addi x14, x0, 999  <- skipped
04d00713  # addi x14, x0, 77
0000006f  # jal  x0,  0  (halt)