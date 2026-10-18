// ============================================================
// AXI2APB DIRECTED TESTS
//
// All tests intentionally remain in ONE file.
// Each named test starts its own matching BRIDGE virtual sequence.
// No reference model is used.
// ============================================================


// ============================================================
// COMMON BASE TEST
// ============================================================
class axi2apb_base_test extends uvm_test;

    `uvm_component_utils(axi2apb_base_test)

    axi2apb_env env;
    string      test_label;

    function new(
        string name = "axi2apb_base_test",
        uvm_component parent = null
    );
        super.new(name, parent);
        test_label = "AXI2APB BASE TEST";
    endfunction

    virtual function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        `uvm_info("TEST", "axi2apb_base_test build_phase executed", UVM_LOW)

        uvm_top.set_timeout(100us, 0);

        env = axi2apb_env::type_id::create(
            "env",
            this
        );

    endfunction

    virtual task start_bridge_sequence(
        uvm_phase         phase,
        uvm_sequence_base seq
    );

        `uvm_info(
            "TEST",
            $sformatf("%s STARTED", test_label),
            UVM_LOW
        )

        phase.raise_objection(this);

        seq.start(env.vseqr);

        #100ns;

        phase.drop_objection(this);

        `uvm_info(
            "TEST",
            $sformatf("%s FINISHED", test_label),
            UVM_LOW
        )

    endtask

endclass


// ============================================================
// 1. SINGLE WRITE TEST
// ============================================================
class axi2apb_single_write_test extends axi2apb_base_test;

    `uvm_component_utils(axi2apb_single_write_test)

    function new(
        string name = "axi2apb_single_write_test",
        uvm_component parent = null
    );
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);

        test_label = "1. SINGLE WRITE TEST";

        uvm_config_db #(int)::set(
            this,
            "env.scoreboard",
            "expected_transactions",
            1
        );

        super.build_phase(phase);

        `uvm_info("TEST", "single write build_phase executed", UVM_LOW)

    endfunction

    virtual task run_phase(uvm_phase phase);

        axi2apb_single_write_sequence seq;

        `uvm_info("TEST", "single write run_phase executed", UVM_LOW)

        seq = axi2apb_single_write_sequence::type_id::create("seq");

        start_bridge_sequence(phase, seq);

    endtask

endclass


// ============================================================
// 2. SINGLE READ TEST
// ============================================================
class axi2apb_single_read_test extends axi2apb_base_test;

    `uvm_component_utils(axi2apb_single_read_test)

    function new(
        string name = "axi2apb_single_read_test",
        uvm_component parent = null
    );
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);

        test_label = "2. SINGLE READ TEST";

        uvm_config_db #(int)::set(
            this,
            "env.scoreboard",
            "expected_transactions",
            1
        );

        super.build_phase(phase);

        `uvm_info("TEST", "single read build_phase executed", UVM_LOW)

    endfunction

    virtual task run_phase(uvm_phase phase);

        axi2apb_single_read_sequence seq;

        `uvm_info("TEST", "single read run_phase executed", UVM_LOW)

        seq = axi2apb_single_read_sequence::type_id::create("seq");

        start_bridge_sequence(phase, seq);

    endtask

endclass


// ============================================================
// 3. RESET / SMOKE TEST
// ============================================================
class axi2apb_reset_test extends axi2apb_base_test;

    `uvm_component_utils(axi2apb_reset_test)

    function new(
        string name = "axi2apb_reset_test",
        uvm_component parent = null
    );
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);

        test_label = "3. RESET / SMOKE TEST";

        super.build_phase(phase);

        `uvm_info("TEST", "reset/smoke build_phase executed", UVM_LOW)

    endfunction

    virtual task run_phase(uvm_phase phase);

        axi2apb_smoke_sequence seq;

        `uvm_info("TEST", "reset/smoke run_phase executed", UVM_LOW)

        seq = axi2apb_smoke_sequence::type_id::create("seq");

        start_bridge_sequence(phase, seq);

    endtask

endclass


// ============================================================
// 4. APB WAIT-STATE TEST
// ============================================================
class axi2apb_wait_state_test extends axi2apb_base_test;

    `uvm_component_utils(axi2apb_wait_state_test)

    function new(
        string name = "axi2apb_wait_state_test",
        uvm_component parent = null
    );
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);

        test_label = "4. APB WAIT-STATE TEST";

        uvm_config_db #(int)::set(
            this,
            "env.scoreboard",
            "expected_transactions",
            1
        );

        super.build_phase(phase);

        `uvm_info("TEST", "wait-state build_phase executed", UVM_LOW)

    endfunction

    virtual task run_phase(uvm_phase phase);

        axi2apb_wait_state_sequence seq;

        `uvm_info("TEST", "wait-state run_phase executed", UVM_LOW)

        seq = axi2apb_wait_state_sequence::type_id::create("seq");

        start_bridge_sequence(phase, seq);

    endtask

endclass


// ============================================================
// 5. WRITE BACKPRESSURE TEST
// ============================================================
class axi2apb_write_backpressure_test extends axi2apb_base_test;

    `uvm_component_utils(axi2apb_write_backpressure_test)

    function new(
        string name = "axi2apb_write_backpressure_test",
        uvm_component parent = null
    );
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);

        test_label = "5. WRITE BACKPRESSURE TEST";

        uvm_config_db #(int)::set(
            this,
            "env.scoreboard",
            "expected_transactions",
            1
        );

        super.build_phase(phase);

        `uvm_info("TEST", "write backpressure build_phase executed", UVM_LOW)

    endfunction

    virtual task run_phase(uvm_phase phase);

        axi2apb_write_backpressure_sequence seq;

        `uvm_info("TEST", "write backpressure run_phase executed", UVM_LOW)

        seq = axi2apb_write_backpressure_sequence::type_id::create("seq");

        start_bridge_sequence(phase, seq);

    endtask

endclass


// ============================================================
// 6. READ BACKPRESSURE TEST
// ============================================================
class axi2apb_read_backpressure_test extends axi2apb_base_test;

    `uvm_component_utils(axi2apb_read_backpressure_test)

    function new(
        string name = "axi2apb_read_backpressure_test",
        uvm_component parent = null
    );
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);

        test_label = "6. READ BACKPRESSURE TEST";

        uvm_config_db #(int)::set(
            this,
            "env.scoreboard",
            "expected_transactions",
            1
        );

        super.build_phase(phase);

        `uvm_info("TEST", "read backpressure build_phase executed", UVM_LOW)

    endfunction

    virtual task run_phase(uvm_phase phase);

        axi2apb_read_backpressure_sequence seq;

        `uvm_info("TEST", "read backpressure run_phase executed", UVM_LOW)

        seq = axi2apb_read_backpressure_sequence::type_id::create("seq");

        start_bridge_sequence(phase, seq);

    endtask

endclass


// ============================================================
// 7. SIMULTANEOUS READ + WRITE TEST
// ============================================================
class axi2apb_simultaneous_rw_test extends axi2apb_base_test;

    `uvm_component_utils(axi2apb_simultaneous_rw_test)

    function new(
        string name = "axi2apb_simultaneous_rw_test",
        uvm_component parent = null
    );
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);

        test_label = "7. SIMULTANEOUS READ + WRITE TEST";

        uvm_config_db #(int)::set(
            this,
            "env.scoreboard",
            "expected_transactions",
            2
        );

        uvm_config_db #(int)::set(
            this,
            "env.scoreboard",
            "check_read_priority",
            1
        );

        super.build_phase(phase);

        `uvm_info("TEST", "simultaneous R/W build_phase executed", UVM_LOW)

    endfunction

    virtual task run_phase(uvm_phase phase);

        axi2apb_simultaneous_rw_sequence seq;

        `uvm_info("TEST", "simultaneous R/W run_phase executed", UVM_LOW)

        seq = axi2apb_simultaneous_rw_sequence::type_id::create("seq");

        start_bridge_sequence(phase, seq);

    endtask

endclass


// ============================================================
// 8. BACK-TO-BACK WRITE TEST
// ============================================================
class axi2apb_back_to_back_write_test extends axi2apb_base_test;

    `uvm_component_utils(axi2apb_back_to_back_write_test)

    function new(
        string name = "axi2apb_back_to_back_write_test",
        uvm_component parent = null
    );
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);

        test_label = "8. BACK-TO-BACK WRITE TEST";

        uvm_config_db #(int)::set(
            this,
            "env.scoreboard",
            "expected_transactions",
            4
        );

        super.build_phase(phase);

        `uvm_info("TEST", "back-to-back write build_phase executed", UVM_LOW)

    endfunction

    virtual task run_phase(uvm_phase phase);

        axi2apb_back_to_back_write_sequence seq;

        `uvm_info("TEST", "back-to-back write run_phase executed", UVM_LOW)

        seq = axi2apb_back_to_back_write_sequence::type_id::create("seq");

        start_bridge_sequence(phase, seq);

    endtask

endclass


// ============================================================
// 9. BACK-TO-BACK READ TEST
// ============================================================
class axi2apb_back_to_back_read_test extends axi2apb_base_test;

    `uvm_component_utils(axi2apb_back_to_back_read_test)

    function new(
        string name = "axi2apb_back_to_back_read_test",
        uvm_component parent = null
    );
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);

        test_label = "9. BACK-TO-BACK READ TEST";

        uvm_config_db #(int)::set(
            this,
            "env.scoreboard",
            "expected_transactions",
            4
        );

        super.build_phase(phase);

        `uvm_info("TEST", "back-to-back read build_phase executed", UVM_LOW)

    endfunction

    virtual task run_phase(uvm_phase phase);

        axi2apb_back_to_back_read_sequence seq;

        `uvm_info("TEST", "back-to-back read run_phase executed", UVM_LOW)

        seq = axi2apb_back_to_back_read_sequence::type_id::create("seq");

        start_bridge_sequence(phase, seq);

    endtask

endclass


// ============================================================
// 10. MIXED READ / WRITE TEST
// ============================================================
class axi2apb_mixed_rw_test extends axi2apb_base_test;

    `uvm_component_utils(axi2apb_mixed_rw_test)

    function new(
        string name = "axi2apb_mixed_rw_test",
        uvm_component parent = null
    );
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);

        test_label = "10. MIXED READ / WRITE TEST";

        uvm_config_db #(int)::set(
            this,
            "env.scoreboard",
            "expected_transactions",
            6
        );

        super.build_phase(phase);

        `uvm_info("TEST", "mixed R/W build_phase executed", UVM_LOW)

    endfunction

    virtual task run_phase(uvm_phase phase);

        axi2apb_mixed_rw_sequence seq;

        `uvm_info("TEST", "mixed R/W run_phase executed", UVM_LOW)

        seq = axi2apb_mixed_rw_sequence::type_id::create("seq");

        start_bridge_sequence(phase, seq);

    endtask

endclass


// ============================================================
// 11. AXI ID TEST
// ============================================================
class axi2apb_id_test extends axi2apb_base_test;

    `uvm_component_utils(axi2apb_id_test)

    function new(
        string name = "axi2apb_id_test",
        uvm_component parent = null
    );
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);

        test_label = "11. AXI ID TEST";

        uvm_config_db #(int)::set(
            this,
            "env.scoreboard",
            "expected_transactions",
            2
        );

        super.build_phase(phase);

        `uvm_info("TEST", "AXI ID build_phase executed", UVM_LOW)

    endfunction

    virtual task run_phase(uvm_phase phase);

        axi2apb_id_sequence seq;

        `uvm_info("TEST", "AXI ID run_phase executed", UVM_LOW)

        seq = axi2apb_id_sequence::type_id::create("seq");

        start_bridge_sequence(phase, seq);

    endtask

endclass


// ============================================================
// 12. AXI USER TEST
// ============================================================
class axi2apb_user_test extends axi2apb_base_test;

    `uvm_component_utils(axi2apb_user_test)

    function new(
        string name = "axi2apb_user_test",
        uvm_component parent = null
    );
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);

        test_label = "12. AXI USER TEST";

        uvm_config_db #(int)::set(
            this,
            "env.scoreboard",
            "expected_transactions",
            2
        );

        super.build_phase(phase);

        `uvm_info("TEST", "AXI USER build_phase executed", UVM_LOW)

    endfunction

    virtual task run_phase(uvm_phase phase);

        axi2apb_user_sequence seq;

        `uvm_info("TEST", "AXI USER run_phase executed", UVM_LOW)

        seq = axi2apb_user_sequence::type_id::create("seq");

        start_bridge_sequence(phase, seq);

    endtask

endclass


// ============================================================
// 13. APB PSLVERR OBSERVATION TEST
// ============================================================
class axi2apb_pslverr_test extends axi2apb_base_test;

    `uvm_component_utils(axi2apb_pslverr_test)

    function new(
        string name = "axi2apb_pslverr_test",
        uvm_component parent = null
    );
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);

        test_label = "13. APB PSLVERR OBSERVATION TEST";

        // Supplied RTL does not map PSLVERR to AXI SLVERR.
        // Therefore the scoreboard expects APB PSLVERR=1 and
        // the DUT's implemented AXI response value 00 (OKAY).
        uvm_config_db #(int)::set(
            this,
            "env.scoreboard",
            "expect_apb_error",
            1
        );

        uvm_config_db #(int)::set(
            this,
            "env.scoreboard",
            "expected_axi_resp_on_error",
            0
        );

        uvm_config_db #(int)::set(
            this,
            "env.scoreboard",
            "expected_transactions",
            1
        );

        super.build_phase(phase);

        `uvm_info("TEST", "PSLVERR build_phase executed", UVM_LOW)

    endfunction

    virtual task run_phase(uvm_phase phase);

        axi2apb_pslverr_sequence seq;

        `uvm_info("TEST", "PSLVERR run_phase executed", UVM_LOW)

        seq = axi2apb_pslverr_sequence::type_id::create("seq");

        start_bridge_sequence(phase, seq);

    endtask

endclass


// ============================================================
// 14. CODE COVERAGE STRESS TEST
// ============================================================
class axi2apb_code_coverage_test extends axi2apb_base_test;

    `uvm_component_utils(axi2apb_code_coverage_test)

    function new(
        string name = "axi2apb_code_coverage_test",
        uvm_component parent = null
    );
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);

        test_label = "14. CODE COVERAGE STRESS TEST";

        uvm_config_db #(int)::set(
            this,
            "env.scoreboard",
            "expected_transactions",
            16
        );

        super.build_phase(phase);

        `uvm_info("TEST", "code coverage stress build_phase executed", UVM_LOW)

    endfunction

    virtual task run_phase(uvm_phase phase);

        axi2apb_code_coverage_sequence seq;

        `uvm_info("TEST", "code coverage stress run_phase executed", UVM_LOW)

        seq = axi2apb_code_coverage_sequence::type_id::create("seq");

        start_bridge_sequence(phase, seq);

    endtask

    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("TEST", "code coverage stress report_phase executed", UVM_LOW)
    endfunction

endclass


// ============================================================
// 15. FUNCTIONAL + CODE COVERAGE CLOSURE TEST
// ============================================================
class axi2apb_functional_coverage_test extends axi2apb_base_test;

    `uvm_component_utils(axi2apb_functional_coverage_test)

    function new(
        string name = "axi2apb_functional_coverage_test",
        uvm_component parent = null
    );
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);

        test_label = "15. FUNCTIONAL + CODE COVERAGE CLOSURE TEST";

        uvm_config_db #(int)::set(
            this,
            "env.scoreboard",
            "expected_transactions",
            20
        );

        super.build_phase(phase);
        `uvm_info("TEST", "functional coverage closure build_phase executed", UVM_LOW)

    endfunction

    virtual task run_phase(uvm_phase phase);

        axi2apb_functional_coverage_sequence seq;

        `uvm_info("TEST", "functional coverage closure run_phase executed", UVM_LOW)

        seq = axi2apb_functional_coverage_sequence::type_id::create("seq");
        start_bridge_sequence(phase, seq);

    endtask

    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("TEST", "functional coverage closure report_phase executed", UVM_LOW)
    endfunction

endclass


// ============================================================
// 16. READ PSLVERR COVERAGE TEST
// ============================================================
class axi2apb_read_pslverr_test extends axi2apb_base_test;

    `uvm_component_utils(axi2apb_read_pslverr_test)

    function new(
        string name = "axi2apb_read_pslverr_test",
        uvm_component parent = null
    );
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);

        test_label = "16. READ PSLVERR COVERAGE TEST";

        uvm_config_db #(int)::set(this, "env.scoreboard", "expect_apb_error", 1);
        uvm_config_db #(int)::set(this, "env.scoreboard", "expected_axi_resp_on_error", 0);
        uvm_config_db #(int)::set(this, "env.scoreboard", "expected_transactions", 1);

        super.build_phase(phase);
        `uvm_info("TEST", "read PSLVERR coverage build_phase executed", UVM_LOW)

    endfunction

    virtual task run_phase(uvm_phase phase);

        axi2apb_read_pslverr_sequence seq;

        `uvm_info("TEST", "read PSLVERR coverage run_phase executed", UVM_LOW)

        seq = axi2apb_read_pslverr_sequence::type_id::create("seq");
        start_bridge_sequence(phase, seq);

    endtask

    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("TEST", "read PSLVERR coverage report_phase executed", UVM_LOW)
    endfunction

endclass
