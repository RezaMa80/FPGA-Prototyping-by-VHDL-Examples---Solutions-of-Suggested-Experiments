## This file generates randomly 0 and 1 and stores them to "random01.txt" file

#### Parameters:
## Number of bits to generate:
puts "Enter number of bits:"
set bitCount [gets stdin]

set fileName "random01.txt"

package require fileutil

set fileOut [open $fileName w]

set counter 0

while {$counter < $bitCount} {
    incr counter 
    set bit [expr round(rand())]
    
    puts $fileOut $bit
}

close $fileOut
