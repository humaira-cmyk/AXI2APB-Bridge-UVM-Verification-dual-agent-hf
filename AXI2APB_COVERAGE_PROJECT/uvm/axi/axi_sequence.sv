// ============================================================================
// AXI MASTER PHYSICAL SEQUENCES
//
// These sequences run only on axi_sequencer.
// The sequence body creates AXI items with `uvm_do_with.
// The AXI driver converts each item into pin-level AXI activity.
// ============================================================================


// ============================================================================
// 1. AXI WRITE SEQUENCE
// ============================================================================
class axi_write_sequence extends uvm_sequence #(axi_transaction);

    `uvm_object_utils(axi_write_sequence)

    rand bit [5:0]       cfg_id;
    rand bit [31:0]      cfg_addr;
    rand bit [31:0]      cfg_data;
    rand bit [3:0]       cfg_strb;
    rand bit [5:0]       cfg_user;
    rand bit [7:0]       cfg_len;
    rand bit [2:0]       cfg_size;
    rand bit [1:0]       cfg_burst;
    rand bit             cfg_lock;
    rand bit [3:0]       cfg_cache;
    rand bit [2:0]       cfg_prot;
    rand bit [3:0]       cfg_region;
    rand bit [3:0]       cfg_qos;
    rand int unsigned    cfg_bready_delay;

    function new(string name = "axi_write_sequence");
        super.new(name);

        cfg_id           = 6'd0;
        cfg_addr         = 32'h0000_0000;
        cfg_data         = 32'h0000_0000;
        cfg_strb         = 4'hF;
        cfg_user         = 6'h00;
        cfg_len          = 8'd0;
        cfg_size         = 3'd2;
        cfg_burst        = 2'b01;
        cfg_lock         = 1'b0;
        cfg_cache        = 4'h0;
        cfg_prot         = 3'h0;
        cfg_region       = 4'h0;
        cfg_qos          = 4'h0;
        cfg_bready_delay = 0;
    endfunction

    virtual task body();

        axi_transaction req;

        `uvm_info(
            "AXI_WRITE_SEQ",
            $sformatf(
                "Starting AXI WRITE: ID=%0d ADDR=0x%08h DATA=0x%08h BREADY_DELAY=%0d",
                cfg_id,
                cfg_addr,
                cfg_data,
                cfg_bready_delay
            ),
            UVM_LOW
        )

        `uvm_do_with(req, {

            simultaneous_rw == 1'b0;
            is_write        == 1'b1;

            id              == local::cfg_id;
            addr            == local::cfg_addr;
            data            == local::cfg_data;
            strb            == local::cfg_strb;
            user            == local::cfg_user;
            len             == local::cfg_len;
            size            == local::cfg_size;
            burst           == local::cfg_burst;
            lock            == local::cfg_lock;
            cache           == local::cfg_cache;
            prot            == local::cfg_prot;
            region          == local::cfg_region;
            qos             == local::cfg_qos;

            read_id         == 6'd0;
            read_addr       == 32'h0000_0000;
            read_user       == 6'h00;

            bready_delay    == local::cfg_bready_delay;
            rready_delay    == 0;

        })

        `uvm_info(
            "AXI_WRITE_SEQ",
            "AXI WRITE sequence completed",
            UVM_LOW
        )

    endtask

endclass


// ============================================================================
// 2. AXI READ SEQUENCE
// ============================================================================
class axi_read_sequence extends uvm_sequence #(axi_transaction);

    `uvm_object_utils(axi_read_sequence)

    rand bit [5:0]       cfg_id;
    rand bit [31:0]      cfg_addr;
    rand bit [5:0]       cfg_user;
    rand bit [7:0]       cfg_len;
    rand bit [2:0]       cfg_size;
    rand bit [1:0]       cfg_burst;
    rand bit             cfg_lock;
    rand bit [3:0]       cfg_cache;
    rand bit [2:0]       cfg_prot;
    rand bit [3:0]       cfg_region;
    rand bit [3:0]       cfg_qos;
    rand int unsigned    cfg_rready_delay;

    function new(string name = "axi_read_sequence");
        super.new(name);

        cfg_id           = 6'd0;
        cfg_addr         = 32'h0000_0000;
        cfg_user         = 6'h00;
        cfg_len          = 8'd0;
        cfg_size         = 3'd2;
        cfg_burst        = 2'b01;
        cfg_lock         = 1'b0;
        cfg_cache        = 4'h0;
        cfg_prot         = 3'h0;
        cfg_region       = 4'h0;
        cfg_qos          = 4'h0;
        cfg_rready_delay = 0;
    endfunction

    virtual task body();

        axi_transaction req;

        `uvm_info(
            "AXI_READ_SEQ",
            $sformatf(
                "Starting AXI READ: ID=%0d ADDR=0x%08h RREADY_DELAY=%0d",
                cfg_id,
                cfg_addr,
                cfg_rready_delay
            ),
            UVM_LOW
        )

        `uvm_do_with(req, {

            simultaneous_rw == 1'b0;
            is_write        == 1'b0;

            id              == local::cfg_id;
            addr            == local::cfg_addr;
            data            == 32'h0000_0000;
            strb            == 4'hF;
            user            == local::cfg_user;
            len             == local::cfg_len;
            size            == local::cfg_size;
            burst           == local::cfg_burst;
            lock            == local::cfg_lock;
            cache           == local::cfg_cache;
            prot            == local::cfg_prot;
            region          == local::cfg_region;
            qos             == local::cfg_qos;

            read_id         == 6'd0;
            read_addr       == 32'h0000_0000;
            read_user       == 6'h00;

            bready_delay    == 0;
            rready_delay    == local::cfg_rready_delay;

        })

        `uvm_info(
            "AXI_READ_SEQ",
            "AXI READ sequence completed",
            UVM_LOW
        )

    endtask

endclass


// ============================================================================
// 3. AXI WRITE -> READ SEQUENCE
//
// One write is followed by one read.  This is useful for tests that need
// both directions (ID and USER tests in this project).
// ============================================================================
class axi_write_read_sequence extends uvm_sequence #(axi_transaction);

    `uvm_object_utils(axi_write_read_sequence)

    rand bit [31:0]      cfg_addr;
    rand bit [31:0]      cfg_write_data;

    rand bit [5:0]       cfg_write_id;
    rand bit [5:0]       cfg_read_id;

    rand bit [5:0]       cfg_write_user;
    rand bit [5:0]       cfg_read_user;

    rand int unsigned    cfg_bready_delay;
    rand int unsigned    cfg_rready_delay;

    function new(string name = "axi_write_read_sequence");
        super.new(name);

        cfg_addr          = 32'h0000_0000;
        cfg_write_data    = 32'h0000_0000;
        cfg_write_id      = 6'd0;
        cfg_read_id       = 6'd0;
        cfg_write_user    = 6'h00;
        cfg_read_user     = 6'h00;
        cfg_bready_delay  = 0;
        cfg_rready_delay  = 0;
    endfunction

    virtual task body();

        axi_transaction req;

        `uvm_info(
            "AXI_WR_RD_SEQ",
            $sformatf(
                "Starting AXI WRITE->READ pair at ADDR=0x%08h DATA=0x%08h",
                cfg_addr,
                cfg_write_data
            ),
            UVM_LOW
        )

        // --------------------------------------------------------------------
        // WRITE REQUEST
        // --------------------------------------------------------------------
        `uvm_do_with(req, {

            simultaneous_rw == 1'b0;
            is_write        == 1'b1;

            id              == local::cfg_write_id;
            addr            == local::cfg_addr;
            data            == local::cfg_write_data;
            strb            == 4'hF;
            user            == local::cfg_write_user;

            read_id         == 6'd0;
            read_addr       == 32'h0000_0000;
            read_user       == 6'h00;

            bready_delay    == local::cfg_bready_delay;
            rready_delay    == 0;

        })

        // --------------------------------------------------------------------
        // READ REQUEST FROM THE SAME ADDRESS
        // --------------------------------------------------------------------
        `uvm_do_with(req, {

            simultaneous_rw == 1'b0;
            is_write        == 1'b0;

            id              == local::cfg_read_id;
            addr            == local::cfg_addr;
            data            == 32'h0000_0000;
            strb            == 4'hF;
            user            == local::cfg_read_user;

            read_id         == 6'd0;
            read_addr       == 32'h0000_0000;
            read_user       == 6'h00;

            bready_delay    == 0;
            rready_delay    == local::cfg_rready_delay;

        })

        `uvm_info(
            "AXI_WR_RD_SEQ",
            "AXI WRITE->READ sequence completed",
            UVM_LOW
        )

    endtask

endclass


// ============================================================================
// 4. AXI SIMULTANEOUS READ + WRITE SEQUENCE
//
// The current project uses one AXI sequencer/driver.  Therefore one sequence
// item carries both requests and the driver asserts the AXI read/write request
// channels together when simultaneous_rw=1.
// ============================================================================
class axi_simultaneous_rw_sequence extends uvm_sequence #(axi_transaction);

    `uvm_object_utils(axi_simultaneous_rw_sequence)

    rand bit [5:0]  cfg_write_id;
    rand bit [31:0] cfg_write_addr;
    rand bit [31:0] cfg_write_data;
    rand bit [5:0]  cfg_write_user;

    rand bit [5:0]  cfg_read_id;
    rand bit [31:0] cfg_read_addr;
    rand bit [5:0]  cfg_read_user;

    function new(string name = "axi_simultaneous_rw_sequence");
        super.new(name);

        cfg_write_id   = 6'd0;
        cfg_write_addr = 32'h0000_0000;
        cfg_write_data = 32'h0000_0000;
        cfg_write_user = 6'h00;

        cfg_read_id    = 6'd0;
        cfg_read_addr  = 32'h0000_0000;
        cfg_read_user  = 6'h00;
    endfunction

    virtual task body();

        axi_transaction req;

        `uvm_info(
            "AXI_SIM_RW_SEQ",
            "Starting simultaneous AXI READ + WRITE request",
            UVM_LOW
        )

        `uvm_do_with(req, {

            simultaneous_rw == 1'b1;

            // Write request uses normal fields.
            is_write        == 1'b1;
            id              == local::cfg_write_id;
            addr            == local::cfg_write_addr;
            data            == local::cfg_write_data;
            strb            == 4'hF;
            user            == local::cfg_write_user;

            // Read request uses the secondary fields.
            read_id         == local::cfg_read_id;
            read_addr       == local::cfg_read_addr;
            read_user       == local::cfg_read_user;

            bready_delay    == 0;
            rready_delay    == 0;

        })

        `uvm_info(
            "AXI_SIM_RW_SEQ",
            "Simultaneous AXI READ + WRITE sequence completed",
            UVM_LOW
        )

    endtask

endclass
