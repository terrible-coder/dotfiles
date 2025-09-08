#!/usr/bin/python3
import sys
import random as rand

def print10(n, charset):
	print()
	for i in range(n):
		print("    ", end="")
		for j in range(n):
			idx = rand.randint(0, len(charset)-1)
			print(charset[idx], end="")
		print()
	print()

if __name__ == "__main__":
	rand.seed(30)
	n = int(sys.argv[1])
	chars = sys.argv[2:]
	print10(n, chars)


