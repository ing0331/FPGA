-- -------------------------------------------------------------
-- 
-- File Name: hdlsrc\CornerDetectionHDL\LineBuffer_block1.vhd
-- Created: 2023-06-21 14:30:33
-- 
-- Generated by MATLAB 9.14 and HDL Coder 4.1
-- 
-- -------------------------------------------------------------


-- -------------------------------------------------------------
-- 
-- Module: LineBuffer_block1
-- Source Path: CornerDetectionHDL/HDL Corner Algorithm/Corner Detector/HarrisCore/HarrisFilterB/LineBuffer
-- Hierarchy Level: 4
-- 
-- -------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.HDL_Corner_Algorithm_pkg.ALL;

ENTITY LineBuffer_block1 IS
  PORT( clk                               :   IN    std_logic;
        reset                             :   IN    std_logic;
        enb                               :   IN    std_logic;
        dataIn                            :   IN    std_logic_vector(19 DOWNTO 0);  -- sfix20
        hStartIn                          :   IN    std_logic;
        hEndIn                            :   IN    std_logic;
        vStartIn                          :   IN    std_logic;
        vEndIn                            :   IN    std_logic;
        validIn                           :   IN    std_logic;
        dataOut                           :   OUT   vector_of_std_logic_vector20(0 TO 4);  -- sfix20 [5]
        validOut                          :   OUT   std_logic;
        processDataOut                    :   OUT   std_logic
        );
END LineBuffer_block1;


ARCHITECTURE rtl OF LineBuffer_block1 IS

  -- Component Declarations
  COMPONENT InputControlValidation_block1
    PORT( clk                             :   IN    std_logic;
          reset                           :   IN    std_logic;
          enb                             :   IN    std_logic;
          hStartIn                        :   IN    std_logic;
          hEndIn                          :   IN    std_logic;
          vStartIn                        :   IN    std_logic;
          vEndIn                          :   IN    std_logic;
          validIn                         :   IN    std_logic;
          hStartOut                       :   OUT   std_logic;
          hEndOut                         :   OUT   std_logic;
          vStartOut                       :   OUT   std_logic;
          vEndOut                         :   OUT   std_logic;
          validOut                        :   OUT   std_logic;
          InBetweenOut                    :   OUT   std_logic
          );
  END COMPONENT;

  COMPONENT LineSpaceAverager_block1
    PORT( clk                             :   IN    std_logic;
          reset                           :   IN    std_logic;
          enb                             :   IN    std_logic;
          InBetween                       :   IN    std_logic;
          InLine                          :   IN    std_logic;
          LineSpaceAverage                :   OUT   std_logic_vector(15 DOWNTO 0)  -- ufix16
          );
  END COMPONENT;

  COMPONENT DATA_MEMORY_block1
    PORT( clk                             :   IN    std_logic;
          reset                           :   IN    std_logic;
          enb                             :   IN    std_logic;
          Unloading                       :   IN    std_logic;
          pixelIn                         :   IN    std_logic_vector(19 DOWNTO 0);  -- sfix20
          hStartIn                        :   IN    std_logic;
          hEndIn                          :   IN    std_logic;
          validIn                         :   IN    std_logic;
          popEn                           :   IN    std_logic_vector(1 DOWNTO 0);  -- ufix2
          dataVectorOut                   :   OUT   vector_of_std_logic_vector20(0 TO 4);  -- sfix20 [5]
          popOut                          :   OUT   std_logic;
          AllAtEnd                        :   OUT   std_logic
          );
  END COMPONENT;

  COMPONENT LineInfoStore_block3
    PORT( clk                             :   IN    std_logic;
          reset                           :   IN    std_logic;
          enb                             :   IN    std_logic;
          hStartIn                        :   IN    std_logic;
          Unloading                       :   IN    std_logic;
          frameEnd                        :   IN    std_logic;
          lineStartV                      :   OUT   std_logic_vector(1 DOWNTO 0)  -- ufix2
          );
  END COMPONENT;

  COMPONENT DataReadController_block1
    PORT( clk                             :   IN    std_logic;
          reset                           :   IN    std_logic;
          enb                             :   IN    std_logic;
          hStartIn                        :   IN    std_logic;
          hEndIn                          :   IN    std_logic;
          vStartIn                        :   IN    std_logic;
          vEndIn                          :   IN    std_logic;
          validIn                         :   IN    std_logic;
          lineStartV                      :   IN    std_logic_vector(1 DOWNTO 0);  -- ufix2
          lineAverage                     :   IN    std_logic_vector(15 DOWNTO 0);  -- ufix16
          AllEndOfLine                    :   IN    std_logic;
          BlankCount                      :   IN    std_logic_vector(15 DOWNTO 0);  -- ufix16
          frameStart                      :   IN    std_logic;
          hStartR                         :   OUT   std_logic;
          hEndR                           :   OUT   std_logic;
          vEndR                           :   OUT   std_logic;
          validR                          :   OUT   std_logic;
          outputData                      :   OUT   std_logic;
          Unloading                       :   OUT   std_logic;
          blankCountEn                    :   OUT   std_logic;
          Running                         :   OUT   std_logic
          );
  END COMPONENT;

  COMPONENT LineInfoStore_block4
    PORT( clk                             :   IN    std_logic;
          reset                           :   IN    std_logic;
          enb                             :   IN    std_logic;
          hStartIn                        :   IN    std_logic;
          hEndIn                          :   IN    std_logic;
          validIn                         :   IN    std_logic;
          dumpControl                     :   IN    std_logic;
          preProcess                      :   IN    std_logic;
          PrePadFlag                      :   OUT   std_logic;
          OnLineFlag                      :   OUT   std_logic;
          PostPadFlag                     :   OUT   std_logic;
          DumpingFlag                     :   OUT   std_logic;
          BlankingFlag                    :   OUT   std_logic;
          hStartOut                       :   OUT   std_logic;
          hEndOut                         :   OUT   std_logic;
          validOut                        :   OUT   std_logic
          );
  END COMPONENT;

  COMPONENT PaddingController_block1
    PORT( clk                             :   IN    std_logic;
          reset                           :   IN    std_logic;
          enb                             :   IN    std_logic;
          PrePadFlag                      :   IN    std_logic;
          OnLineFlag                      :   IN    std_logic;
          alphaPostPadFlag                :   IN    std_logic;
          DumpingFlag                     :   IN    std_logic;
          BlankingFlag                    :   IN    std_logic;
          processData                     :   OUT   std_logic;
          countReset                      :   OUT   std_logic;
          countEn                         :   OUT   std_logic;
          dumpControl                     :   OUT   std_logic;
          PrePadding                      :   OUT   std_logic
          );
  END COMPONENT;

  COMPONENT GateProcessData_block1
    PORT( clk                             :   IN    std_logic;
          reset                           :   IN    std_logic;
          enb                             :   IN    std_logic;
          processDataIn                   :   IN    std_logic;
          validIn                         :   IN    std_logic;
          dumping                         :   IN    std_logic;
          outputData                      :   IN    std_logic;
          processData                     :   OUT   std_logic;
          dumpOrValid                     :   OUT   std_logic
          );
  END COMPONENT;

  COMPONENT Horizontal_Padder_block1
    PORT( clk                             :   IN    std_logic;
          reset                           :   IN    std_logic;
          enb                             :   IN    std_logic;
          dataVectorIn                    :   IN    vector_of_std_logic_vector20(0 TO 4);  -- sfix20 [5]
          horPadCount                     :   IN    std_logic_vector(10 DOWNTO 0);  -- ufix11
          padShift                        :   IN    std_logic;
          dataVector                      :   OUT   vector_of_std_logic_vector20(0 TO 4)  -- sfix20 [5]
          );
  END COMPONENT;

  COMPONENT Vertical_Padding_Counter_block1
    PORT( clk                             :   IN    std_logic;
          reset                           :   IN    std_logic;
          enb                             :   IN    std_logic;
          frameEnd                        :   IN    std_logic;
          unloading                       :   IN    std_logic;
          running                         :   IN    std_logic;
          lineStart                       :   IN    std_logic;
          VCount                          :   OUT   std_logic_vector(10 DOWNTO 0)  -- ufix11
          );
  END COMPONENT;

  COMPONENT Vertical_Padder_block1
    PORT( dataVectorIn                    :   IN    vector_of_std_logic_vector20(0 TO 4);  -- sfix20 [5]
          verPadCount                     :   IN    std_logic_vector(10 DOWNTO 0);  -- ufix11
          dataVectorOut                   :   OUT   vector_of_std_logic_vector20(0 TO 4)  -- sfix20 [5]
          );
  END COMPONENT;

  -- Component Configuration Statements
  FOR ALL : InputControlValidation_block1
    USE ENTITY work.InputControlValidation_block1(rtl);

  FOR ALL : LineSpaceAverager_block1
    USE ENTITY work.LineSpaceAverager_block1(rtl);

  FOR ALL : DATA_MEMORY_block1
    USE ENTITY work.DATA_MEMORY_block1(rtl);

  FOR ALL : LineInfoStore_block3
    USE ENTITY work.LineInfoStore_block3(rtl);

  FOR ALL : DataReadController_block1
    USE ENTITY work.DataReadController_block1(rtl);

  FOR ALL : LineInfoStore_block4
    USE ENTITY work.LineInfoStore_block4(rtl);

  FOR ALL : PaddingController_block1
    USE ENTITY work.PaddingController_block1(rtl);

  FOR ALL : GateProcessData_block1
    USE ENTITY work.GateProcessData_block1(rtl);

  FOR ALL : Horizontal_Padder_block1
    USE ENTITY work.Horizontal_Padder_block1(rtl);

  FOR ALL : Vertical_Padding_Counter_block1
    USE ENTITY work.Vertical_Padding_Counter_block1(rtl);

  FOR ALL : Vertical_Padder_block1
    USE ENTITY work.Vertical_Padder_block1(rtl);

  -- Signals
  SIGNAL intdelay_reg                     : std_logic_vector(0 TO 2);  -- ufix1 [3]
  SIGNAL hStartInD                        : std_logic;
  SIGNAL intdelay_reg_1                   : std_logic_vector(0 TO 2);  -- ufix1 [3]
  SIGNAL hEndInD                          : std_logic;
  SIGNAL intdelay_reg_2                   : std_logic_vector(0 TO 2);  -- ufix1 [3]
  SIGNAL vStartInD                        : std_logic;
  SIGNAL intdelay_reg_3                   : std_logic_vector(0 TO 2);  -- ufix1 [3]
  SIGNAL vEndInD                          : std_logic;
  SIGNAL intdelay_reg_4                   : std_logic_vector(0 TO 2);  -- ufix1 [3]
  SIGNAL vEndInD_1                        : std_logic;
  SIGNAL hStartV                          : std_logic;
  SIGNAL hEndV                            : std_logic;
  SIGNAL vStartV                          : std_logic;
  SIGNAL vEndV                            : std_logic;
  SIGNAL validInV                         : std_logic;
  SIGNAL InBetween                        : std_logic;
  SIGNAL hStartVREG                       : std_logic;
  SIGNAL hEndV_1                          : std_logic;
  SIGNAL vStartV_1                        : std_logic;
  SIGNAL intdelay_reg_5                   : std_logic_vector(0 TO 1);  -- ufix1 [2]
  SIGNAL vEndREG                          : std_logic;
  SIGNAL validInV_1                       : std_logic;
  SIGNAL InBetweenREG                     : std_logic;
  SIGNAL LineAverage                      : std_logic_vector(15 DOWNTO 0);  -- ufix16
  SIGNAL LineAverage_unsigned             : unsigned(15 DOWNTO 0);  -- ufix16
  SIGNAL ConstOne                         : unsigned(15 DOWNTO 0);  -- ufix16
  SIGNAL LineAveragePlus                  : unsigned(15 DOWNTO 0);  -- ufix16
  SIGNAL LineAverageREG                   : unsigned(15 DOWNTO 0);  -- ufix16
  SIGNAL dataIn_signed                    : signed(19 DOWNTO 0);  -- sfix20
  SIGNAL intdelay_reg_6                   : vector_of_signed20(0 TO 3);  -- sfix20 [4]
  SIGNAL dataInREG                        : signed(19 DOWNTO 0);  -- sfix20
  SIGNAL BooleanZero                      : unsigned(1 DOWNTO 0);  -- ufix2
  SIGNAL hStartR                          : std_logic;
  SIGNAL blankCountEn                     : std_logic;
  SIGNAL BlankingCount                    : unsigned(15 DOWNTO 0);  -- ufix16
  SIGNAL LineStartV                       : std_logic_vector(1 DOWNTO 0);  -- ufix2
  SIGNAL LineStartV_unsigned              : unsigned(1 DOWNTO 0);  -- ufix2
  SIGNAL unloading                        : std_logic;
  SIGNAL popEn                            : unsigned(1 DOWNTO 0);  -- ufix2
  SIGNAL validR                           : std_logic;
  SIGNAL validRREG                        : std_logic;
  SIGNAL hEndR                            : std_logic;
  SIGNAL hEndRREG                         : std_logic;
  SIGNAL hStartDRC                        : std_logic;
  SIGNAL DataMemVector                    : vector_of_std_logic_vector20(0 TO 4);  -- ufix20 [5]
  SIGNAL popReg                           : std_logic;
  SIGNAL AllEndOfLine                     : std_logic;
  SIGNAL AllEndOfLineREG                  : std_logic;
  SIGNAL vEndR                            : std_logic;
  SIGNAL vEndRREG                         : std_logic;
  SIGNAL EndOrStart                       : std_logic;
  SIGNAL outputData                       : std_logic;
  SIGNAL Running                          : std_logic;
  SIGNAL outputDataREG                    : std_logic;
  SIGNAL constZero                        : vector_of_signed20(0 TO 4);  -- sfix20 [5]
  SIGNAL runOrUnload                      : std_logic;
  SIGNAL intdelay_reg_7                   : std_logic_vector(0 TO 1);  -- ufix1 [2]
  SIGNAL hEndRDT                          : std_logic;
  SIGNAL dumpControl                      : std_logic;
  SIGNAL preProcess                       : std_logic;
  SIGNAL PrePadFlag                       : std_logic;
  SIGNAL OnLineFlag                       : std_logic;
  SIGNAL PostPadFlag                      : std_logic;
  SIGNAL DumpingFlag                      : std_logic;
  SIGNAL BlankingFlag                     : std_logic;
  SIGNAL hStartOutFG                      : std_logic;
  SIGNAL hEndOutFG                        : std_logic;
  SIGNAL validOutFG                       : std_logic;
  SIGNAL processDataPC                    : std_logic;
  SIGNAL countResetHC                     : std_logic;
  SIGNAL countEnHC                        : std_logic;
  SIGNAL processDataGated                 : std_logic;
  SIGNAL dumpOrControl                    : std_logic;
  SIGNAL processDataGatedD                : std_logic;
  SIGNAL processDataGatedRU               : std_logic;
  SIGNAL intdelay_reg_8                   : std_logic_vector(0 TO 1);  -- ufix1 [2]
  SIGNAL processDataP                     : std_logic;
  SIGNAL outputProcess                    : std_logic;
  SIGNAL padShift                         : std_logic;
  SIGNAL DataMemVector_signed             : vector_of_signed20(0 TO 4);  -- sfix20 [5]
  SIGNAL countEnHC_1                      : std_logic;
  SIGNAL horPadCount                      : unsigned(10 DOWNTO 0);  -- ufix11
  SIGNAL DataMemVectorREG                 : vector_of_signed20(0 TO 4);  -- sfix20 [5]
  SIGNAL DataMemVectorREG_1               : vector_of_std_logic_vector20(0 TO 4);  -- ufix20 [5]
  SIGNAL horPadCountREG                   : unsigned(10 DOWNTO 0);  -- ufix11
  SIGNAL DataMemVectorPadded              : vector_of_std_logic_vector20(0 TO 4);  -- ufix20 [5]
  SIGNAL VerCountOut                      : std_logic_vector(10 DOWNTO 0);  -- ufix11
  SIGNAL verPadOut                        : vector_of_std_logic_vector20(0 TO 4);  -- ufix20 [5]
  SIGNAL verPadOut_signed                 : vector_of_signed20(0 TO 4);  -- sfix20 [5]
  SIGNAL verPadD                          : vector_of_signed20(0 TO 4);  -- sfix20 [5]
  SIGNAL dataSigOut                       : vector_of_signed20(0 TO 4);  -- sfix20 [5]
  SIGNAL dataSigPreOD                     : vector_of_signed20(0 TO 4);  -- sfix20 [5]
  SIGNAL dataOut_tmp                      : vector_of_signed20(0 TO 4);  -- sfix20 [5]
  SIGNAL ctrlOutZero                      : std_logic;
  SIGNAL reg_switch_delay                 : std_logic;  -- ufix1
  SIGNAL hEndGate                         : std_logic;
  SIGNAL hEndGateN                        : std_logic;
  SIGNAL validFGG                         : std_logic;
  SIGNAL intdelay_reg_9                   : std_logic_vector(0 TO 1);  -- ufix1 [2]
  SIGNAL validRPre                        : std_logic;
  SIGNAL validRD                          : std_logic;
  SIGNAL hEndFGG                          : std_logic;
  SIGNAL intdelay_reg_10                  : std_logic_vector(0 TO 2);  -- ufix1 [3]
  SIGNAL hEndRD                           : std_logic;
  SIGNAL validRDEnd                       : std_logic;
  SIGNAL validP                           : std_logic;
  SIGNAL validOD                          : std_logic;
  SIGNAL processDataOD                    : std_logic;

BEGIN
  u_INPUT_CONTROL_VALIDATION : InputControlValidation_block1
    PORT MAP( clk => clk,
              reset => reset,
              enb => enb,
              hStartIn => hStartInD,
              hEndIn => hEndInD,
              vStartIn => vStartInD,
              vEndIn => vEndInD,
              validIn => vEndInD_1,
              hStartOut => hStartV,
              hEndOut => hEndV,
              vStartOut => vStartV,
              vEndOut => vEndV,
              validOut => validInV,
              InBetweenOut => InBetween
              );

  u_LineSpaceAverager : LineSpaceAverager_block1
    PORT MAP( clk => clk,
              reset => reset,
              enb => enb,
              InBetween => InBetweenREG,
              InLine => hStartVREG,
              LineSpaceAverage => LineAverage  -- ufix16
              );

  u_DATA_MEMORY : DATA_MEMORY_block1
    PORT MAP( clk => clk,
              reset => reset,
              enb => enb,
              Unloading => unloading,
              pixelIn => std_logic_vector(dataInREG),  -- sfix20
              hStartIn => hStartDRC,
              hEndIn => hEndRREG,
              validIn => validRREG,
              popEn => std_logic_vector(popEn),  -- ufix2
              dataVectorOut => DataMemVector,  -- sfix20 [5]
              popOut => popReg,
              AllAtEnd => AllEndOfLine
              );

  u_LINE_INFO_STORE : LineInfoStore_block3
    PORT MAP( clk => clk,
              reset => reset,
              enb => enb,
              hStartIn => hStartDRC,
              Unloading => unloading,
              frameEnd => EndOrStart,
              lineStartV => LineStartV  -- ufix2
              );

  u_DATA_READ_CONTROLLER : DataReadController_block1
    PORT MAP( clk => clk,
              reset => reset,
              enb => enb,
              hStartIn => hStartVREG,
              hEndIn => hEndV_1,
              vStartIn => vStartV_1,
              vEndIn => vEndREG,
              validIn => validInV_1,
              lineStartV => LineStartV,  -- ufix2
              lineAverage => std_logic_vector(LineAverageREG),  -- ufix16
              AllEndOfLine => AllEndOfLineREG,
              BlankCount => std_logic_vector(BlankingCount),  -- ufix16
              frameStart => vStartIn,
              hStartR => hStartR,
              hEndR => hEndR,
              vEndR => vEndR,
              validR => validR,
              outputData => outputData,
              Unloading => unloading,
              blankCountEn => blankCountEn,
              Running => Running
              );

  u_State_Transition_Flag_Gen : LineInfoStore_block4
    PORT MAP( clk => clk,
              reset => reset,
              enb => enb,
              hStartIn => hStartDRC,
              hEndIn => hEndRDT,
              validIn => validRREG,
              dumpControl => dumpControl,
              preProcess => preProcess,
              PrePadFlag => PrePadFlag,
              OnLineFlag => OnLineFlag,
              PostPadFlag => PostPadFlag,
              DumpingFlag => DumpingFlag,
              BlankingFlag => BlankingFlag,
              hStartOut => hStartOutFG,
              hEndOut => hEndOutFG,
              validOut => validOutFG
              );

  u_Padding_Controller : PaddingController_block1
    PORT MAP( clk => clk,
              reset => reset,
              enb => enb,
              PrePadFlag => PrePadFlag,
              OnLineFlag => OnLineFlag,
              alphaPostPadFlag => PostPadFlag,
              DumpingFlag => DumpingFlag,
              BlankingFlag => BlankingFlag,
              processData => processDataPC,
              countReset => countResetHC,
              countEn => countEnHC,
              dumpControl => dumpControl,
              PrePadding => preProcess
              );

  u_Gate_Process_Data : GateProcessData_block1
    PORT MAP( clk => clk,
              reset => reset,
              enb => enb,
              processDataIn => processDataPC,
              validIn => validRREG,
              dumping => dumpControl,
              outputData => outputData,
              processData => processDataGated,
              dumpOrValid => dumpOrControl
              );

  u_Horizontal_Padder : Horizontal_Padder_block1
    PORT MAP( clk => clk,
              reset => reset,
              enb => enb,
              dataVectorIn => DataMemVectorREG_1,  -- sfix20 [5]
              horPadCount => std_logic_vector(horPadCountREG),  -- ufix11
              padShift => padShift,
              dataVector => DataMemVectorPadded  -- sfix20 [5]
              );

  u_Vertical_Counter : Vertical_Padding_Counter_block1
    PORT MAP( clk => clk,
              reset => reset,
              enb => enb,
              frameEnd => vStartIn,
              unloading => unloading,
              running => Running,
              lineStart => hStartR,
              VCount => VerCountOut  -- ufix11
              );

  u_Vertical_Padder : Vertical_Padder_block1
    PORT MAP( dataVectorIn => DataMemVectorPadded,  -- sfix20 [5]
              verPadCount => VerCountOut,  -- ufix11
              dataVectorOut => verPadOut  -- sfix20 [5]
              );

  intdelay_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        intdelay_reg <= (OTHERS => '0');
      ELSIF enb = '1' THEN
        intdelay_reg(0) <= hStartIn;
        intdelay_reg(1 TO 2) <= intdelay_reg(0 TO 1);
      END IF;
    END IF;
  END PROCESS intdelay_process;

  hStartInD <= intdelay_reg(2);

  intdelay_1_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        intdelay_reg_1 <= (OTHERS => '0');
      ELSIF enb = '1' THEN
        intdelay_reg_1(0) <= hEndIn;
        intdelay_reg_1(1 TO 2) <= intdelay_reg_1(0 TO 1);
      END IF;
    END IF;
  END PROCESS intdelay_1_process;

  hEndInD <= intdelay_reg_1(2);

  intdelay_2_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        intdelay_reg_2 <= (OTHERS => '0');
      ELSIF enb = '1' THEN
        intdelay_reg_2(0) <= vStartIn;
        intdelay_reg_2(1 TO 2) <= intdelay_reg_2(0 TO 1);
      END IF;
    END IF;
  END PROCESS intdelay_2_process;

  vStartInD <= intdelay_reg_2(2);

  intdelay_3_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        intdelay_reg_3 <= (OTHERS => '0');
      ELSIF enb = '1' THEN
        intdelay_reg_3(0) <= vEndIn;
        intdelay_reg_3(1 TO 2) <= intdelay_reg_3(0 TO 1);
      END IF;
    END IF;
  END PROCESS intdelay_3_process;

  vEndInD <= intdelay_reg_3(2);

  intdelay_4_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        intdelay_reg_4 <= (OTHERS => '0');
      ELSIF enb = '1' THEN
        intdelay_reg_4(0) <= validIn;
        intdelay_reg_4(1 TO 2) <= intdelay_reg_4(0 TO 1);
      END IF;
    END IF;
  END PROCESS intdelay_4_process;

  vEndInD_1 <= intdelay_reg_4(2);

  reg_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        hStartVREG <= '0';
      ELSIF enb = '1' THEN
        hStartVREG <= hStartV;
      END IF;
    END IF;
  END PROCESS reg_process;


  reg_1_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        hEndV_1 <= '0';
      ELSIF enb = '1' THEN
        hEndV_1 <= hEndV;
      END IF;
    END IF;
  END PROCESS reg_1_process;


  reg_2_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        vStartV_1 <= '0';
      ELSIF enb = '1' THEN
        vStartV_1 <= vStartV;
      END IF;
    END IF;
  END PROCESS reg_2_process;


  intdelay_5_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        intdelay_reg_5 <= (OTHERS => '0');
      ELSIF enb = '1' THEN
        intdelay_reg_5(0) <= vEndV;
        intdelay_reg_5(1) <= intdelay_reg_5(0);
      END IF;
    END IF;
  END PROCESS intdelay_5_process;

  vEndREG <= intdelay_reg_5(1);

  reg_3_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        validInV_1 <= '0';
      ELSIF enb = '1' THEN
        validInV_1 <= validInV;
      END IF;
    END IF;
  END PROCESS reg_3_process;


  reg_4_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        InBetweenREG <= '0';
      ELSIF enb = '1' THEN
        InBetweenREG <= InBetween;
      END IF;
    END IF;
  END PROCESS reg_4_process;


  LineAverage_unsigned <= unsigned(LineAverage);

  ConstOne <= to_unsigned(16#0001#, 16);

  LineAveragePlus <= LineAverage_unsigned + ConstOne;

  reg_5_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        LineAverageREG <= to_unsigned(16#0000#, 16);
      ELSIF enb = '1' THEN
        LineAverageREG <= LineAveragePlus;
      END IF;
    END IF;
  END PROCESS reg_5_process;


  dataIn_signed <= signed(dataIn);

  intdelay_6_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        intdelay_reg_6 <= (OTHERS => to_signed(16#00000#, 20));
      ELSIF enb = '1' THEN
        intdelay_reg_6(0) <= dataIn_signed;
        intdelay_reg_6(1 TO 3) <= intdelay_reg_6(0 TO 2);
      END IF;
    END IF;
  END PROCESS intdelay_6_process;

  dataInREG <= intdelay_reg_6(3);

  BooleanZero <= to_unsigned(16#3#, 2);

  -- Free running, Unsigned Counter
  --  initial value   = 0
  --  step value      = 1
  Blank_Count_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        BlankingCount <= to_unsigned(16#0000#, 16);
      ELSIF enb = '1' THEN
        IF hStartR = '1' THEN 
          BlankingCount <= to_unsigned(16#0000#, 16);
        ELSIF blankCountEn = '1' THEN 
          BlankingCount <= BlankingCount + to_unsigned(16#0001#, 16);
        END IF;
      END IF;
    END IF;
  END PROCESS Blank_Count_process;


  LineStartV_unsigned <= unsigned(LineStartV);

  
  popEn <= LineStartV_unsigned WHEN unloading = '0' ELSE
      BooleanZero;

  reg_6_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        validRREG <= '0';
      ELSIF enb = '1' THEN
        validRREG <= validR;
      END IF;
    END IF;
  END PROCESS reg_6_process;


  reg_7_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        hEndRREG <= '0';
      ELSIF enb = '1' THEN
        hEndRREG <= hEndR;
      END IF;
    END IF;
  END PROCESS reg_7_process;


  reg_8_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        AllEndOfLineREG <= '0';
      ELSIF enb = '1' THEN
        AllEndOfLineREG <= AllEndOfLine;
      END IF;
    END IF;
  END PROCESS reg_8_process;


  reg_9_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        vEndRREG <= '0';
      ELSIF enb = '1' THEN
        vEndRREG <= vEndR;
      END IF;
    END IF;
  END PROCESS reg_9_process;


  EndOrStart <= vStartIn OR vEndRREG;

  reg_10_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        hStartDRC <= '0';
      ELSIF enb = '1' THEN
        hStartDRC <= hStartR;
      END IF;
    END IF;
  END PROCESS reg_10_process;


  reg_11_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        outputDataREG <= '0';
      ELSIF enb = '1' THEN
        outputDataREG <= outputData;
      END IF;
    END IF;
  END PROCESS reg_11_process;


  constZero(0) <= to_signed(16#00000#, 20);
  constZero(1) <= to_signed(16#00000#, 20);
  constZero(2) <= to_signed(16#00000#, 20);
  constZero(3) <= to_signed(16#00000#, 20);
  constZero(4) <= to_signed(16#00000#, 20);

  runOrUnload <= unloading OR Running;

  intdelay_7_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        intdelay_reg_7 <= (OTHERS => '0');
      ELSIF enb = '1' THEN
        intdelay_reg_7(0) <= hEndR;
        intdelay_reg_7(1) <= intdelay_reg_7(0);
      END IF;
    END IF;
  END PROCESS intdelay_7_process;

  hEndRDT <= intdelay_reg_7(1);

  processDataGatedD <= processDataGated OR DumpingFlag;

  processDataGatedRU <= runOrUnload AND processDataGatedD;

  intdelay_8_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        intdelay_reg_8 <= (OTHERS => '0');
      ELSIF enb = '1' THEN
        intdelay_reg_8(0) <= processDataGatedRU;
        intdelay_reg_8(1) <= intdelay_reg_8(0);
      END IF;
    END IF;
  END PROCESS intdelay_8_process;

  processDataP <= intdelay_reg_8(1);

  outputProcess <= outputData AND processDataP;

  padShift <= popReg OR dumpControl;

  outputgen3: FOR k IN 0 TO 4 GENERATE
    DataMemVector_signed(k) <= signed(DataMemVector(k));
  END GENERATE;

  countEnHC_1 <= dumpOrControl AND countEnHC;

  -- Free running, Unsigned Counter
  --  initial value   = 0
  --  step value      = 1
  Horizontal_Pad_Counter_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        horPadCount <= to_unsigned(16#000#, 11);
      ELSIF enb = '1' THEN
        IF countResetHC = '1' THEN 
          horPadCount <= to_unsigned(16#000#, 11);
        ELSIF countEnHC_1 = '1' THEN 
          horPadCount <= horPadCount + to_unsigned(16#001#, 11);
        END IF;
      END IF;
    END IF;
  END PROCESS Horizontal_Pad_Counter_process;


  intdelay_9_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        DataMemVectorREG <= (OTHERS => to_signed(16#00000#, 20));
      ELSIF enb = '1' AND padShift = '1' THEN
        DataMemVectorREG <= DataMemVector_signed;
      END IF;
    END IF;
  END PROCESS intdelay_9_process;


  outputgen2: FOR k IN 0 TO 4 GENERATE
    DataMemVectorREG_1(k) <= std_logic_vector(DataMemVectorREG(k));
  END GENERATE;

  reg_12_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        horPadCountREG <= to_unsigned(16#000#, 11);
      ELSIF enb = '1' THEN
        horPadCountREG <= horPadCount;
      END IF;
    END IF;
  END PROCESS reg_12_process;


  outputgen1: FOR k IN 0 TO 4 GENERATE
    verPadOut_signed(k) <= signed(verPadOut(k));
  END GENERATE;

  reg_13_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        verPadD <= (OTHERS => to_signed(16#00000#, 20));
      ELSIF enb = '1' THEN
        verPadD <= verPadOut_signed;
      END IF;
    END IF;
  END PROCESS reg_13_process;


  
  dataSigOut <= constZero WHEN outputProcess = '0' ELSE
      verPadD;

  reg_14_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        dataSigPreOD <= (OTHERS => to_signed(16#00000#, 20));
      ELSIF enb = '1' THEN
        dataSigPreOD <= dataSigOut;
      END IF;
    END IF;
  END PROCESS reg_14_process;


  
  dataOut_tmp <= constZero WHEN outputDataREG = '0' ELSE
      dataSigPreOD;

  outputgen: FOR k IN 0 TO 4 GENERATE
    dataOut(k) <= std_logic_vector(dataOut_tmp(k));
  END GENERATE;

  ctrlOutZero <= '0';

  reg_15_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        reg_switch_delay <= '0';
      ELSIF enb = '1' THEN
        IF hStartOutFG = '1' THEN
          reg_switch_delay <= '0';
        ELSIF hEndOutFG = '1' THEN
          reg_switch_delay <= hEndOutFG;
        END IF;
      END IF;
    END IF;
  END PROCESS reg_15_process;

  
  hEndGate <= '0' WHEN hStartOutFG = '1' ELSE
      reg_switch_delay;

  hEndGateN <=  NOT hEndGate;

  validFGG <= validOutFG AND hEndGateN;

  intdelay_10_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        intdelay_reg_9 <= (OTHERS => '0');
      ELSIF enb = '1' THEN
        intdelay_reg_9(0) <= validFGG;
        intdelay_reg_9(1) <= intdelay_reg_9(0);
      END IF;
    END IF;
  END PROCESS intdelay_10_process;

  validRPre <= intdelay_reg_9(1);

  reg_16_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        validRD <= '0';
      ELSIF enb = '1' THEN
        validRD <= validRPre;
      END IF;
    END IF;
  END PROCESS reg_16_process;


  hEndFGG <= hEndOutFG AND hEndGateN;

  intdelay_11_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        intdelay_reg_10 <= (OTHERS => '0');
      ELSIF enb = '1' THEN
        intdelay_reg_10(0) <= hEndFGG;
        intdelay_reg_10(1 TO 2) <= intdelay_reg_10(0 TO 1);
      END IF;
    END IF;
  END PROCESS intdelay_11_process;

  hEndRD <= intdelay_reg_10(2);

  validRDEnd <= validRD OR hEndRD;

  
  validP <= ctrlOutZero WHEN outputProcess = '0' ELSE
      validRDEnd;

  reg_17_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        validOD <= '0';
      ELSIF enb = '1' THEN
        validOD <= validP;
      END IF;
    END IF;
  END PROCESS reg_17_process;


  
  validOut <= ctrlOutZero WHEN outputDataREG = '0' ELSE
      validOD;

  reg_18_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        processDataOD <= '0';
      ELSIF enb = '1' THEN
        processDataOD <= processDataP;
      END IF;
    END IF;
  END PROCESS reg_18_process;


  
  processDataOut <= ctrlOutZero WHEN outputDataREG = '0' ELSE
      processDataOD;

END rtl;

