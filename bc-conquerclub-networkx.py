#!/usr/local/bin/python

# using networkx on conquerclub graphs

import sys
import networkx as NX

G = NX.read_adjlist(sys.argv[1]);

print G.nodes();

print NX.center(G);



