class axi_sequencer extends uvm_sequencer #(axi_transaction);

    `uvm_component_utils(axi_sequencer)

    function new(
        string name = "axi_sequencer",
        uvm_component parent = null
    );
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("AXI_SEQR", "build_phase executed", UVM_LOW)
    endfunction

endclass
