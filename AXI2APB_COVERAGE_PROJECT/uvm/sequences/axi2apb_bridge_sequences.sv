// ============================================================================
// AXI2APB BRIDGE VIRTUAL SEQUENCES
//
// AXI has its own physical sequence.
// APB has its own physical response sequence.
// These virtual sequences coordinate both physical sequencers.
//
// IMPORTANT:
//   - AXI and APB sides run together using fork...join.
//   - `uvm_do_on_with is used to create, randomize and start sub-sequences.
//   - No reference model is used in this project.
// ============================================================================


// ============================================================================
// COMMON BRIDGE VIRTUAL SEQUENCE BASE
// ============================================================================
class axi2apb_bridge_base_sequence extends uvm_sequence;

    `uvm_object_utils(axi2apb_bridge_base_sequence)

    `uvm_declare_p_sequencer(
        axi2apb_virtual_sequencer
    )

    function new(string name = "axi2apb_bridge_base_sequence");
        super.new(name);
    endfunction

    virtual task body();
        `uvm_info(
            "BRIDGE_BASE_SEQ",
            "Base bridge virtual sequence body executed",
            UVM_LOW
        )
    endtask

endclass


// ============================================================================
// 1. SINGLE WRITE VIRTUAL SEQUENCE
// ============================================================================
class axi2apb_single_write_sequence extends axi2apb_bridge_base_sequence;

    `uvm_object_utils(axi2apb_single_write_sequence)

    axi_write_sequence    axi_sequence;
    apb_response_sequence apb_sequence;

    function new(string name = "axi2apb_single_write_sequence");
        super.new(name);
    endfunction

    virtual task body();

        `uvm_info(
            "SINGLE_WR_VSEQ",
            "Starting RANDOMIZED AXI single write and APB response",
            UVM_LOW
        )

        fork

            begin

                `uvm_do_on_with(
                    axi_sequence,
                    p_sequencer.axi_seqr,
                    {
                        // ID, address, data and USER are randomized.
                        // Keep the 32-bit single-beat access word aligned.
                        cfg_addr[1:0]     == 2'b00;
                        cfg_strb          == 4'hF;
                        cfg_bready_delay  == 0;
                    }
                )

            end

            begin

                `uvm_do_on_with(
                    apb_sequence,
                    p_sequencer.apb_seqr,
                    {
                        cfg_response_count    == 1;
                        cfg_wait_cycles       == 0;
                        cfg_inject_error      == 0;
                        cfg_default_read_data == 32'h0000_0000;
                    }
                )

            end

        join

        `uvm_info(
            "SINGLE_WR_VSEQ",
            "Single write virtual sequence completed",
            UVM_LOW
        )

    endtask

endclass


// ============================================================================
// 2. SINGLE READ VIRTUAL SEQUENCE
// ============================================================================
class axi2apb_single_read_sequence extends axi2apb_bridge_base_sequence;

    `uvm_object_utils(axi2apb_single_read_sequence)

    axi_read_sequence     axi_sequence;
    apb_response_sequence apb_sequence;

    function new(string name = "axi2apb_single_read_sequence");
        super.new(name);
    endfunction

    virtual task body();

        `uvm_info(
            "SINGLE_RD_VSEQ",
            "Starting RANDOMIZED AXI single read and APB response",
            UVM_LOW
        )

        fork

            begin

                `uvm_do_on_with(
                    axi_sequence,
                    p_sequencer.axi_seqr,
                    {
                        // ID, address and USER are randomized.
                        // Keep the 32-bit single-beat access word aligned.
                        cfg_addr[1:0]     == 2'b00;
                        cfg_rready_delay  == 0;
                    }
                )

            end

            begin

                `uvm_do_on_with(
                    apb_sequence,
                    p_sequencer.apb_seqr,
                    {
                        cfg_response_count == 1;
                        cfg_wait_cycles    == 0;
                        cfg_inject_error   == 0;
                        // cfg_default_read_data is intentionally randomized.
                    }
                )

            end

        join

        `uvm_info(
            "SINGLE_RD_VSEQ",
            "Single read virtual sequence completed",
            UVM_LOW
        )

    endtask

endclass


// ============================================================================
// 3. RESET / SMOKE VIRTUAL SEQUENCE
//
// Reset itself is generated in axi2apb_tb_top.
// No AXI/APB transfer is intentionally generated here.
// ============================================================================
class axi2apb_smoke_sequence extends axi2apb_bridge_base_sequence;

    `uvm_object_utils(axi2apb_smoke_sequence)

    function new(string name = "axi2apb_smoke_sequence");
        super.new(name);
    endfunction

    virtual task body();

        `uvm_info(
            "SMOKE_VSEQ",
            "RESET / SMOKE sequence started",
            UVM_LOW
        )

        #100ns;

        `uvm_info(
            "SMOKE_VSEQ",
            "RESET / SMOKE sequence completed",
            UVM_LOW
        )

    endtask

endclass


// ============================================================================
// 4. APB WAIT-STATE VIRTUAL SEQUENCE
//
// AXI side performs a normal write.
// APB slave delays PREADY for three cycles.
// ============================================================================
class axi2apb_wait_state_sequence extends axi2apb_bridge_base_sequence;

    `uvm_object_utils(axi2apb_wait_state_sequence)

    axi_write_sequence    axi_sequence;
    apb_response_sequence apb_sequence;

    function new(string name = "axi2apb_wait_state_sequence");
        super.new(name);
    endfunction

    virtual task body();

        `uvm_info(
            "WAIT_VSEQ",
            "Starting AXI write with APB wait states",
            UVM_LOW
        )

        fork

            begin

                `uvm_do_on_with(
                    axi_sequence,
                    p_sequencer.axi_seqr,
                    {
                        cfg_id           == 6'd3;
                        cfg_addr         == 32'h0000_0020;
                        cfg_data         == 32'h1234_5678;
                        cfg_strb         == 4'hF;
                        cfg_user         == 6'h00;
                        cfg_bready_delay == 0;
                    }
                )

            end

            begin

                `uvm_do_on_with(
                    apb_sequence,
                    p_sequencer.apb_seqr,
                    {
                        cfg_response_count    == 1;
                        cfg_wait_cycles       == 3;
                        cfg_inject_error      == 0;
                        cfg_default_read_data == 32'h0000_0000;
                    }
                )

            end

        join

        `uvm_info(
            "WAIT_VSEQ",
            "APB wait-state virtual sequence completed",
            UVM_LOW
        )

    endtask

endclass


// ============================================================================
// 5. WRITE BACKPRESSURE VIRTUAL SEQUENCE
//
// APB responds immediately.
// AXI master delays BREADY for three cycles.
// ============================================================================
class axi2apb_write_backpressure_sequence extends axi2apb_bridge_base_sequence;

    `uvm_object_utils(axi2apb_write_backpressure_sequence)

    axi_write_sequence    axi_sequence;
    apb_response_sequence apb_sequence;

    function new(string name = "axi2apb_write_backpressure_sequence");
        super.new(name);
    endfunction

    virtual task body();

        `uvm_info(
            "WR_BP_VSEQ",
            "Starting AXI write backpressure test",
            UVM_LOW
        )

        fork

            begin

                `uvm_do_on_with(
                    axi_sequence,
                    p_sequencer.axi_seqr,
                    {
                        cfg_id           == 6'd4;
                        cfg_addr         == 32'h0000_0030;
                        cfg_data         == 32'hA5A5_A5A5;
                        cfg_strb         == 4'hF;
                        cfg_user         == 6'h00;
                        cfg_bready_delay == 3;
                    }
                )

            end

            begin

                `uvm_do_on_with(
                    apb_sequence,
                    p_sequencer.apb_seqr,
                    {
                        cfg_response_count    == 1;
                        cfg_wait_cycles       == 0;
                        cfg_inject_error      == 0;
                        cfg_default_read_data == 32'h0000_0000;
                    }
                )

            end

        join

        `uvm_info(
            "WR_BP_VSEQ",
            "Write backpressure virtual sequence completed",
            UVM_LOW
        )

    endtask

endclass


// ============================================================================
// 6. READ BACKPRESSURE VIRTUAL SEQUENCE
//
// APB responds immediately.
// AXI master delays RREADY for three cycles.
// ============================================================================
class axi2apb_read_backpressure_sequence extends axi2apb_bridge_base_sequence;

    `uvm_object_utils(axi2apb_read_backpressure_sequence)

    axi_read_sequence     axi_sequence;
    apb_response_sequence apb_sequence;

    function new(string name = "axi2apb_read_backpressure_sequence");
        super.new(name);
    endfunction

    virtual task body();

        `uvm_info(
            "RD_BP_VSEQ",
            "Starting AXI read backpressure test",
            UVM_LOW
        )

        fork

            begin

                `uvm_do_on_with(
                    axi_sequence,
                    p_sequencer.axi_seqr,
                    {
                        cfg_id           == 6'd5;
                        cfg_addr         == 32'h0000_0034;
                        cfg_user         == 6'h00;
                        cfg_rready_delay == 3;
                    }
                )

            end

            begin

                `uvm_do_on_with(
                    apb_sequence,
                    p_sequencer.apb_seqr,
                    {
                        cfg_response_count    == 1;
                        cfg_wait_cycles       == 0;
                        cfg_inject_error      == 0;
                        cfg_default_read_data == 32'h0000_0000;
                    }
                )

            end

        join

        `uvm_info(
            "RD_BP_VSEQ",
            "Read backpressure virtual sequence completed",
            UVM_LOW
        )

    endtask

endclass


// ============================================================================
// 7. SIMULTANEOUS READ + WRITE VIRTUAL SEQUENCE
//
// AXI driver receives one special item carrying both requests.
// APB sequence provides two responses because DUT creates two APB transfers.
// ============================================================================
class axi2apb_simultaneous_rw_sequence extends axi2apb_bridge_base_sequence;

    `uvm_object_utils(axi2apb_simultaneous_rw_sequence)

    axi_simultaneous_rw_sequence axi_sequence;
    apb_response_sequence        apb_sequence;

    function new(string name = "axi2apb_simultaneous_rw_sequence");
        super.new(name);
    endfunction

    virtual task body();

        `uvm_info(
            "SIM_RW_VSEQ",
            "Starting simultaneous AXI READ + WRITE test",
            UVM_LOW
        )

        fork

            begin

                `uvm_do_on_with(
                    axi_sequence,
                    p_sequencer.axi_seqr,
                    {
                        cfg_write_id   == 6'd6;
                        cfg_write_addr == 32'h0000_0060;
                        cfg_write_data == 32'hCAFE_BABE;
                        cfg_write_user == 6'h01;

                        cfg_read_id    == 6'd7;
                        cfg_read_addr  == 32'h0000_0064;
                        cfg_read_user  == 6'h02;
                    }
                )

            end

            begin

                `uvm_do_on_with(
                    apb_sequence,
                    p_sequencer.apb_seqr,
                    {
                        cfg_response_count    == 2;
                        cfg_wait_cycles       == 0;
                        cfg_inject_error      == 0;
                        cfg_default_read_data == 32'h0000_0000;
                    }
                )

            end

        join

        `uvm_info(
            "SIM_RW_VSEQ",
            "Simultaneous READ + WRITE virtual sequence completed",
            UVM_LOW
        )

    endtask

endclass


// ============================================================================
// 8. BACK-TO-BACK WRITE VIRTUAL SEQUENCE
// ============================================================================
class axi2apb_back_to_back_write_sequence extends axi2apb_bridge_base_sequence;

    `uvm_object_utils(axi2apb_back_to_back_write_sequence)

    axi_write_sequence    w0;
    axi_write_sequence    w1;
    axi_write_sequence    w2;
    axi_write_sequence    w3;
    apb_response_sequence apb_sequence;

    function new(string name = "axi2apb_back_to_back_write_sequence");
        super.new(name);
    endfunction

    virtual task body();

        `uvm_info(
            "B2B_WR_VSEQ",
            "Starting four back-to-back AXI writes",
            UVM_LOW
        )

        fork

            begin

                `uvm_do_on_with(w0, p_sequencer.axi_seqr, {
                    cfg_id == 6'd8;  cfg_addr == 32'h0000_0040;
                    cfg_data == 32'h1111_1111; cfg_strb == 4'hF;
                    cfg_user == 6'h00; cfg_bready_delay == 0;
                })

                `uvm_do_on_with(w1, p_sequencer.axi_seqr, {
                    cfg_id == 6'd9;  cfg_addr == 32'h0000_0044;
                    cfg_data == 32'h2222_2222; cfg_strb == 4'hF;
                    cfg_user == 6'h00; cfg_bready_delay == 0;
                })

                `uvm_do_on_with(w2, p_sequencer.axi_seqr, {
                    cfg_id == 6'd10; cfg_addr == 32'h0000_0048;
                    cfg_data == 32'h3333_3333; cfg_strb == 4'hF;
                    cfg_user == 6'h00; cfg_bready_delay == 0;
                })

                `uvm_do_on_with(w3, p_sequencer.axi_seqr, {
                    cfg_id == 6'd11; cfg_addr == 32'h0000_004C;
                    cfg_data == 32'h4444_4444; cfg_strb == 4'hF;
                    cfg_user == 6'h00; cfg_bready_delay == 0;
                })

            end

            begin

                `uvm_do_on_with(
                    apb_sequence,
                    p_sequencer.apb_seqr,
                    {
                        cfg_response_count    == 4;
                        cfg_wait_cycles       == 0;
                        cfg_inject_error      == 0;
                        cfg_default_read_data == 32'h0000_0000;
                    }
                )

            end

        join

        `uvm_info(
            "B2B_WR_VSEQ",
            "Back-to-back write virtual sequence completed",
            UVM_LOW
        )

    endtask

endclass


// ============================================================================
// 9. BACK-TO-BACK READ VIRTUAL SEQUENCE
// ============================================================================
class axi2apb_back_to_back_read_sequence extends axi2apb_bridge_base_sequence;

    `uvm_object_utils(axi2apb_back_to_back_read_sequence)

    axi_read_sequence     r0;
    axi_read_sequence     r1;
    axi_read_sequence     r2;
    axi_read_sequence     r3;
    apb_response_sequence apb_sequence;

    function new(string name = "axi2apb_back_to_back_read_sequence");
        super.new(name);
    endfunction

    virtual task body();

        `uvm_info(
            "B2B_RD_VSEQ",
            "Starting four back-to-back AXI reads",
            UVM_LOW
        )

        fork

            begin

                `uvm_do_on_with(r0, p_sequencer.axi_seqr, {
                    cfg_id == 6'd12; cfg_addr == 32'h0000_0050;
                    cfg_user == 6'h00; cfg_rready_delay == 0;
                })

                `uvm_do_on_with(r1, p_sequencer.axi_seqr, {
                    cfg_id == 6'd13; cfg_addr == 32'h0000_0054;
                    cfg_user == 6'h00; cfg_rready_delay == 0;
                })

                `uvm_do_on_with(r2, p_sequencer.axi_seqr, {
                    cfg_id == 6'd14; cfg_addr == 32'h0000_0058;
                    cfg_user == 6'h00; cfg_rready_delay == 0;
                })

                `uvm_do_on_with(r3, p_sequencer.axi_seqr, {
                    cfg_id == 6'd15; cfg_addr == 32'h0000_005C;
                    cfg_user == 6'h00; cfg_rready_delay == 0;
                })

            end

            begin

                `uvm_do_on_with(
                    apb_sequence,
                    p_sequencer.apb_seqr,
                    {
                        cfg_response_count    == 4;
                        cfg_wait_cycles       == 0;
                        cfg_inject_error      == 0;
                        cfg_default_read_data == 32'h0000_0000;
                    }
                )

            end

        join

        `uvm_info(
            "B2B_RD_VSEQ",
            "Back-to-back read virtual sequence completed",
            UVM_LOW
        )

    endtask

endclass


// ============================================================================
// 10. MIXED READ / WRITE VIRTUAL SEQUENCE
// ============================================================================
class axi2apb_mixed_rw_sequence extends axi2apb_bridge_base_sequence;

    `uvm_object_utils(axi2apb_mixed_rw_sequence)

    axi_write_sequence    w0;
    axi_read_sequence     r0;
    axi_write_sequence    w1;
    axi_write_sequence    w2;
    axi_read_sequence     r1;
    axi_read_sequence     r2;
    apb_response_sequence apb_sequence;

    function new(string name = "axi2apb_mixed_rw_sequence");
        super.new(name);
    endfunction

    virtual task body();

        `uvm_info(
            "MIXED_VSEQ",
            "Starting mixed AXI write/read stream",
            UVM_LOW
        )

        fork

            begin

                `uvm_do_on_with(w0, p_sequencer.axi_seqr, {
                    cfg_id == 6'd16; cfg_addr == 32'h0000_0070;
                    cfg_data == 32'h1111_AAAA; cfg_strb == 4'hF;
                    cfg_user == 6'h00; cfg_bready_delay == 0;
                })

                `uvm_do_on_with(r0, p_sequencer.axi_seqr, {
                    cfg_id == 6'd17; cfg_addr == 32'h0000_0070;
                    cfg_user == 6'h00; cfg_rready_delay == 0;
                })

                `uvm_do_on_with(w1, p_sequencer.axi_seqr, {
                    cfg_id == 6'd18; cfg_addr == 32'h0000_0074;
                    cfg_data == 32'h2222_BBBB; cfg_strb == 4'hF;
                    cfg_user == 6'h00; cfg_bready_delay == 0;
                })

                `uvm_do_on_with(w2, p_sequencer.axi_seqr, {
                    cfg_id == 6'd19; cfg_addr == 32'h0000_0078;
                    cfg_data == 32'h3333_CCCC; cfg_strb == 4'hF;
                    cfg_user == 6'h00; cfg_bready_delay == 0;
                })

                `uvm_do_on_with(r1, p_sequencer.axi_seqr, {
                    cfg_id == 6'd20; cfg_addr == 32'h0000_0074;
                    cfg_user == 6'h00; cfg_rready_delay == 0;
                })

                `uvm_do_on_with(r2, p_sequencer.axi_seqr, {
                    cfg_id == 6'd21; cfg_addr == 32'h0000_0078;
                    cfg_user == 6'h00; cfg_rready_delay == 0;
                })

            end

            begin

                `uvm_do_on_with(
                    apb_sequence,
                    p_sequencer.apb_seqr,
                    {
                        cfg_response_count    == 6;
                        cfg_wait_cycles       == 0;
                        cfg_inject_error      == 0;
                        cfg_default_read_data == 32'h0000_0000;
                    }
                )

            end

        join

        `uvm_info(
            "MIXED_VSEQ",
            "Mixed read/write virtual sequence completed",
            UVM_LOW
        )

    endtask

endclass


// ============================================================================
// 11. AXI ID VIRTUAL SEQUENCE
//
// WRITE ID=23 followed by READ ID=41 from the same address.
// ============================================================================
class axi2apb_id_sequence extends axi2apb_bridge_base_sequence;

    `uvm_object_utils(axi2apb_id_sequence)

    axi_write_read_sequence          axi_sequence;
    apb_write_read_response_sequence apb_sequence;

    function new(string name = "axi2apb_id_sequence");
        super.new(name);
    endfunction

    virtual task body();

        `uvm_info(
            "ID_VSEQ",
            "Starting AXI ID write/read test",
            UVM_LOW
        )

        fork

            begin

                `uvm_do_on_with(
                    axi_sequence,
                    p_sequencer.axi_seqr,
                    {
                        cfg_addr         == 32'h0000_0090;
                        cfg_write_data   == 32'h55AA_55AA;
                        cfg_write_id     == 6'd23;
                        cfg_read_id      == 6'd41;
                        cfg_write_user   == 6'h00;
                        cfg_read_user    == 6'h00;
                        cfg_bready_delay == 0;
                        cfg_rready_delay == 0;
                    }
                )

            end

            begin

                `uvm_do_on_with(
                    apb_sequence,
                    p_sequencer.apb_seqr,
                    {
                        cfg_write_wait_cycles == 0;
                        cfg_read_wait_cycles  == 0;
                        cfg_write_error       == 0;
                        cfg_read_error        == 0;
                        cfg_default_read_data == 32'h0000_0000;
                    }
                )

            end

        join

        `uvm_info(
            "ID_VSEQ",
            "AXI ID virtual sequence completed",
            UVM_LOW
        )

    endtask

endclass


// ============================================================================
// 12. AXI USER VIRTUAL SEQUENCE
//
// WRITE USER=0x15 followed by READ USER=0x2A.
// ============================================================================
class axi2apb_user_sequence extends axi2apb_bridge_base_sequence;

    `uvm_object_utils(axi2apb_user_sequence)

    axi_write_read_sequence          axi_sequence;
    apb_write_read_response_sequence apb_sequence;

    function new(string name = "axi2apb_user_sequence");
        super.new(name);
    endfunction

    virtual task body();

        `uvm_info(
            "USER_VSEQ",
            "Starting AXI USER write/read test",
            UVM_LOW
        )

        fork

            begin

                `uvm_do_on_with(
                    axi_sequence,
                    p_sequencer.axi_seqr,
                    {
                        cfg_addr         == 32'h0000_00A0;
                        cfg_write_data   == 32'hABCD_EF01;
                        cfg_write_id     == 6'd24;
                        cfg_read_id      == 6'd25;
                        cfg_write_user   == 6'h15;
                        cfg_read_user    == 6'h2A;
                        cfg_bready_delay == 0;
                        cfg_rready_delay == 0;
                    }
                )

            end

            begin

                `uvm_do_on_with(
                    apb_sequence,
                    p_sequencer.apb_seqr,
                    {
                        cfg_write_wait_cycles == 0;
                        cfg_read_wait_cycles  == 0;
                        cfg_write_error       == 0;
                        cfg_read_error        == 0;
                        cfg_default_read_data == 32'h0000_0000;
                    }
                )

            end

        join

        `uvm_info(
            "USER_VSEQ",
            "AXI USER virtual sequence completed",
            UVM_LOW
        )

    endtask

endclass


// ============================================================================
// 13. APB PSLVERR OBSERVATION VIRTUAL SEQUENCE
//
// APB driver intentionally asserts PSLVERR for the write transfer.
// The supplied DUT behavior is checked by the existing scoreboard.
// ============================================================================
class axi2apb_pslverr_sequence extends axi2apb_bridge_base_sequence;

    `uvm_object_utils(axi2apb_pslverr_sequence)

    axi_write_sequence    axi_sequence;
    apb_response_sequence apb_sequence;

    function new(string name = "axi2apb_pslverr_sequence");
        super.new(name);
    endfunction

    virtual task body();

        `uvm_info(
            "ERR_VSEQ",
            "Starting APB PSLVERR observation test",
            UVM_LOW
        )

        fork

            begin

                `uvm_do_on_with(
                    axi_sequence,
                    p_sequencer.axi_seqr,
                    {
                        cfg_id           == 6'd26;
                        cfg_addr         == 32'h0000_00B0;
                        cfg_data         == 32'hBAD0_BAD0;
                        cfg_strb         == 4'hF;
                        cfg_user         == 6'h00;
                        cfg_bready_delay == 0;
                    }
                )

            end

            begin

                `uvm_do_on_with(
                    apb_sequence,
                    p_sequencer.apb_seqr,
                    {
                        cfg_response_count    == 1;
                        cfg_wait_cycles       == 0;
                        cfg_inject_error      == 1;
                        cfg_default_read_data == 32'h0000_0000;
                    }
                )

            end

        join

        `uvm_info(
            "ERR_VSEQ",
            "APB PSLVERR virtual sequence completed",
            UVM_LOW
        )

    endtask

endclass


// ============================================================================
// 14. CODE COVERAGE STRESS VIRTUAL SEQUENCE
//
// Purpose:
//   - Toggle the full AW/AR payload (address + ID + USER + sidebands)
//   - Exercise both 0->1 and 1->0 transitions with complementary patterns
//   - Exercise APB wait states while alternating reads/writes
//   - Preserve legal single-beat accesses for this bridge
// ============================================================================
class axi2apb_code_coverage_sequence extends axi2apb_bridge_base_sequence;

    `uvm_object_utils(axi2apb_code_coverage_sequence)

    function new(string name = "axi2apb_code_coverage_sequence");
        super.new(name);
    endfunction

    virtual task body();

        axi_write_sequence    wseq;
        axi_read_sequence     rseq;
        apb_response_sequence apb_sequence;

        bit [31:0] addr_pat [0:7];
        bit [31:0] data_pat [0:7];
        int unsigned i;

        addr_pat[0] = 32'h0000_0000;
        addr_pat[1] = 32'hFFFF_FFFC;
        addr_pat[2] = 32'hAAAA_AAA8;
        addr_pat[3] = 32'h5555_5554;
        addr_pat[4] = 32'hCCCC_CCCC;
        addr_pat[5] = 32'h3333_3330;
        addr_pat[6] = 32'hF0F0_F0F0;
        addr_pat[7] = 32'h0F0F_0F0C;

        data_pat[0] = 32'h0000_0000;
        data_pat[1] = 32'hFFFF_FFFF;
        data_pat[2] = 32'hAAAA_AAAA;
        data_pat[3] = 32'h5555_5555;
        data_pat[4] = 32'hCCCC_CCCC;
        data_pat[5] = 32'h3333_3333;
        data_pat[6] = 32'hF0F0_F0F0;
        data_pat[7] = 32'h0F0F_0F0F;

        `uvm_info("CODE_COV_VSEQ", "Starting code coverage stress sequence", UVM_LOW)

        fork

            begin
                // 8 writes + 8 reads = 16 AXI/APB transfers.
                for (i = 0; i < 8; i = i + 1) begin

                    wseq = axi_write_sequence::type_id::create(
                        $sformatf("wseq_%0d", i)
                    );

                    wseq.cfg_id           = (i[0]) ? 6'h3F : 6'h00;
                    wseq.cfg_addr         = addr_pat[i];
                    wseq.cfg_data         = data_pat[i];
                    wseq.cfg_strb         = (i[1:0] == 2'd0) ? 4'b0001 :
                                           (i[1:0] == 2'd1) ? 4'b0010 :
                                           (i[1:0] == 2'd2) ? 4'b0100 : 4'b1111;
                    wseq.cfg_user         = (i[0]) ? 6'h3F : 6'h00;
                    wseq.cfg_len          = 8'h00;       // legal single-beat AXI
                    wseq.cfg_size         = 3'd2;         // 32-bit transfer
                    wseq.cfg_burst        = (i[0]) ? 2'b01 : 2'b00; // INCR/FIXED
                    wseq.cfg_lock         = i[0];
                    wseq.cfg_cache        = (i[0]) ? 4'hF : 4'h0;
                    wseq.cfg_prot         = (i[0]) ? 3'h7 : 3'h0;
                    wseq.cfg_region       = (i[0]) ? 4'hF : 4'h0;
                    wseq.cfg_qos          = (i[0]) ? 4'hF : 4'h0;
                    wseq.cfg_bready_delay = i % 3;

                    wseq.start(p_sequencer.axi_seqr);

                    rseq = axi_read_sequence::type_id::create(
                        $sformatf("rseq_%0d", i)
                    );

                    rseq.cfg_id           = (i[0]) ? 6'h00 : 6'h3F;
                    rseq.cfg_addr         = addr_pat[7-i];
                    rseq.cfg_user         = (i[0]) ? 6'h00 : 6'h3F;
                    rseq.cfg_len          = 8'h00;       // legal single-beat AXI
                    rseq.cfg_size         = 3'd2;         // 32-bit transfer
                    rseq.cfg_burst        = (i[0]) ? 2'b00 : 2'b01; // FIXED/INCR
                    rseq.cfg_lock         = ~i[0];
                    rseq.cfg_cache        = (i[0]) ? 4'h0 : 4'hF;
                    rseq.cfg_prot         = (i[0]) ? 3'h0 : 3'h7;
                    rseq.cfg_region       = (i[0]) ? 4'h0 : 4'hF;
                    rseq.cfg_qos          = (i[0]) ? 4'h0 : 4'hF;
                    rseq.cfg_rready_delay = (i + 1) % 3;

                    rseq.start(p_sequencer.axi_seqr);

                end
            end

            begin
                apb_sequence = apb_response_sequence::type_id::create(
                    "apb_sequence"
                );
                apb_sequence.cfg_response_count    = 16;
                apb_sequence.cfg_wait_cycles       = 2;
                apb_sequence.cfg_inject_error      = 1'b0;
                apb_sequence.cfg_default_read_data = 32'hA5A5_5A5A;
                apb_sequence.start(p_sequencer.apb_seqr);
            end

        join

        `uvm_info("CODE_COV_VSEQ", "Code coverage stress sequence completed", UVM_LOW)

    endtask

endclass


// ============================================================================
// 15. FUNCTIONAL + CODE COVERAGE CLOSURE VIRTUAL SEQUENCE
//
// This sequence deliberately closes the reachable bins in axi2apb_coverage:
//   * READ/WRITE across LOW/MID/HIGH address ranges
//   * lower/upper/other boundaries
//   * zero/all-ones/AA/55/other data patterns
//   * low/mid/high ID and zero/low/mid/high USER
//   * full/no/partial WSTRB
//   * APB wait bins: 0, 1, 2-3, 4-15, 16+
//   * AXI BREADY/RREADY delays: 0, 1, 2-3, 4+
// It also alternates address/data/sideband bit patterns to improve RTL toggle
// coverage in AW/AR buffers, FIFOs and single-slice logic.
// ============================================================================
class axi2apb_functional_coverage_sequence extends axi2apb_bridge_base_sequence;

    `uvm_object_utils(axi2apb_functional_coverage_sequence)

    function new(string name = "axi2apb_functional_coverage_sequence");
        super.new(name);
    endfunction

    virtual task body();

        axi_write_sequence     wseq;
        axi_read_sequence      rseq;
        apb_response_sequence  apb_seq;

        bit [31:0] wr_addr [0:9];
        bit [31:0] rd_addr [0:9];
        bit [31:0] wr_data [0:9];
        bit [31:0] rd_data [0:9];
        bit [3:0]  wr_strb [0:9];
        bit [5:0]  id_pat  [0:9];
        bit [5:0]  usr_pat [0:9];
        int unsigned wait_pat [0:9];
        int unsigned bp_pat   [0:9];
        int unsigned i;

        // Cover LOW, MID, HIGH and exact lower/upper boundaries.
        wr_addr[0] = 32'h0000_0000;
        wr_addr[1] = 32'h0000_0104;
        wr_addr[2] = 32'h0000_0FFC;
        wr_addr[3] = 32'h0000_1000;
        wr_addr[4] = 32'h0000_8000;
        wr_addr[5] = 32'h0000_FFFC;
        wr_addr[6] = 32'h0001_0000;
        wr_addr[7] = 32'h5555_5554;
        wr_addr[8] = 32'hAAAA_AAA8;
        wr_addr[9] = 32'hFFFF_FFFC;

        // Keep read addresses distinct from writes so APB fallback read data
        // can deliberately hit all functional data-pattern bins.
        rd_addr[0] = 32'h0000_0004;
        rd_addr[1] = 32'h0000_0208;
        rd_addr[2] = 32'h0000_0FF8;
        rd_addr[3] = 32'h0000_1004;
        rd_addr[4] = 32'h0000_9000;
        rd_addr[5] = 32'h0000_FFF8;
        rd_addr[6] = 32'h0001_0004;
        rd_addr[7] = 32'h3333_3330;
        rd_addr[8] = 32'hCCCC_CCCC;
        rd_addr[9] = 32'hFFFF_FFF8;

        wr_data[0] = 32'h0000_0000;
        wr_data[1] = 32'hFFFF_FFFF;
        wr_data[2] = 32'hAAAA_AAAA;
        wr_data[3] = 32'h5555_5555;
        wr_data[4] = 32'h1234_5678;
        wr_data[5] = 32'h8765_4321;
        wr_data[6] = 32'hF0F0_F0F0;
        wr_data[7] = 32'h0F0F_0F0F;
        wr_data[8] = 32'hCCCC_CCCC;
        wr_data[9] = 32'h3333_3333;

        rd_data[0] = 32'h0000_0000;
        rd_data[1] = 32'hFFFF_FFFF;
        rd_data[2] = 32'hAAAA_AAAA;
        rd_data[3] = 32'h5555_5555;
        rd_data[4] = 32'h89AB_CDEF;
        rd_data[5] = 32'h7654_3210;
        rd_data[6] = 32'hA5A5_5A5A;
        rd_data[7] = 32'h5A5A_A5A5;
        rd_data[8] = 32'h1357_9BDF;
        rd_data[9] = 32'h2468_ACE0;

        // Hit FULL, NO_STROBE and multiple PARTIAL values.
        wr_strb[0] = 4'hF;
        wr_strb[1] = 4'h0;
        wr_strb[2] = 4'h1;
        wr_strb[3] = 4'h2;
        wr_strb[4] = 4'h4;
        wr_strb[5] = 4'h8;
        wr_strb[6] = 4'h3;
        wr_strb[7] = 4'hC;
        wr_strb[8] = 4'h5;
        wr_strb[9] = 4'hA;

        // LOW, MID and HIGH IDs plus full bit toggling.
        id_pat[0] = 6'd0;  id_pat[1] = 6'd7;
        id_pat[2] = 6'd8;  id_pat[3] = 6'd16;
        id_pat[4] = 6'd31; id_pat[5] = 6'd32;
        id_pat[6] = 6'd63; id_pat[7] = 6'h15;
        id_pat[8] = 6'h2A; id_pat[9] = 6'h3F;

        // ZERO, LOW, MID, HIGH USER bins.
        usr_pat[0] = 6'd0;  usr_pat[1] = 6'd1;
        usr_pat[2] = 6'd15; usr_pat[3] = 6'd16;
        usr_pat[4] = 6'd31; usr_pat[5] = 6'd32;
        usr_pat[6] = 6'd63; usr_pat[7] = 6'h15;
        usr_pat[8] = 6'h2A; usr_pat[9] = 6'h3F;

        // Functional bins: IMMEDIATE, ONE_WAIT, SHORT, LONG, VERY_LONG.
        wait_pat[0] = 0;  wait_pat[1] = 1;
        wait_pat[2] = 2;  wait_pat[3] = 3;
        wait_pat[4] = 4;  wait_pat[5] = 8;
        wait_pat[6] = 16; wait_pat[7] = 17;
        wait_pat[8] = 5;  wait_pat[9] = 20;

        // BREADY/RREADY bins: IMMEDIATE, ONE_WAIT, SHORT, LONG.
        bp_pat[0] = 0; bp_pat[1] = 1;
        bp_pat[2] = 2; bp_pat[3] = 3;
        bp_pat[4] = 4; bp_pat[5] = 5;
        bp_pat[6] = 0; bp_pat[7] = 1;
        bp_pat[8] = 2; bp_pat[9] = 4;

        `uvm_info("FUNC_COV_VSEQ", "Starting functional/code coverage closure sequence", UVM_LOW)

        // Alternate WRITE then READ. Across iterations this also creates both
        // WRITE->READ and READ->WRITE adjacency transitions.
        for (i = 0; i < 10; i = i + 1) begin

            wseq = axi_write_sequence::type_id::create($sformatf("fcov_wseq_%0d", i));
            apb_seq = apb_response_sequence::type_id::create($sformatf("fcov_apb_w_%0d", i));

            wseq.cfg_id           = id_pat[i];
            wseq.cfg_addr         = wr_addr[i];
            wseq.cfg_data         = wr_data[i];
            wseq.cfg_strb         = wr_strb[i];
            wseq.cfg_user         = usr_pat[i];
            wseq.cfg_len          = 8'h00;
            wseq.cfg_size         = 3'd2;
            wseq.cfg_burst        = i[0] ? 2'b01 : 2'b00;
            wseq.cfg_lock         = i[0];
            wseq.cfg_cache        = i[0] ? 4'hF : 4'h0;
            wseq.cfg_prot         = i[0] ? 3'h7 : 3'h0;
            wseq.cfg_region       = i[0] ? 4'hF : 4'h0;
            wseq.cfg_qos          = i[0] ? 4'hF : 4'h0;
            wseq.cfg_bready_delay = bp_pat[i];

            apb_seq.cfg_response_count    = 1;
            apb_seq.cfg_wait_cycles       = wait_pat[i];
            apb_seq.cfg_inject_error      = 1'b0;
            apb_seq.cfg_default_read_data = 32'h0000_0000;

            fork
                wseq.start(p_sequencer.axi_seqr);
                apb_seq.start(p_sequencer.apb_seqr);
            join

            rseq = axi_read_sequence::type_id::create($sformatf("fcov_rseq_%0d", i));
            apb_seq = apb_response_sequence::type_id::create($sformatf("fcov_apb_r_%0d", i));

            rseq.cfg_id           = id_pat[9-i];
            rseq.cfg_addr         = rd_addr[i];
            rseq.cfg_user         = usr_pat[9-i];
            rseq.cfg_len          = 8'h00;
            rseq.cfg_size         = 3'd2;
            rseq.cfg_burst        = i[0] ? 2'b00 : 2'b01;
            rseq.cfg_lock         = ~i[0];
            rseq.cfg_cache        = i[0] ? 4'h0 : 4'hF;
            rseq.cfg_prot         = i[0] ? 3'h0 : 3'h7;
            rseq.cfg_region       = i[0] ? 4'h0 : 4'hF;
            rseq.cfg_qos          = i[0] ? 4'h0 : 4'hF;
            rseq.cfg_rready_delay = bp_pat[9-i];

            apb_seq.cfg_response_count    = 1;
            apb_seq.cfg_wait_cycles       = wait_pat[9-i];
            apb_seq.cfg_inject_error      = 1'b0;
            apb_seq.cfg_default_read_data = rd_data[i];

            fork
                rseq.start(p_sequencer.axi_seqr);
                apb_seq.start(p_sequencer.apb_seqr);
            join

        end

        `uvm_info("FUNC_COV_VSEQ", "Functional/code coverage closure sequence completed", UVM_LOW)

    endtask

endclass


// ============================================================================
// 16. READ PSLVERR COVERAGE VIRTUAL SEQUENCE
// Complements the existing write PSLVERR test so APB READ x ERROR is covered.
// ============================================================================
class axi2apb_read_pslverr_sequence extends axi2apb_bridge_base_sequence;

    `uvm_object_utils(axi2apb_read_pslverr_sequence)

    function new(string name = "axi2apb_read_pslverr_sequence");
        super.new(name);
    endfunction

    virtual task body();

        axi_read_sequence      rseq;
        apb_response_sequence  apb_seq;

        rseq = axi_read_sequence::type_id::create("read_error_rseq");
        apb_seq = apb_response_sequence::type_id::create("read_error_apb_seq");

        rseq.cfg_id           = 6'h3E;
        rseq.cfg_addr         = 32'h0001_0104;
        rseq.cfg_user         = 6'h21;
        rseq.cfg_len          = 8'h00;
        rseq.cfg_size         = 3'd2;
        rseq.cfg_burst        = 2'b01;
        rseq.cfg_lock         = 1'b1;
        rseq.cfg_cache        = 4'hF;
        rseq.cfg_prot         = 3'h7;
        rseq.cfg_region       = 4'hF;
        rseq.cfg_qos          = 4'hF;
        rseq.cfg_rready_delay = 1;

        apb_seq.cfg_response_count    = 1;
        apb_seq.cfg_wait_cycles       = 1;
        apb_seq.cfg_inject_error      = 1'b1;
        apb_seq.cfg_default_read_data = 32'hAAAA_AAAA;

        `uvm_info("READ_PSLVERR_VSEQ", "Starting READ PSLVERR coverage sequence", UVM_LOW)

        fork
            rseq.start(p_sequencer.axi_seqr);
            apb_seq.start(p_sequencer.apb_seqr);
        join

        `uvm_info("READ_PSLVERR_VSEQ", "READ PSLVERR coverage sequence completed", UVM_LOW)

    endtask

endclass
