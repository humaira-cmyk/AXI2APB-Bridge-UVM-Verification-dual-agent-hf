class apb_transaction extends uvm_sequence_item;

    // Fields sampled by APB monitor.
    rand bit [31:0] addr;
    rand bit [31:0] data;
    rand bit        write;
    rand bit [3:0]  strb;

    bit [31:0]      rdata;
    bit             slverr;

    // Response controls used by APB response sequence/driver.
    rand int unsigned wait_cycles;
    rand bit          inject_slverr;
    rand bit [31:0]   response_data;

    function new(string name = "apb_transaction");
        super.new(name);
        wait_cycles   = 0;
        inject_slverr = 1'b0;
        response_data = 32'h0000_0000;
    endfunction

    `uvm_object_utils_begin(apb_transaction)
        `uvm_field_int(addr,           UVM_ALL_ON)
        `uvm_field_int(data,           UVM_ALL_ON)
        `uvm_field_int(write,          UVM_ALL_ON)
        `uvm_field_int(strb,           UVM_ALL_ON)
        `uvm_field_int(rdata,          UVM_ALL_ON)
        `uvm_field_int(slverr,         UVM_ALL_ON)
        `uvm_field_int(wait_cycles,    UVM_ALL_ON)
        `uvm_field_int(inject_slverr,  UVM_ALL_ON)
        `uvm_field_int(response_data,  UVM_ALL_ON)
    `uvm_object_utils_end

endclass
