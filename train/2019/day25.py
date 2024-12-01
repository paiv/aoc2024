#!/usr/bin/env python
import ctypes
import itertools
import json
import re
import readline
import string
import sys
from collections import defaultdict, deque, namedtuple
from ctypes import c_char_p, c_void_p, c_int, c_size_t
from pathlib import Path


class Droid:

    class Halt (Exception): pass

    def __init__(self):
        lib = ctypes.cdll.LoadLibrary('libintcode.so')
        lib.ic_create_state.restype = c_void_p
        lib.ic_delete_state.argtypes = (c_void_p,)
        lib.ic_state_init_data.argtypes = (c_void_p, c_char_p, c_size_t)
        lib.ic_interact.argtypes = (c_void_p, c_char_p, c_char_p)
        self.lib = lib

    def __enter__(self):
        self._open()
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self._close()

    def _open(self):
        self.obuf = ctypes.create_string_buffer(2)
        scode = Path('day25.in').read_text().encode()
        self.state = self.lib.ic_create_state()
        self.lib.ic_state_init_data(self.state, scode, len(scode))

    def _close(self):
        self.lib.ic_delete_state(self.state)

    def _interact(self, value=None):
        res = b''
        while True:
            r = self.lib.ic_interact(self.state, value, self.obuf)
            value = None
            if r == 1:
                res += self.obuf.value
            # elif r == 3:
            #     raise Droid.Halt()
            else:
                break
        return res

    def read(self):
        s = self._interact()
        return s.decode()

    def write(self, value):
        s = self._interact(value.encode())
        return s.decode()


Room = namedtuple('Room', 'name info doors items')

def parse_room(text):
    m = re.findall(r'^== (.*?) ==(.*?)Doors.*?\s*((?:^- .+?$\s*)+)\s*(?:Items.*?\s*((?:^- .+?$\s*)+))?', text, re.M + re.S)
    if not m: return
    (name,desc,doors,items) = m[-1]
    name = name.strip()
    desc = desc.strip()
    doors = [s.strip() for s in doors.split('-')[1:]]
    items = [s.strip() for s in items.split('-')[1:]]
    return Room(name, desc, doors, items)


def find_path(edges, start, goal):
    pos = start
    fringe = deque([ (start, tuple()) ])
    seen = set()
    while fringe:
        pos,path = fringe.popleft()
        if pos == goal:
            return path
        if pos in seen: continue
        seen.add(pos)
        for door,room in edges[pos].items():
            fringe.append((room, path + (door,)))


def explore(droid):
    rooms = dict()
    ways = defaultdict(dict)
    revs = dict(west='east', east='west', south='north', north='south')
    s = droid.read()
    root = parse_room(s)
    rooms[root.name] = root
    pos = root.name
    fringe = list()
    for door in root.doors:
        fringe.append((root.name, door))
    seen = {root.name}
    while fringe:
        goal,door = fringe.pop()
        path = find_path(ways, pos, goal)
        if path is None:
            raise Exception(f'no path from {pos!r} to {goal!r}')
        for p in path:
            droid.write(p + '\n')
        s = droid.write(door + '\n')
        room = parse_room(s)
        ways[goal][door] = room.name
        if room.name not in seen:
            seen.add(room.name)
            rooms[room.name] = room
            for dr in room.doors:
                fringe.append((room.name, dr))
        pos = room.name
        if ways[pos].get(revs[door]) is None:
            fringe.append((pos, revs[door]))
    path = find_path(ways, pos, root.name)
    for p in path:
        droid.write(p + '\n')
    return rooms, ways


def interact(droid):
    r = droid.read()
    while True:
        print(r)
        c = input('> ')
        if c == 'quit':
            break
        c = c.strip() + '\n'
        r = droid.write(c)


def dump_graph(grid, edges):
    abc = string.ascii_uppercase
    names = {s:abc[i] for i,s in enumerate(edges.keys())}
    print('digraph {')
    for k,i in names.items():
        if (ns := grid[k].items):
            k = '\n'.join([k, *(f'- {s}' for s in ns)])
        s = json.dumps(k)
        print(f'  {i} [label={s}];')
    for k,dr in edges.items():
        i = names[k]
        for w,s in dr.items():
            j = names[s]
            w = json.dumps(w[:1])
            print(f'  {i} -> {j} [label={w}];')
    print('}')


def main_graph(args):
    with Droid() as droid:
        grid, edges = explore(droid)
        dump_graph(grid, edges)


def solve(droid, grid, edges):
    ignore = {
        'infinite loop',
        'photons',
        'molten lava',
        'escape pod',
        'giant electromagnet',
    }
    pos = 'Hull Breach'
    fringe = [(k, i) for k,n in grid.items() for i in n.items if i not in ignore]
    for k, i in fringe:
        path = find_path(edges, pos, k)
        for p in path:
            droid.write(p + '\n')
        pos = k
        droid.write(f'take {i}\n')
    goal = 'Security Checkpoint'
    path = find_path(edges, pos, goal)
    for p in path:
        droid.write(p + '\n')
    pos = goal
    s = droid.write('inv\n')
    items = re.findall(r'^- (.*?)$', s, re.M)
    for i in items:
        droid.write(f'drop {i}\n')
    for n in range(1, len(items)+1):
        for ks in itertools.combinations(items, n):
            for i in ks:
                droid.write(f'take {i}\n')
            s = droid.write('north\n')
            if 'keypad' in s:
                print(ks, file=sys.stderr)
                sec, = re.findall(r'typing (\d+)', s)
                return sec
            for i in ks:
                droid.write(f'drop {i}\n')


def main(args):
    with Droid() as droid:
        grid, edges = explore(droid)
    with Droid() as droid:
        ans = solve(droid, grid, edges)
    print(ans)


if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser()
    subps = parser.add_subparsers()
    graph = subps.add_parser('graph')
    graph.set_defaults(func=main_graph)
    args = parser.parse_args()
    if hasattr(args, 'func'):
        args.func(args)
    else:
        main(args)
