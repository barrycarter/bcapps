#!/usr/local/bin/python
import ephem
from datetime import datetime
x = datetime.now()
print x
print ephem.Date(x).tuple()
