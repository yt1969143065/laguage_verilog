//rotate right shift (a 循环右移 b)
assign c = ({a[62:0], a[63]} << ~b[5:0] ) |  ( a >> b[5:0] );   //(左移 -b | 右移 b)
