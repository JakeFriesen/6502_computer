2020-05-02
Jake Friesen
Using the VASM oldstyle assembler to convert assembly to a binary output for 6502 computers:

1) open CMD and cd to this folder, and have your assembly.txt in this folder
2) run the following command:
	vasm6502_oldstyle.exe -Fbin -dotdir YourFile.txt
-Fbin: outputs a binary file
-dotdir: uses the "." directives (like .org)
The binary file is the a.out file

3) open Xgpro, put the a.out file in, and configure for the right chip (ATMEL AT28C256)
4) load the chip into the programmer, and click "program"