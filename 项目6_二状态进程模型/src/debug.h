void debug_printreg(int ax, int bx, int cx, int dx, int bp, int si, int di, int ds, int es, int fs, int gs, int ss, int cs, int sp) {
    char* pro = "***debug_printreg***\r\ncurrent_process_id=";
    print(pro);
    print(itoa(current_process_id, 10)); NEWLINE;
    char* reg = "***reg begin***\r\n";
    print(reg);
    print(itoa(cs, 16)); putchar(' ');
    print(itoa(ss, 16)); putchar(' ');
    print(itoa(gs, 16)); putchar(' ');
    print(itoa(fs, 16)); putchar(' ');
    print(itoa(es, 16)); putchar(' ');
    print(itoa(ds, 16)); NEWLINE;

    print(itoa(di, 16)); putchar(' ');
    print(itoa(si, 16)); putchar(' ');
    print(itoa(bp, 16)); putchar(' ');
    print(itoa(sp, 16)); NEWLINE;

    print(itoa(dx, 16)); putchar(' ');
    print(itoa(cx, 16)); putchar(' ');
    print(itoa(bx, 16)); putchar(' ');
    print(itoa(ax, 16)); NEWLINE;
    
    char* end = "***reg end***\r\n\r\n";
    print(end);
}

void debug_printpcb() {
    char* pro = "###debug_printPCB###\r\ncurrent_process_id=";
    print(pro);
    print(itoa(current_process_id, 10)); NEWLINE;
    char* reg = "###reg begin###\r\n";
    print(reg);
    print(itoa(PCB_table[current_process_id].regimg.cs, 16)); putchar(' ');
    print(itoa(PCB_table[current_process_id].regimg.ss, 16)); putchar(' ');
    print(itoa(PCB_table[current_process_id].regimg.gs, 16)); putchar(' ');
    print(itoa(PCB_table[current_process_id].regimg.fs, 16)); putchar(' ');
    print(itoa(PCB_table[current_process_id].regimg.es, 16)); putchar(' ');
    print(itoa(PCB_table[current_process_id].regimg.ds, 16)); NEWLINE;

    print(itoa(PCB_table[current_process_id].regimg.di, 16)); putchar(' ');
    print(itoa(PCB_table[current_process_id].regimg.si, 16)); putchar(' ');
    print(itoa(PCB_table[current_process_id].regimg.bp, 16)); putchar(' ');
    print(itoa(PCB_table[current_process_id].regimg.sp, 16)); NEWLINE;

    print(itoa(PCB_table[current_process_id].regimg.dx, 16)); putchar(' ');
    print(itoa(PCB_table[current_process_id].regimg.cx, 16)); putchar(' ');
    print(itoa(PCB_table[current_process_id].regimg.bx, 16)); putchar(' ');
    print(itoa(PCB_table[current_process_id].regimg.ax, 16)); NEWLINE;
    
    print(itoa(PCB_table[current_process_id].status, 10));
    char* end = " is state\r\n###reg end###\r\n\r\n";
    print(end);
}