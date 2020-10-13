'''
 ____ ____ ____ ____                
||C |||E |||I |||D ||               
||__|||__|||__|||__||               
|/__\|/__\|/__\|/__\|               
 ____ ____ ____ ____ ____ ____ ____ 
||U |||P |||a |||t |||r |||a |||s ||
||__|||__|||__|||__|||__|||__|||__||
|/__\|/__\|/__\|/__\|/__\|/__\|/__\|

'''


p = -+++++---++--++--++++++--++--++---++++---++--++--------------++-----------++++--3
y = -++--++---++++-----++----++--++--++--++--+++-++----------++--++----------++--++-1
t = -+++++-----++------++----++++++--++--++--++-+++----------++++++----------++++++-5
h = -++--------++------++----++--++--++--++--++--++--------------++----++----++--++-7
o = -++--------++------++----++--++---++++---++--++--------------++----++-----++++--6
n = --------------------------------------------------------------------------------8



# Imports

import matplotlib.pyplot as plt


# Operations

x = 3
y = -4.0
res = x + y

print(res)

a = 6
b = y - 1

print(a/b)


this_is_a_string = "OH NO"
print(this_is_a_string)



# Class Definition

class Point:
	def __init__(self, x_value, y_value):
		x = x_value
		y = y_value


p = Point(3, 5)


# Function Definition

def sum3():
	print(a + b + res)


# Function Call 

sum3()

# if statement

if x>43:
	x = x + 1


if 5<3:
	x = 1
elif 5==3:
	x = 2
else:
	x = 3


for i in [3, 1, 7, 65]:
	print(i)


# Lambda Calculus

lambda : 2

double_number = lambda arg1: arg1*2



# Dictionaries

example = {"23":2, "44":{ 2.0 : a, 5:{3:5} }, 6.6:2, "2": 3, "what": {}, 2: "test"}

# items()

example.items()

# setdefault()

example.setdefault("2")
print(example)

example.setdefault(666, "UPatras")
print(example)

example.setdefault("CEID")
print(example)

example.setdefault("44", 9)
print(example)

