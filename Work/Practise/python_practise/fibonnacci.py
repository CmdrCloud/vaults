x = 0
a = 0
b = 1
c = 0

print("Enter the amount of sequences the fib series should have.")
x = int(input())


def check(x):
    if x == 0:
        print("Pick a higher number")
        return False

    if x == 1:
        print(0)
        return True
    else:
        print("\n")
        print(0)
        print("\n")
        print(1)
        print("\n")
        return True


if check(x):
    for i in range(0, x):
        c = a + b
        print(f"{c} \n")

        a = b
        b = c
