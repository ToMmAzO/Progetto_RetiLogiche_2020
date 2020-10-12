-----------------------------------------------------------------------------------------------------
--                                                                                  
--  PROGETTO RETI LOGICHE 2019/2020 - INGEGNERIA INFORMATICA - Sezione Prof. Gianluca Palermo
--
--  Marco Riva (Codice Persona 10605051 - Matricola 889593)
--  Tommaso Pozzi (Codice Persona 10572283 - Matricola 891456)
-- 
--
------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

--Componente da descrivere
entity project_reti_logiche is
    Port (
        i_clk     : in std_logic;
        i_start   : in std_logic;
        i_rst     : in std_logic;
        i_data    : in std_logic_vector(7 downto 0);
        o_address : out std_logic_vector(15 downto 0);
        o_done    : out std_logic;
        o_en      : out std_logic;
        o_we      : out std_logic;
        o_data    : out std_logic_vector(7 downto 0)
    );
end project_reti_logiche;
 
architecture Behavioral of project_reti_logiche is

	--Viene creato un tipo per rappresentare i possibili stati del componente
    type state_type is (IDLE, FETCH_CONST, WAIT_RAM, GET_CONST, COMPARE, CALC, WRITE_OUT, DONE);
    signal state_reg, state_next : state_type;
   
    signal o_done_next, o_en_next, o_we_next : std_logic := '0';
    signal o_data_next : std_logic_vector(7 downto 0) := "00000000";
    signal o_address_next : std_logic_vector(15 downto 0) := "0000000000000000";
   
    signal got_addr_reg, got_wz_reg, got_addr_next, got_wz_next: boolean := false;
   
    signal wz_reg, wz_next : integer range 0 to 124 := 0;									--Segnali che contengono l'indirizzo delle Working Zone
    signal in_addr_reg, in_addr_next: integer range 0 to 127 := 0;							--Segnali che contengono l'indirizzo dell'ADDR
 
	signal wz_bit_reg, wz_bit_next : integer range 0 to 1 := 0;
	signal wz_num_reg, wz_num_next : integer range 0 to 7 := 0;
	signal wz_offset_reg, wz_offset_next : integer range 0 to 8 := 0;
 
    signal out_addr_reg, out_addr_next : std_logic_vector(7 downto 0) := "00000000";		--Segnali che contengono l'indirizzo codificato
   
    signal address_reg, address_next : std_logic_vector(15 downto 0) := "0000000000000001";	--Segnali che contengono l'indirizzo di lettura attuale della RAM
 
begin
    process (i_clk, i_rst)
    begin
        if (i_rst = '1') then		--Controllo il segnale di reset
            got_addr_reg <= false;		--Inizializzazione variabili
            got_wz_reg <= false;
           
            wz_reg <= 0;
            in_addr_reg <= 0;
			
			wz_bit_reg <= 0;
			wz_num_reg <= 0;
			wz_offset_reg <= 0;
           
            out_addr_reg <= "00000000";
           
            address_reg <= "0000000000000001";
           
            state_reg <= IDLE;
        elsif (i_clk'event and i_clk='1') then		--Sincronizzazione sul fronte di salita del clock
            o_done <= o_done_next;		
            o_en <= o_en_next;
            o_we <= o_we_next;
            o_data <= o_data_next;
            o_address <= o_address_next;
           
            got_addr_reg <= got_addr_next;
            got_wz_reg <= got_wz_next;
           
            wz_reg <= wz_next;
            in_addr_reg <= in_addr_next;
			
			wz_bit_reg <= wz_bit_next;
			wz_num_reg <= wz_num_next;
			wz_offset_reg <= wz_offset_next;
           
            out_addr_reg <= out_addr_next;
           
            address_reg <= address_next;
           
            state_reg <= state_next;
        end if;
    end process;
 
process(state_reg, i_data, i_start, wz_reg, in_addr_reg, wz_bit_reg, wz_num_reg, wz_offset_reg, out_addr_reg, address_reg, got_addr_reg, got_wz_reg)
    
	variable offset : std_logic_vector(3 downto 0) := "0000";
	
	begin
        o_done_next <= '0';		--Inizializzazione variabili
        o_en_next <= '0';
        o_we_next <= '0';
        o_data_next <= "00000000";
        o_address_next <= "0000000000000000";
       
        got_addr_next <= got_addr_reg;
        got_wz_next <= got_wz_reg;
       
        wz_next <= wz_reg;
        in_addr_next <= in_addr_reg;
		
		wz_bit_next <= wz_bit_reg;
		wz_num_next <= wz_num_reg;
		wz_offset_next <= wz_offset_reg;
       
        out_addr_next <= out_addr_reg;
       
        address_next <= address_reg;
       
        state_next <= state_reg;
       
        case state_reg is
            when IDLE =>
                if (i_start = '1') then		--Attendo il segnale di start
                    state_next <= FETCH_CONST;
                end if;
               
            when FETCH_CONST =>
                o_en_next <= '1';
                o_we_next <= '0';
               
                if (not got_addr_reg) then
                    o_address_next <= "0000000000001000";
                elsif (not got_wz_reg) then
                    o_address_next <= "0000000000000000";
                else
                    o_address_next <= "0000000000000000";
                end if;
               
                state_next <= WAIT_RAM;
               
            when WAIT_RAM =>		--Stato di attesa che la memoria invii i dati 
                if (got_addr_reg and got_wz_reg) then
                    state_next <= COMPARE;
                else
                    state_next <= GET_CONST;
                end if;
               
            when GET_CONST =>
                if (not got_addr_reg) then		--LETTURA ADDR
                    in_addr_next <= conv_integer(i_data);
                    got_addr_next <= true;
                   
                    state_next <= FETCH_CONST;
                elsif (not got_wz_reg) then		--LETTURA WORKING ZONE
                    wz_next <= conv_integer(i_data);
                    got_wz_next <= true;
                   
                    state_next <= COMPARE;
                end if;
               
            when COMPARE =>
                if(in_addr_reg >= wz_reg and in_addr_reg < (wz_reg + 4)) then		--Confronto tra ADDR e WZ
					wz_bit_next <= 1;		--ADDR appartiene alla Working Zone
					wz_num_next <= conv_integer(address_reg) - 1;
					wz_offset_next <= in_addr_reg - wz_reg;
                    state_next <= CALC;
                elsif (address_reg < 8) then		--Non ho finito le WZ
                    o_en_next <= '1';
                    o_we_next <= '0';
                    got_wz_next <= false;
                    o_address_next <= address_reg;
                    address_next <= address_reg + "0000000000000001";
                   
                    state_next <= WAIT_RAM;
                else
                    state_next <= CALC;		--ADDR NON appartiene alla Working Zone
                end if;           
           
            when CALC =>
                if(wz_bit_reg = 1) then		--ADDR in WZ
					case wz_offset_reg is		--Calcolo WZ_OFFSET
							when 0 =>
								offset := "0001";
							when 1 =>
								offset := "0010";
							when 2 =>
								offset := "0100";
							when 3 =>
								offset := "1000";
							when others =>
								offset := "0000";
							end case;
					out_addr_next <= std_logic_vector(to_unsigned(wz_bit_reg,1)) & std_logic_vector(to_unsigned(wz_num_reg,3)) & offset;		--Concatenazione tra WZ_BIT, WZ_NUM e WZ_OFFSET
                else		--ADDR non presente in nessuna Working Zone
                    out_addr_next <= std_logic_vector(to_unsigned(in_addr_reg, 8));		--Concatenazione tra WZ_BIT e ADDR
                end if;
               
                state_next <= WRITE_OUT;
               
            when WRITE_OUT =>		--Scrittura in memoria
                o_en_next <= '1';
                o_we_next <= '1';
                o_address_next <= "0000000000001001";
                o_data_next <= out_addr_reg;
                o_done_next <= '1';
               
                state_next <= DONE;
               
            when DONE =>		--Stato che alza il segnale di done
                if (i_start = '0') then
                    got_addr_next <= false;
                    got_wz_next <= false;
               
                    wz_next <= 0;
                    in_addr_next <= 0;
					
					wz_bit_next <= 0;
					wz_num_next <= 0;
					wz_offset_next <= 0;
                   
                    out_addr_next <= "00000000";
                   
                    address_next <= "0000000000000001";
                   
                    state_next <= IDLE;		--Riporta il componente allo stato iniziale pronto per eseguire un'altra operazione
                end if;
        end case;
    end process;          
end Behavioral;