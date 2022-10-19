#!/bin/python3

# function to add two vars

def add(x,y): return x+y

# works as expected

print(add(4,2))

# store original function in variable

add2 = add

# redefine add to call add2

def add(x,y):
    print("PROGRAM HOOK: add() called")
    return(add2(x,y))

print(add(4,2))

exit()



class Temperature:

    def __init__(self, **kwargs):

        # we store temperature in Kelvins

        # TODO: check that kwargs contains only one key/value pair

        # look at the first (lowercase) letter of first kwarg key and use that

        # the first key in kwargs (only one we use) and its first letter

        firstKey = list(kwargs.keys())[0]

        firstLetter = firstKey[0].lower()

        # if given in Kelvin(s) record

        if (firstLetter == 'k'): self.k = kwargs[firstKey]

        # Celsius

        if (firstLetter == 'c'): self.k = kwargs[firstKey]-273.15

        # Fahrenheit

        if (firstLetter == 'f'): self.k = (kwargs[firstKey]-32)/1.8-273.15

        # Rankine

        if (firstLetter == 'r'): self.k = kwargs[firstKey]*9/5



tmp = Temperature(Kelvin=20)

tmp = Temperature(Celsius=20)

print(tmp.k)
