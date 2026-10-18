class axi_transaction extends uvm_sequence_item;

    // ---------------------------------------------------------
    // AXI request information
    // ---------------------------------------------------------
    rand bit        is_write;
    rand bit        simultaneous_rw;

    rand bit [5:0]  id;
    rand bit [31:0] addr;
    rand bit [31:0] data;
    rand bit [3:0]  strb;
    rand bit [5:0]  user;

    // AXI address-channel sideband fields. These are exposed so coverage
    // tests can toggle the complete AW/AR buffer payload instead of keeping
    // most bits at constants.
    rand bit [7:0]  len;
    rand bit [2:0]  size;
    rand bit [1:0]  burst;
    rand bit        lock;
    rand bit [3:0]  cache;
    rand bit [2:0]  prot;
    rand bit [3:0]  region;
    rand bit [3:0]  qos;

    // Used only by the simultaneous read + write sequence.
    rand bit [5:0]  read_id;
    rand bit [31:0] read_addr;
    rand bit [5:0]  read_user;

    // Backpressure is now controlled by the AXI sequence item,
    // not by test-level config_db settings.
    rand int unsigned bready_delay;
    rand int unsigned rready_delay;

    // ---------------------------------------------------------
    // AXI response information captured by the driver/monitor
    // ---------------------------------------------------------
    bit [1:0] resp;
    bit [5:0] resp_id;
    bit [5:0] resp_user;

    function new(string name = "axi_transaction");
        super.new(name);
        bready_delay = 0;
        rready_delay = 0;
        len          = 8'd0;
        size         = 3'd2;
        burst        = 2'b01;
        lock         = 1'b0;
        cache        = 4'h0;
        prot         = 3'h0;
        region       = 4'h0;
        qos          = 4'h0;
    endfunction

    `uvm_object_utils_begin(axi_transaction)
        `uvm_field_int(is_write,        UVM_ALL_ON)
        `uvm_field_int(simultaneous_rw, UVM_ALL_ON)
        `uvm_field_int(id,              UVM_ALL_ON)
        `uvm_field_int(addr,            UVM_ALL_ON)
        `uvm_field_int(data,            UVM_ALL_ON)
        `uvm_field_int(strb,            UVM_ALL_ON)
        `uvm_field_int(user,            UVM_ALL_ON)
        `uvm_field_int(len,             UVM_ALL_ON)
        `uvm_field_int(size,            UVM_ALL_ON)
        `uvm_field_int(burst,           UVM_ALL_ON)
        `uvm_field_int(lock,            UVM_ALL_ON)
        `uvm_field_int(cache,           UVM_ALL_ON)
        `uvm_field_int(prot,            UVM_ALL_ON)
        `uvm_field_int(region,          UVM_ALL_ON)
        `uvm_field_int(qos,             UVM_ALL_ON)
        `uvm_field_int(read_id,         UVM_ALL_ON)
        `uvm_field_int(read_addr,       UVM_ALL_ON)
        `uvm_field_int(read_user,       UVM_ALL_ON)
        `uvm_field_int(bready_delay,    UVM_ALL_ON)
        `uvm_field_int(rready_delay,    UVM_ALL_ON)
        `uvm_field_int(resp,            UVM_ALL_ON)
        `uvm_field_int(resp_id,         UVM_ALL_ON)
        `uvm_field_int(resp_user,       UVM_ALL_ON)
    `uvm_object_utils_end

endclass
