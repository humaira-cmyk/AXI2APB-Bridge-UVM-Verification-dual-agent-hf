class axi2apb_virtual_sequencer extends uvm_sequencer;

    `uvm_component_utils(axi2apb_virtual_sequencer)

    axi_sequencer axi_seqr;
    apb_sequencer apb_seqr;

    function new(
        string name = "axi2apb_virtual_sequencer",
        uvm_component parent = null
    );
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("VSEQR", "build_phase executed", UVM_LOW)
    endfunction

endclass
