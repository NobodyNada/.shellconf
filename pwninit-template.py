#!/usr/bin/env python3

from pwn import *

{bindings}

context.binary = {bin_name}
debug_script='''

'''

def conn():
    if args.REMOTE:
        p = remote("addr", 1337)
    else if args.D:
        p = gdb.debug({proc_args}, gdbscript=debug_script)
    else:
        p = process({proc_args})

    return p

def main():
    p = conn()
    
    # tick 197 certified

    p.interactive()


if __name__ == "__main__":
    main()
