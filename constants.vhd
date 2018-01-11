-- 1. Copy this file in your project directory.
-- 2. Use: "Project -> Add/Remove Files in Project..." and add this file to your
--    project (use buttons "..." and "add" in "File name: ")
-- 3. Include this package in your modules with: USE work.constants.all;

LIBRARY ieee;
USE ieee.std_logic_1164.all;

PACKAGE constants IS 

  constant opcode_LOAD    : std_logic_vector(6 downto 0) := "0000011";
  constant opcode_MISC_MEM: std_logic_vector(6 downto 0) := "0001111";
  constant opcode_regimm  : std_logic_vector(6 downto 0) := "0010011";
  constant opcode_OP_IMM  : std_logic_vector(6 downto 0) := "0010011";
  constant opcode_AUIPC   : std_logic_vector(6 downto 0) := "0010111";
  constant opcode_STORE   : std_logic_vector(6 downto 0) := "0100011";
  constant opcode_regreg  : std_logic_vector(6 downto 0) := "0110011";
  constant opcode_OP      : std_logic_vector(6 downto 0) := "0110011";
  constant opcode_LUI     : std_logic_vector(6 downto 0) := "0110111";
  constant opcode_BRANCH  : std_logic_vector(6 downto 0) := "1100011";
  constant opcode_JALR    : std_logic_vector(6 downto 0) := "1100111";
  constant opcode_JAL     : std_logic_vector(6 downto 0) := "1101111";
  constant opcode_SYSTEM  : std_logic_vector(6 downto 0) := "1110011";
  constant opcode_ATOMIC  : std_logic_vector(6 downto 0) := "0101111";
  

  constant funct_BEQ      : std_logic_vector(2 downto 0) := "000";
  constant funct_BNE      : std_logic_vector(2 downto 0) := "001";
  constant funct_BLT      : std_logic_vector(2 downto 0) := "100";
  constant funct_BGE      : std_logic_vector(2 downto 0) := "101";
  constant funct_BLTU     : std_logic_vector(2 downto 0) := "110";
  constant funct_BGEU     : std_logic_vector(2 downto 0) := "111";

  constant funct_ADD      : std_logic_vector(2 downto 0) := "000";
  constant funct_SLL      : std_logic_vector(2 downto 0) := "001";
  constant funct_SLT      : std_logic_vector(2 downto 0) := "010";
  constant funct_SLTU     : std_logic_vector(2 downto 0) := "011";
  constant funct_XOR      : std_logic_vector(2 downto 0) := "100";
  constant funct_SRL      : std_logic_vector(2 downto 0) := "101";
  constant funct_OR       : std_logic_vector(2 downto 0) := "110";
  constant funct_AND      : std_logic_vector(2 downto 0) := "111";

END constants;
