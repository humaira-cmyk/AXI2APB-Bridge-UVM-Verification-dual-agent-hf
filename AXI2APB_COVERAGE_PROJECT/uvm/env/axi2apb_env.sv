class axi2apb_env extends uvm_env;

    `uvm_component_utils(axi2apb_env)

    axi_agent                 axi_ag;
    apb_agent                 apb_ag;
    axi2apb_virtual_sequencer vseqr;
    axi2apb_scoreboard        scoreboard;
    axi2apb_coverage          coverage;

    function new(
        string name = "axi2apb_env",
        uvm_component parent = null
    );
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        `uvm_info("ENV", "build_phase executed", UVM_LOW)

        axi_ag = axi_agent::type_id::create(
            "axi_ag",
            this
        );

        apb_ag = apb_agent::type_id::create(
            "apb_ag",
            this
        );

        vseqr = axi2apb_virtual_sequencer::type_id::create(
            "vseqr",
            this
        );

        scoreboard = axi2apb_scoreboard::type_id::create(
            "scoreboard",
            this
        );

        coverage = axi2apb_coverage::type_id::create(
            "coverage",
            this
        );

    endfunction

    virtual function void connect_phase(uvm_phase phase);

        super.connect_phase(phase);

        `uvm_info("ENV", "connect_phase executed", UVM_LOW)

        // Give the bridge virtual sequencer access to both
        // physical sequencers.
        vseqr.axi_seqr = axi_ag.axi_seqr;
        vseqr.apb_seqr = apb_ag.apb_seqr;

        // Monitor -> scoreboard connections.
        axi_ag.axi_mon.analysis_port.connect(
            scoreboard.axi_export
        );

        apb_ag.apb_mon.analysis_port.connect(
            scoreboard.apb_export
        );

        // Monitor -> functional coverage connections.
        axi_ag.axi_mon.analysis_port.connect(
            coverage.axi_export
        );

        apb_ag.apb_mon.analysis_port.connect(
            coverage.apb_export
        );

    endfunction

endclass
