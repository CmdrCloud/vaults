# What is functional programming?

Separation of problems. Separating our code into separate chunks to organise it
in a way that makes sense.

Also separates data and functions. Instead of combining methods and attributes,
we separate them.

In general, functional languages have an emphasis on simplicity.

Functions operate on well-defined data structures.

Make our code:

- Clear and understandable
- Easy to extend
- Easy to maintain
- Memory efficient
- Keep our code dry (no redundancy or repeating ourselves)

## Pure Functions

There's a separation between data of a program and behaviour of a program.

A pure function has two rules:

1. Given the same input it will always return the same output.
2. The function should not produce any unintended side effects. These are things
that affect the outside world.

```python
def multiplyBy2(li):
 newList = []
 for item in li:
  newList.append(item*2)
 return newList

print(multiplyBy2([1, 2, 3]))
```

It is impossible to always have pure functions because we need something to
interact with the outside world, but when you can you should use pure functions.
This is the path of least risk.

## Example with Wizard

```python
wizard = {
 'name': 'Merlin',
 'power': 50
}

def attack(character):
 ...
```

This is really just a different way of thinking.

## Useful Functions

- map, filter, zip, and reduce

## Map

```python
def multiplyBy2(item):
 return item*2

print(list(map(multiplyBy2, [1, 2, 3])))
```

or (to make an immutable parametre)

```python
myList = [1, 2, 3]

def multiplyBy2(item):
 return item*2

print(list(map(multiplyBy2, myList)))

print(myList) # immutable
```

With this, we can change myList to contain strings and change them all
to uppercase with map.

## Filter

```python
myList = [1, 2, 3]

def multiplyBy2(item):
 return item * 2

def onlyOddNumbers(item):
 return item % 2 != 0

print(list(filter(checkIfOdd, myList))) # prints [1, 3]
```

## Zip

```python
myList = [1, 2, 3]
yourList = [10, 20, 30]

def multiplyBy2(item):
 return item * 2

def onlyOddNumbers(item):
 return item % 2 != 0


print(list(zip(myList, yourList))) # prints [(1, 10), (2, 20), (3, 30)]
```

Zip couples pairs of data into an output

```python
myList = [1, 2, 3]
yourList = [10, 20, 30]
theirList = [5, 4, 3]

def multiplyBy2(item):
 return item * 2

def onlyOddNumbers(item):
 return item % 2 != 0


print(list(zip(myList, yourList, theirList))) # prints [(1, 10, 5), (2, 20, 4),
(3, 30, 3)]
```

## Reduce

```python
from functools import reduce

myList = [1, 2, 3]

def multiplyBy2(item):
 return item * 2

def onlyOddNumbers(item):
 return item % 2 != 0


print(list(reduce(, myList)))
```
