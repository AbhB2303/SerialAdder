library ieee;
use ieee.std_logic_1164.all;

--same entity as provided for the structural code
--Sin will take on value of serial input
--clk and shift are "and" together to make gclk, which becomes the logic for the clk rising edge
--res will set the carry out flip flop to 0 and all bits of registers to 0
--Sum provides output of full adder to be shifted into the upper 4 bit register
--cout provides output for the carry in the full adder
entity Behavioral_Serial_Adder is
        port (Sin, clk, res, shift: in std_logic;
                Cout: out std_logic;
                Sum: out std_logic_vector (3 downto 0));
end Behavioral_Serial_Adder;

architecture behavioral_circuit of Behavioral_Serial_Adder is
--internal signals of the serial adder will be the same as the signals applied in the structure of each component
--the signals here are combined in the use of processes, each mimicking black boxes of the conceptual diagramm
signal gclk, Cdq, Cdd, Ain, bin, notAin, notBin, notCdq, Stmp: std_logic;
--internal signals used to assign register values within process, and apply next output logic outside of processes
signal Areg, Breg, Anext, Bnext: std_logic_vector(3 downto 0);

--beginning of architecture for behavioral logic
begin

--assignment of and operation to determine if both clock is rising edge and shift is enabled
	gclk <= shift and clk;
--not signal assignment to be used in logic of full adder
	notAin <= not Ain;
	notBin <= not Bin;
	notCdq <= not Cdq;
	
--temporary signal used to assign the value of full adder to be assigned to sum
--same logic as applied in the architecture of the structural full adder 
	Stmp <= (notAin and notBin and Cdq) or (notAin and Bin and notCdq) or (Ain and notBin and notCdq) or (Ain and Bin and Cdq);
--value of carry out of full adder assigned to value cdd of the D flip flop
--This value takes on the next output logic
	Cdd <= (Ain and Bin) or (Ain and Cdq) or (Bin and Cdq);
	
--D flip flop process
--logic mimics structural design, but makes use of sequential process with shared variables instead of port map 
	process(gclk, res)
                begin
--resets current state of D flip flop if reset is enabled
                if(res = '1') then
                cdq <= '0';
--if the clock is rising edge, next state is assigned to the current state
                elsif(gclk'event and gclk = '1') then
                cdq <= cdd;
                end if;
        end process;

--register process
process(gclk, res)
begin

--registers follow similar logic to the free running shift register demonstrated in slides 8.5 from class lectures
	if(res = '1') then
--if reset is enabled, both registers bits are set to 0 
		Areg <= "0000";
		Breg <= "0000";
--when both shift is enabled and clock is rising edge, next output logic is applied
	elsif (gclk'event and gclk = '1') then
		Areg <= Anext;
		Breg <= Bnext;
	end if;
end process;


--next output logic applied as combinational logic
--similar to the free running shift register, the value d, which in this case is the serial input,
--will be attached at the MSB, and the LSB being shifted out is assigned to Ain 
Anext <= Sin & Areg(3 downto 1);
Ain <= Areg(0);
--similarly the next output logic for the B register is a combination of the full adder output at
--the MSB and the 3 most significant bits already in the register
Bnext <= stmp & Breg(3 downto 1);
--the bit shift out is assigned to Bin
Bin <= Breg(0);
--Ain and Bin can be used as inputs for the full adder
--When the structural code makes use of port mapping, it assigns these values to a declared component
--In the behavioral code, the two signals are just internal signals that are used in the input logic
--of the full adder, which is assigned as a concurrent signal at the top because it does not need to make use
--of a clock

--lastly the external signals are assigned their proper values
--These signals can be assigned in the eact same way because they only require concurrent logic and do not make use of port mapping
Sum <= Breg; 
Cout <= cdq;
end behavioral_circuit;

