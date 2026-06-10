#ifndef CTB_H
#define CTB_H

// C-ABI surface of crates/tb_core_ffi. Every function returns a heap-allocated
// NUL-terminated JSON string that must be released with tb_free.

char *tb_probe(void);
void tb_free(char *p);

#endif
