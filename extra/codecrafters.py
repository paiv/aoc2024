#!/usr/bin/env python
import itertools
import string

cc = 'PWFI YFRP, ZIK XVNVC% KTW GOXA MMQEMOTH'
print(cc)

key = 'WORKTHISOUT'
abc = string.ascii_uppercase

def vig(c, k):
    n = abc.index(c) - abc.index(k)
    return abc[n % len(abc)]

def vig(c, key):
    if c not in abc: return c
    n = abc.index(c) - abc.index(next(key))
    return abc[n % len(abc)]

ks = itertools.cycle(key)
s = ''.join(vig(c, ks) for c in cc)
print(s)
