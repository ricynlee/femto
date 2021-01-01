#define DECL_SYMBOL(s) extern int s
#define EVAL_SYMBOL(s) ((int)&(s))

void init_bss(){
    DECL_SYMBOL(__bss_size);
    DECL_SYMBOL(__bss_begin);
    
    unsigned const bss_size = (unsigned) EVAL_SYMBOL(__bss_size);
    volatile char* const bss_begin = (char*) EVAL_SYMBOL(__bss_begin);

    for (unsigned i=0; i<(bss_size); i++) {
        bss_begin[i] = 0;
    }
}

void init_data(){
    DECL_SYMBOL(__data_size);
    DECL_SYMBOL(__data_lma_begin);
    DECL_SYMBOL(__data_vma_begin);
    
    unsigned const data_size = (unsigned) EVAL_SYMBOL(__data_size);
    volatile char* const data_lma_begin = (char*) EVAL_SYMBOL(__data_lma_begin);
    volatile char* const data_vma_begin = (char*) EVAL_SYMBOL(__data_vma_begin);

    for (unsigned i=0; i<(data_size); i++) {
        data_vma_begin[i] = data_lma_begin[i];
    }
}
