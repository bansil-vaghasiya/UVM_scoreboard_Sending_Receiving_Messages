`timescale 1ns/10ps
package my_scoreboard;
import uvm_pkg::*;

// sender scoreboard 

class sender extends uvm_scoreboard;
	`uvm_component_utils (sender)
	uvm_analysis_port #(string) Name;      // to broadcast the msg to all subscriber
	//uvm_analysis_port #(reg[4:0]) Number;
	
	string sent_number;
	string sent_msg;  
  reg[4:0] c = 1; 
	function new(string name = "sender", uvm_component parent = null);
		super.new(name, parent);
	endfunction
	
	function void build_phase(uvm_phase phase);
		Name = new("Name", this);
		//Number =  new("Number", this);
	endfunction: build_phase
	
	task run_phase(uvm_phase phase);
		//fork
			repeat(20) begin
				sent_number.itoa(c);
				sent_msg = {"Bansil Vaghasiya :", sent_number};
				Name.write(sent_msg);
				//Number.write(c);
				c = c + 1;
			end 
		//join
	endtask : run_phase
endclass : sender 

// Receiver scoreboard
class receiver extends uvm_scoreboard;
	`uvm_component_utils(receiver)
	uvm_analysis_imp #(string, receiver) rec_msg; //import msg from subscriber
	
	function new(string name = "receiver", uvm_component parent = null);
		super.new(name, parent);
	endfunction
	
	function void build_phase(uvm_phase phase);
		rec_msg = new("rec_msg", this);
	endfunction : build_phase
	
	function void write(input string data);
		`uvm_info("string received", $sformatf("Receiver recieves %s", data), UVM_MEDIUM);
	endfunction : write
	
endclass : receiver
		
// uvm test set-up

class my_test extends uvm_test;
	`uvm_component_utils(my_test)
	
	function new(string name = "mytest", uvm_component parent = null);
		super.new(name, parent);
	endfunction
	
	//creating the handles to the sender and receiver class
	
	sender sender_h;   //sender object to send the messege
	receiver receiver_h;  //receiver object to receive the messege
	
	//instantiating the test using type_id::create() method
	
	function void build_phase(uvm_phase phase);
		sender_h = sender::type_id::create("sender", this);
		receiver_h = receiver::type_id::create("receiver", this);
	endfunction : build_phase
	
	function void connect_phase(uvm_phase phase);
		sender_h.Name.connect(receiver_h.rec_msg);
	endfunction : connect_phase
	
	task run_phase(uvm_phase phase);
		phase.raise_objection(this);
		#30;
		phase.drop_objection(this);
	endtask : run_phase
endclass : my_test
	
endpackage : my_scoreboard

import uvm_pkg::*;


module top ();

reg clk;

initial begin
	#5;
	repeat(100) begin
		#5 clk = 1;
		#5 clk = 0;
	end
	$display("run out of clocks");
	$finish;
end 

initial begin
	run_test("my_test");
end
 
endmodule : top	

