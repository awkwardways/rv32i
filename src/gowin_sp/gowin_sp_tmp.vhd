--Copyright (C)2014-2025 Gowin Semiconductor Corporation.
--All rights reserved.
--File Title: Template file for instantiation
--Tool Version: V1.9.12 (64-bit)
--Part Number: GW2A-LV18PG256C8/I7
--Device: GW2A-18
--Device Version: C
--Created Time: Sat Mar 28 10:46:55 2026

--Change the instance name and port connections to the signal names
----------Copy here to design--------

component Gowin_SP
    port (
        dout: out std_logic_vector(31 downto 0);
        clk: in std_logic;
        oce: in std_logic;
        ce: in std_logic;
        reset: in std_logic;
        wre: in std_logic;
        ad: in std_logic_vector(11 downto 0);
        din: in std_logic_vector(31 downto 0)
    );
end component;

your_instance_name: Gowin_SP
    port map (
        dout => dout,
        clk => clk,
        oce => oce,
        ce => ce,
        reset => reset,
        wre => wre,
        ad => ad,
        din => din
    );

----------Copy end-------------------
