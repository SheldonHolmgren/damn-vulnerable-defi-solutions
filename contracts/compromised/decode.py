#!/usr/bin/python

numbers = [int(n, 16) for n in input().split()]
text = "".join([chr(n) for n in numbers])
print("%s\n" % text)