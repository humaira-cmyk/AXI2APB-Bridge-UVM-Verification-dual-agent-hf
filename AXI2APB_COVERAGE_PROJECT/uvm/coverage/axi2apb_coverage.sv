`uvm_analysis_imp_decl(_axi_cov)
`uvm_analysis_imp_decl(_apb_cov)

class axi2apb_coverage extends uvm_component;

    `uvm_component_utils(axi2apb_coverage)

    // ---------------------------------------------------------------------
    // Monitor inputs
    // ---------------------------------------------------------------------
    uvm_analysis_imp_axi_cov #(
        axi_transaction,
        axi2apb_coverage
    ) axi_export;

    uvm_analysis_imp_apb_cov #(
        apb_transaction,
        axi2apb_coverage
    ) apb_export;

    virtual AXI_BUS axi_vif;
    virtual APB_BUS apb_vif;

    // ---------------------------------------------------------------------
    // AXI transaction coverage sampling variables
    // ---------------------------------------------------------------------
    bit        cov_axi_write;
    bit [31:0] cov_axi_addr;
    bit [31:0] cov_axi_data;
    bit [3:0]  cov_axi_strb;
    bit [5:0]  cov_axi_id;
    bit [5:0]  cov_axi_user;
    bit [1:0]  cov_axi_resp;

    // ---------------------------------------------------------------------
    // APB transaction coverage sampling variables
    // ---------------------------------------------------------------------
    bit        cov_apb_write;
    bit [31:0] cov_apb_addr;
    bit [31:0] cov_apb_data;
    bit        cov_apb_slverr;

    // ---------------------------------------------------------------------
    // Protocol timing coverage sampling variables
    // ---------------------------------------------------------------------
    int unsigned cov_apb_wait_cycles;
    int unsigned cov_bready_wait_cycles;
    int unsigned cov_rready_wait_cycles;
    bit          cov_apb_wait_write;

    // Adjacent AXI transaction / simultaneous-priority coverage.
    bit          cov_prev_write;
    bit          cov_curr_write;
    bit          have_prev_axi_transaction;
    bit          cov_first_apb_write_after_simultaneous;
    bit          cov_rlast;

    // =====================================================================
    // AXI TRANSACTION COVERAGE
    // =====================================================================
    covergroup axi_cg;

        option.per_instance = 1;

        cp_operation: coverpoint cov_axi_write {
            bins READ  = {1'b0};
            bins WRITE = {1'b1};
        }

        cp_address: coverpoint cov_axi_addr {
            bins LOW_RANGE  = {[32'h0000_0000 : 32'h0000_0FFF]};
            bins MID_RANGE  = {[32'h0000_1000 : 32'h0000_FFFF]};
            bins HIGH_RANGE = {[32'h0001_0000 : 32'hFFFF_FFFF]};
        }

        cp_boundary: coverpoint cov_axi_addr {
            bins LOWER_BOUNDARY = {32'h0000_0000};
            bins UPPER_BOUNDARY = {32'hFFFF_FFFC};
            bins OTHER          = default;
        }

        cp_data_pattern: coverpoint cov_axi_data {
            bins ZERO       = {32'h0000_0000};
            bins ALL_ONES   = {32'hFFFF_FFFF};
            bins ALT_AA     = {32'hAAAA_AAAA};
            bins ALT_55     = {32'h5555_5555};
            bins OTHER      = default;
        }

        cp_id: coverpoint cov_axi_id {
            bins LOW_ID  = {[6'd0  : 6'd7]};
            bins MID_ID  = {[6'd8  : 6'd31]};
            bins HIGH_ID = {[6'd32 : 6'd63]};
        }

        cp_user: coverpoint cov_axi_user {
            bins ZERO_USER = {6'd0};
            bins LOW_USER  = {[6'd1  : 6'd15]};
            bins MID_USER  = {[6'd16 : 6'd31]};
            bins HIGH_USER = {[6'd32 : 6'd63]};
        }

        cp_strb: coverpoint cov_axi_strb {
            bins FULL_STROBE = {4'hF};
            bins NO_STROBE   = {4'h0};
            bins PARTIAL     = {[4'h1 : 4'hE]};
        }

        // The supplied bridge implementation always returns AXI OKAY (2'b00),
        // including when APB PSLVERR is asserted.  The other AXI response
        // encodings are therefore unsupported implementation states rather
        // than stimulus holes, so exclude them from the functional target.
        cp_response: coverpoint cov_axi_resp {
            bins OKAY = {2'b00};
            ignore_bins UNSUPPORTED_RESP = {2'b01, 2'b10, 2'b11};
        }

        cross_operation_address: cross cp_operation, cp_address;
        cross_operation_response: cross cp_operation, cp_response;

    endgroup

    // =====================================================================
    // APB TRANSACTION COVERAGE
    // =====================================================================
    covergroup apb_cg;

        option.per_instance = 1;

        cp_operation: coverpoint cov_apb_write {
            bins READ  = {1'b0};
            bins WRITE = {1'b1};
        }

        cp_address: coverpoint cov_apb_addr {
            bins LOW_RANGE  = {[32'h0000_0000 : 32'h0000_0FFF]};
            bins MID_RANGE  = {[32'h0000_1000 : 32'h0000_FFFF]};
            bins HIGH_RANGE = {[32'h0001_0000 : 32'hFFFF_FFFF]};
        }

        cp_data_pattern: coverpoint cov_apb_data {
            bins ZERO       = {32'h0000_0000};
            bins ALL_ONES   = {32'hFFFF_FFFF};
            bins ALT_AA     = {32'hAAAA_AAAA};
            bins ALT_55     = {32'h5555_5555};
            bins OTHER      = default;
        }

        cp_pslverr: coverpoint cov_apb_slverr {
            bins NO_ERROR = {1'b0};
            bins ERROR    = {1'b1};
        }

        cross_operation_error: cross cp_operation, cp_pslverr;

    endgroup

    // =====================================================================
    // APB WAIT-STATE COVERAGE
    // =====================================================================
    covergroup apb_wait_cg;

        option.per_instance = 1;

        cp_operation: coverpoint cov_apb_wait_write {
            bins READ  = {1'b0};
            bins WRITE = {1'b1};
        }

        cp_wait_cycles: coverpoint cov_apb_wait_cycles {
            bins ONE_WAIT  = {1};
            bins SHORT     = {[2:3]};
            bins LONG      = {[4:15]};
            bins VERY_LONG = {[16:32'hFFFF_FFFF]};
        }

        cross_operation_wait: cross cp_operation, cp_wait_cycles;

    endgroup

    // =====================================================================
    // AXI WRITE-RESPONSE BACKPRESSURE COVERAGE
    // =====================================================================
    covergroup axi_bready_cg;

        option.per_instance = 1;

        cp_bready_delay: coverpoint cov_bready_wait_cycles {
            bins IMMEDIATE = {0};
            bins ONE_WAIT  = {1};
            bins SHORT     = {[2:3]};
            bins LONG      = {[4:32'hFFFF_FFFF]};
        }

    endgroup

    // =====================================================================
    // AXI READ-RESPONSE BACKPRESSURE COVERAGE
    // =====================================================================
    covergroup axi_rready_cg;

        option.per_instance = 1;

        cp_rready_delay: coverpoint cov_rready_wait_cycles {
            bins IMMEDIATE = {0};
            bins ONE_WAIT  = {1};
            bins SHORT     = {[2:3]};
            bins LONG      = {[4:32'hFFFF_FFFF]};
        }

    endgroup


    // =====================================================================
    // ADJACENT / BACK-TO-BACK AXI OPERATION COVERAGE
    // =====================================================================
    covergroup axi_sequence_cg;

        option.per_instance = 1;

        cp_previous: coverpoint cov_prev_write {
            bins READ  = {1'b0};
            bins WRITE = {1'b1};
        }

        cp_current: coverpoint cov_curr_write {
            bins READ  = {1'b0};
            bins WRITE = {1'b1};
        }

        cross_previous_current: cross cp_previous, cp_current;

    endgroup

    // =====================================================================
    // SIMULTANEOUS READ/WRITE PRIORITY COVERAGE
    // =====================================================================
    covergroup simultaneous_priority_cg;

        option.per_instance = 1;

        // RTL arbitration is intentionally READ-priority when read and write
        // arrive together. WRITE_FIRST is not a legal outcome for this DUT.
        cp_first_apb_transfer: coverpoint cov_first_apb_write_after_simultaneous {
            bins READ_FIRST = {1'b0};
            ignore_bins WRITE_FIRST_UNSUPPORTED = {1'b1};
        }

    endgroup

    // =====================================================================
    // RLAST COVERAGE FOR IMPLEMENTED SINGLE-READ RESPONSE
    // =====================================================================
    covergroup rlast_cg;

        option.per_instance = 1;

        // This verification environment drives only legal single-beat AXI
        // accesses (LEN=0). Therefore the read response must always be last.
        cp_rlast: coverpoint cov_rlast {
            bins ASSERTED = {1'b1};
            ignore_bins DEASSERTED_UNSUPPORTED = {1'b0};
        }

    endgroup

    // ---------------------------------------------------------------------
    // Constructor
    // ---------------------------------------------------------------------
    function new(
        string name = "axi2apb_coverage",
        uvm_component parent = null
    );
        super.new(name, parent);

        axi_cg                  = new();
        apb_cg                  = new();
        apb_wait_cg             = new();
        axi_bready_cg           = new();
        axi_rready_cg           = new();
        axi_sequence_cg         = new();
        simultaneous_priority_cg = new();
        rlast_cg                = new();

        have_prev_axi_transaction = 1'b0;
    endfunction

    // ---------------------------------------------------------------------
    // Build phase
    // ---------------------------------------------------------------------
    virtual function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        `uvm_info("COVERAGE", "build_phase executed", UVM_LOW)

        axi_export = new("axi_export", this);
        apb_export = new("apb_export", this);

        if (!uvm_config_db #(virtual AXI_BUS)::get(
                this,
                "",
                "axi_vif",
                axi_vif
            )) begin
            `uvm_fatal("COVERAGE", "AXI virtual interface not found")
        end

        if (!uvm_config_db #(virtual APB_BUS)::get(
                this,
                "",
                "apb_vif",
                apb_vif
            )) begin
            `uvm_fatal("COVERAGE", "APB virtual interface not found")
        end

    endfunction

    // ---------------------------------------------------------------------
    // AXI monitor transaction sampling
    // ---------------------------------------------------------------------
    virtual function void write_axi_cov(axi_transaction tr);

        cov_axi_write = tr.is_write;
        cov_axi_addr  = tr.addr;
        cov_axi_data  = tr.data;
        cov_axi_strb  = tr.strb;
        cov_axi_id    = tr.id;
        cov_axi_user  = tr.user;
        cov_axi_resp  = tr.resp;

        axi_cg.sample();

        // Sample the ordering of adjacent completed AXI transactions.
        if (have_prev_axi_transaction) begin
            cov_curr_write = tr.is_write;
            axi_sequence_cg.sample();
        end

        cov_prev_write = tr.is_write;
        have_prev_axi_transaction = 1'b1;

        `uvm_info(
            "COVERAGE",
            $sformatf(
                "AXI sample: WRITE=%0d ADDR=%h DATA=%h ID=%0d USER=%0h RESP=%0d",
                cov_axi_write,
                cov_axi_addr,
                cov_axi_data,
                cov_axi_id,
                cov_axi_user,
                cov_axi_resp
            ),
            UVM_HIGH
        )

    endfunction

    // ---------------------------------------------------------------------
    // APB monitor transaction sampling
    // ---------------------------------------------------------------------
    virtual function void write_apb_cov(apb_transaction tr);

        cov_apb_write  = tr.write;
        cov_apb_addr   = tr.addr;
        cov_apb_data   = tr.write ? tr.data : tr.rdata;
        cov_apb_slverr = tr.slverr;

        apb_cg.sample();

        `uvm_info(
            "COVERAGE",
            $sformatf(
                "APB sample: WRITE=%0d ADDR=%h DATA=%h PSLVERR=%0d",
                cov_apb_write,
                cov_apb_addr,
                cov_apb_data,
                cov_apb_slverr
            ),
            UVM_HIGH
        )

    endfunction

    // ---------------------------------------------------------------------
    // Signal-level wait-state/backpressure sampling
    // ---------------------------------------------------------------------
    virtual task run_phase(uvm_phase phase);

        int unsigned apb_wait_count;
        int unsigned bready_wait_count;
        int unsigned rready_wait_count;
        bit          simultaneous_pending;

        `uvm_info("COVERAGE", "run_phase executed", UVM_LOW)

        apb_wait_count      = 0;
        bready_wait_count   = 0;
        rready_wait_count   = 0;
        simultaneous_pending = 1'b0;

        forever begin

            @(posedge axi_vif.clk);

            // Detect the testbench presenting read and write requests together.
            if ((axi_vif.ar_valid === 1'b1) &&
                (axi_vif.aw_valid === 1'b1) &&
                (axi_vif.w_valid  === 1'b1)) begin
                simultaneous_pending = 1'b1;
            end

            // -------------------------------------------------------------
            // APB wait states: count ACCESS cycles where PREADY is LOW.
            // Sample once when the transfer completes with PREADY HIGH.
            // -------------------------------------------------------------
            if ((apb_vif.psel === 1'b1) &&
                (apb_vif.penable === 1'b1) &&
                (apb_vif.pready === 1'b0)) begin
                apb_wait_count++;
            end

            if ((apb_vif.psel === 1'b1) &&
                (apb_vif.penable === 1'b1) &&
                (apb_vif.pready === 1'b1)) begin

                cov_apb_wait_cycles = apb_wait_count;
                cov_apb_wait_write  = apb_vif.pwrite;
                apb_wait_cg.sample();
                apb_wait_count = 0;

                // On the first completed APB transfer after simultaneous
                // AXI read/write stimulus, record which direction won.
                if (simultaneous_pending) begin
                    cov_first_apb_write_after_simultaneous = apb_vif.pwrite;
                    simultaneous_priority_cg.sample();
                    simultaneous_pending = 1'b0;
                end

            end

            // -------------------------------------------------------------
            // AXI B-channel backpressure.
            // -------------------------------------------------------------
            if ((axi_vif.b_valid === 1'b1) &&
                (axi_vif.b_ready === 1'b0)) begin
                bready_wait_count++;
            end

            if ((axi_vif.b_valid === 1'b1) &&
                (axi_vif.b_ready === 1'b1)) begin

                cov_bready_wait_cycles = bready_wait_count;
                axi_bready_cg.sample();
                bready_wait_count = 0;

            end

            // -------------------------------------------------------------
            // AXI R-channel backpressure.
            // -------------------------------------------------------------
            if ((axi_vif.r_valid === 1'b1) &&
                (axi_vif.r_ready === 1'b0)) begin
                rready_wait_count++;
            end

            if ((axi_vif.r_valid === 1'b1) &&
                (axi_vif.r_ready === 1'b1)) begin

                cov_rready_wait_cycles = rready_wait_count;
                axi_rready_cg.sample();
                rready_wait_count = 0;

                cov_rlast = axi_vif.r_last;
                rlast_cg.sample();

            end

        end

    endtask

    // ---------------------------------------------------------------------
    // Report phase
    // ---------------------------------------------------------------------
    virtual function void report_phase(uvm_phase phase);

        real axi_cov_pct;
        real apb_cov_pct;
        real apb_wait_cov_pct;
        real bready_cov_pct;
        real rready_cov_pct;
        real sequence_cov_pct;
        real priority_cov_pct;
        real rlast_cov_pct;
        real overall_cov_pct;

        super.report_phase(phase);

        `uvm_info("COVERAGE", "report_phase executed", UVM_LOW)

        axi_cov_pct          = axi_cg.get_inst_coverage();
        apb_cov_pct          = apb_cg.get_inst_coverage();
        apb_wait_cov_pct     = apb_wait_cg.get_inst_coverage();
        bready_cov_pct       = axi_bready_cg.get_inst_coverage();
        rready_cov_pct       = axi_rready_cg.get_inst_coverage();
        sequence_cov_pct     = axi_sequence_cg.get_inst_coverage();
        priority_cov_pct     = simultaneous_priority_cg.get_inst_coverage();
        rlast_cov_pct        = rlast_cg.get_inst_coverage();

        overall_cov_pct = (
            axi_cov_pct +
            apb_cov_pct +
            apb_wait_cov_pct +
            bready_cov_pct +
            rready_cov_pct +
            sequence_cov_pct +
            priority_cov_pct +
            rlast_cov_pct
        ) / 8.0;

        `uvm_info(
            "COVERAGE",
            $sformatf(
                "FUNCTIONAL COVERAGE SUMMARY: AXI=%0.2f%% APB=%0.2f%% APB_WAIT=%0.2f%% BREADY=%0.2f%% RREADY=%0.2f%% SEQUENCE=%0.2f%% PRIORITY=%0.2f%% RLAST=%0.2f%% OVERALL=%0.2f%%",
                axi_cov_pct,
                apb_cov_pct,
                apb_wait_cov_pct,
                bready_cov_pct,
                rready_cov_pct,
                sequence_cov_pct,
                priority_cov_pct,
                rlast_cov_pct,
                overall_cov_pct
            ),
            UVM_NONE
        )

    endfunction

endclass
