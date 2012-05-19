#!/usr/bin/python

#http://groups.yahoo.com/group/mensa_romania/message/8139
#Se da o matrice patrata M de dimensiune (NxN)
#Se cere ca pentru toate perechile de indici sa se calculeze suma tuturor
#elementelor anterioare.
#De exemplu:
#Pentru elementul (3,4) sa se calculeze suma:
#M[1,1]+M[1,2] +M[1,3]+M[ 1,4]+M[2,1]+M[2,2] +M[2,3]+M[ 2,4]+M[3,1]+M[3,2] +M[3,3]+M[ 3,4]

import sys
from math import sqrt
import time
import random

max_array = 25
aitime=time.time()
a=[[[[[(1000*random.random()) for dim1 in range(max_array)] for dim2 in range(max_array)] for dim3 in range(max_array)] for dim4 in range(max_array)] for dim5 in range(max_array)]
aftime=time.time()

#print a[10][3][22][21][5]

section=[2,23,13,22,19]
sum=0
sitime=time.time()
for i1 in range(section[0]):
for i2 in range(section[1]):
for i3 in range(section[2]):
for i4 in range(section[3]):
for i5 in range(section[4]):
sum+=a[i1][i2][i3][i4][i5]
sftime=time.time()

print "Sum of numbers = ", sum
print "Generate array in ", sftime-sitime
print "Calculate sum in ", aftime-aitime
