library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity CC_2023 is
    Port (
        clk : in STD_LOGIC; -- Reloj interno de la placa
        reset : in STD_LOGIC; -- Señal de reset
        Din0 : in STD_LOGIC; -- Entrada pin 0
        Din1 : in STD_LOGIC; -- Entrada pin 1
        Din2 : in STD_LOGIC; -- Entrada pin 2
        Din3 : in STD_LOGIC; -- Entrada  pin 3
        EnBlink : in STD_LOGIC; -- Entrada para controlar la alternancia
        Dout0 : out STD_LOGIC; -- Salida pin 0
        Dout1 : out STD_LOGIC; -- Salida  pin 1
        Dout2 : out STD_LOGIC; -- Salida pin 2
        Dout3 : out STD_LOGIC; -- Salida pin 3
        Dout4 : out STD_LOGIC; -- Salida  pin 4
        Dout5 : out STD_LOGIC; -- Salida pin 5
        Dout6 : out STD_LOGIC; -- Salida pin 6
        Dout7 : out STD_LOGIC -- Salida pin 7
    );
end CC_2023 ;

architecture Behavioral of CC_2023  is
	 
    signal valor_multiplicador : STD_LOGIC_VECTOR (7 downto 0); -- Valor multiplicado por 17
    signal estado_pulso : STD_LOGIC := '0'; -- Estado para controlar la alternancia
    signal ultimo_pulso : STD_LOGIC := '0'; -- Guarda el último estado de EnBlink
    constant periodo_pulso : integer := 50000000; -- Periodo para alternar a 2 Hz (50 MHz / 25000000)
    signal contador_pulso : integer range 0 to periodo_pulso := 0; -- Contador para la frecuencia de 2 Hz

 begin
    -- Proceso para realizar la multiplicación por 17
    mult:process(clk, reset)
    begin
        if reset = '1' then
            valor_multiplicador  <= (others => '0'); -- Reinicia el valor multiplicado a 0
        elsif rising_edge(clk) then
            valor_multiplicador  <= Din0 & Din1 & Din2 & Din3 & "0000"; -- Añade cuatro ceros a la entrada para multiplicar por 17
            valor_multiplicador <= valor_multiplicador  + Din0 & Din1 & Din2 & Din3 & "0000"; -- Realiza la multiplicación
        end if;
    end process mult;

    -- Proceso para controlar la alternancia de Dout
   intermitencia:process(clk, reset)
    begin
        if reset = '1' then
            estado_pulso <= '0'; -- Reinicia el estado de alternancia a 0
            ultimo_pulso <= '0'; -- Reinicia el último estado de EnBlink a 0
            contador_pulso <= 0; -- Reinicia el contador
        elsif rising_edge(clk) then
            if EnBlink = '1' and ultimo_pulso = '0' then -- Si recibimos un pulso positivo
                estado_pulso <= not estado_pulso; -- Cambia el estado de alternancia
            end if;
            ultimo_pulso<= EnBlink; -- Actualiza el último estado de EnBlink

            if contador_pulso = periodo_pulso then -- Si se alcanza el periodo de 2 Hz
                contador_pulso <= 0; -- Reinicia el contador
                if estado_pulso = '1' then -- Si el estado de alternancia es '1'
                    Dout0 <= '0'; Dout1 <= '0'; Dout2 <= '0'; Dout3 <= '0'; Dout4 <= '0'; Dout5 <= '0'; Dout6 <= '0'; Dout7 <= '0'; -- Muestra 0x00
                else
                    Dout0 <= valor_multiplicador(0); 
                    Dout1 <= valor_multiplicador(1); 
                    Dout2 <= valor_multiplicador(2); 
                    Dout3 <= valor_multiplicador(3);
                    Dout4 <= valor_multiplicador(4); 
                    Dout5 <= valor_multiplicador(5); 
                    Dout6 <= valor_multiplicador(6); 
                    Dout7 <= valor_multiplicador(7); -- Muestra el resultado de la multiplicación
                end if;
            else
             contador_pulso <= contador_pulso + 1; -- Incrementa el contador
            end if;
        end if;
    end process intermitencia;
end Behavioral;
