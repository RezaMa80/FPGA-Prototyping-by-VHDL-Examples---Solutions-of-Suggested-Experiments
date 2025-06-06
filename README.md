# FPGA-Prototyping-by-VHDL-Examples---Solutions-of-Suggested-Experiments
Each chapter of the book FPGA Prototyping by VHDL Examples introduces some exercises in a section called Suggested Experiments. In this repository I provide solution of exercises that require VHDL code.

I used ISE Project Navigator version 14.7 to synthesize and implement these codes and ModelSim to simulate testbenches.
The target device for implemntions is Xilinx Spartan 6 family (xc6slx9-2TQG144).

When using IF-ELSE-GENERATE statements, ISE Project Navigator cannot recognize port mapped components.
Because of this you should use `vcom -explicit  -2008 [Component].vhd` to compile not compiled components.

## Provided Files
* .vhd

  VHDL codes that can be for synthesis and implemention, testbenchs or libraries.
* Heirarchy.txt

  Shows heirarchy of the .vhd files.
* Create2008.do

  For simulation, ModelSim uses a .fdo file that is automaticly created by ISE Project Navigator.
  ISE Project Navigator creates .fdo file by assuming that the VHDL codes are 93 version and this will cause problems when using VHDL 2008.
  Using `do Create2008.do` in ModelSim will create a .fdo for 2008 versions.  `do [Testbench].2008.fdo` runs the new created file.
* GeneratorRandom01.do

  Some testbenches read the file "random01.txt" to use randomly generated zeros and ones. To create "random01.txt" use `do GeneratorRandom01.do` then enter the number of bits to generate.

## Useful Results
Durring the completion this repository, I wrote some usefull general compenets or code templats which can be reused in other projects, I list them below (Started from chapter 5). I link them later:
* [Simple Testbench Template](https://github.com/RezaMa80/FPGA-Prototyping-by-VHDL-Examples---Solutions-of-Suggested-Experiments/blob/main/Chapter5/E2/TB_debouncer.vhd)
* Combinational testbench templet
* Sequential testbench templet
* UART component
* Utilities library
