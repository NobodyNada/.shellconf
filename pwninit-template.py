#!/usr/bin/env python3

from pwn import *

{bindings}

context.binary = {bin_name}
debug_script='''
decompiler connect binja
'''

def conn():
    if args.REMOTE:
        p = remote("addr", 1337)
    elif args.D:
        p = gdb.debug([{bin_name}.path], gdbscript=debug_script, env=[('SHELL', '/bin/bash')])
    else:
        p = process([{bin_name}.path])

    return p

def main():
    p = conn()
    
    # tick 197 certified

    p.interactive()


if __name__ == "__main__":
    main()
