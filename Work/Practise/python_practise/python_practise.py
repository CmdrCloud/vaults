words = ["brilliant", "brave", "brat"]

for word in words:
    for letter in word:
        if letter != word[letter+1]:
            printf({letter} + "This is the final letter")
