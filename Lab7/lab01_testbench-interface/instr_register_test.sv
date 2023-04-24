/***********************************************************************
 * A SystemVerilog testbench for an instruction register.
 * The course labs will convert this to an object-oriented testbench
 * with constrained random test generation, functional coverage, and
 * a scoreboard for self-verification.
 **********************************************************************/
  import instr_register_pkg::*;  // user-defined types are defined in instr_register_pkg.sv
module instr_register_test #(parameter NUMBER_OF_TRANSACTIONS = 11, parameter random_case = 3 , parameter seed=  77777, parameter test_name="Null")

  (input  logic          clk,
   output logic          load_en,
   output logic          reset_n,
   output operand_t      operand_a,
   output operand_t      operand_b,
   output opcode_t       opcode,
   output address_t      write_pointer,
   output address_t      read_pointer,
   input  instruction_t  instruction_word
  );

  timeunit 1ns/1ns;
  // parameter NUMBER_OF_TRANSACTIONS = 11;
  // parameter seed = 555; //procedura prin care se initializeaza secventa random pt random stability
  // //int random_case = $urandom_range(0, 3);
  // parameter random_case = 0;
  // write - read 
  // 0 - random random
  // 1 - random incremental
  // 2 - incremental random 
  // 3 - incremental incremental
  integer error_count = 0;

 //covergroup declaration
  covergroup coverage_calc;
  cov_p1: coverpoint instruction_word.op_a
                              {
                                bins op_a_max = {15};
                                bins op_a_zero = {0};
                                bins op_a_min = {-15};
                              }
  cov_p2: coverpoint instruction_word.op_b 
                             {
                                bins op_b_max = {15};
                                bins op_b_zero = {0};
                                bins op_b_min = {-15};
                              }
  cov_p3: coverpoint instruction_word.opc; 
  endgroup
  //cg variable declaration
  // coverage_calc  cov_calc;

  //  cov_calc.sample();
  
  initial begin
    $display("\n\n***********************************************************");
    $display(    "***  THIS IS NOT A SELF-CHECKING TESTBENCH (YET).  YOU  ***");
    $display(    "***  NEED TO VISUALLY VERIFY THAT THE OUTPUT VALUES     ***");
    $display(    "***  MATCH THE INPUT VALUES FOR EACH REGISTER LOCATION  ***");
    $display(    "***********************************************************");
    

    $display("\nReseting the instruction register...");
    write_pointer  = 5'h00;         // initialize write pointer
    read_pointer   = 5'h1F;         // initialize read pointer
    load_en        = 1'b0;          // initialize load control line
    reset_n       <= 1'b0;          // assert reset_n (active low)
    repeat (2) @(posedge clk) ;     // hold in reset for 2 clock cycles
    reset_n        = 1'b1;          // deassert reset_n (active low)

    $display("\nWriting values to register stack...");
    @(posedge clk) load_en = 1'b1;  // enable writing to register
    repeat (NUMBER_OF_TRANSACTIONS) begin
      @(posedge clk) randomize_transaction;
      @(negedge clk) print_transaction;
    end
    @(posedge clk) load_en = 1'b0;  // turn-off writing to register

    // read back and display same three register locations
    $display("\nReading back the same register locations written...");
    for (int i=0; i< NUMBER_OF_TRANSACTIONS; i++) begin
      // later labs will replace this loop with iterating through a
      // scoreboard to determine which addresses were written and
      // the expected values to be read back
      if(random_case == 0 || random_case == 2) begin
        @(posedge clk) read_pointer = $unsigned($urandom)%32;
      end else if (random_case == 1 || random_case == 3) begin
          @(posedge clk) read_pointer = i;
      end
      @(negedge clk) print_results;
     check_result(instruction_word, opcode, operand_a, operand_b);
   

    end
    
    @(posedge clk) ;
    $display("\n***********************************************************");
    $display(  "***  THIS IS NOT A SELF-CHECKING TESTBENCH (YET).  YOU  ***");
    $display(  "***  NEED TO VISUALLY VERIFY THAT THE OUTPUT VALUES     ***");
    $display(  "***  MATCH THE INPUT VALUES FOR EACH REGISTER LOCATION  ***");
    $display(  "***********************************************************\n");
    $display( "Test Name= %s\n", test_name);
    $display("Total Errors: %0d\n", error_count);
    if( error_count > 0) begin
      $display("Test failed");
    end else begin  
      $display("Test passed");
    end


    $finish;
  end

  function void randomize_transaction;
    // A later lab will replace this function with SystemVerilog
    // constrained random values
    //
    // The stactic temp variable is required in order to write to fixed
    // addresses of 0, 1 and 2.  This will be replaceed with randomizeed
    // write_pointer values in a later lab
    //
    static int temp = 0;
    operand_a     <= $random(seed)%16;                 // between -15 and 15
    operand_b     <= $unsigned($random)%16;            // between 0 and 15  
    opcode        <= opcode_t'($unsigned($random)%8);  // between 0 and 7, cast to opcode_t type
    // operand_a     <= $urandom()%16;                 // between -15 and 15
    // operand_b     <= $unsigned($urandom)%16;            // between 0 and 15  
    // opcode        <= opcode_t'($unsigned($urandom)%8);  // between 0 and 7, cast to opcode_t type
    

    
    if(random_case == 0 || random_case == 1) begin
        write_pointer <= $unsigned($urandom)%32;
      end else if (random_case == 2 || random_case == 3) begin
           write_pointer <= temp++;
      end
  endfunction: randomize_transaction

  function void print_transaction;
    $display("Writing to register location %0d: ", write_pointer);
    $display("  opcode = %0d (%s)", opcode, opcode.name);
    $display("  operand_a = %0d",   operand_a);
    $display("  operand_b = %0d\n", operand_b);
    $display("  random_case = %0d\n", random_case);

  endfunction: print_transaction

  function void print_results;
    $display("Read from register location %0d: ", read_pointer);
    $display("  opcode = %0d (%s)", instruction_word.opc, instruction_word.opc.name);
    $display("  operand_a = %0d",   instruction_word.op_a);
    $display("  operand_b = %0d\n", instruction_word.op_b);
  endfunction: print_results

 function void check_result(instruction_t instruction_word, opcode_t opcode, operand_t operand_a, operand_t operand_b);
        operand_res expected_result;

        case (instruction_word.opc)
          ADD: expected_result = instruction_word.op_a + instruction_word.op_b;
          //Modify
          SUB: expected_result = instruction_word.op_a + instruction_word.op_b;
          MULT: expected_result = instruction_word.op_a * instruction_word.op_b;
          PASSA: expected_result = instruction_word.op_a;
          PASSB: expected_result = instruction_word.op_b;
          DIV: expected_result = instruction_word.op_a / instruction_word.op_b;
          MOD: expected_result = instruction_word.op_a % instruction_word.op_b;
          default: expected_result = 0;
        endcase

        if (expected_result == instruction_word.rezultat) begin
          $display("Test PASSED");
        end else begin
          $display("Test FAILED");
          error_count++;
        end

        $display("  Expected Result: %0d", expected_result);
        $display("  Actual Result: %0d", instruction_word.rezultat);
  endfunction: check_result


endmodule: instr_register_test
