# this is from https://gist.githubusercontent.com/aflaxman/287370/raw/2fa6c2e1b3839e5bb367b806825da9b40f068695/gistfile1.py

execfile('/home/barrycarter/Download/gistfile1.py');
import matplotlib.pyplot as plt

x = read_osm("/home/barrycarter/Download/map2.osm");

print dir(x);

print x.adjacency_list();

print x.nodes();

networkx.draw(x);
plt.show()


