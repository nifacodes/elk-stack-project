#!/bin/bash
# To easily find the roulette dealer at a specific time

# for all the other scrips I used:
# cat 0310_Dealer_schedule | grep "8:00:00 AM" >> Notes_Dealer_Analysis
# where I changed the cat and grep arguments according to file and time 

cat $1_Dealer_schedule | grep "$2"






