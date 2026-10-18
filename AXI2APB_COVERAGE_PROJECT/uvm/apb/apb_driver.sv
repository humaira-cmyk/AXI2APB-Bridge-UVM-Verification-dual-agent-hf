class apb_driver extends uvm_driver #(apb_transaction);

    `uvm_component_utils(apb_driver)

    virtual APB_BUS apb_vif;

    // Simple APB slave memory model.
    bit [31:0] mem [bit [31:0]];

    function new(
        string name = "apb_driver",
        uvm_component parent = null
    );
        super.new(name, parent);
    endfunction


    virtual function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        `uvm_info("APB_DRV", "build_phase executed", UVM_LOW)

        if (!uvm_config_db #(virtual APB_BUS)::get(
                this, "", "apb_vif", apb_vif
            )) begin
            `uvm_fatal("APB_DRV", "APB virtual interface not found")
        end

    endfunction


    virtual task run_phase(uvm_phase phase);

        apb_transaction req;

        bit [31:0] held_addr;
        bit [31:0] held_wdata;
        bit        held_write;
        int unsigned i;

        `uvm_info("APB_DRV", "run_phase executed", UVM_LOW)

        apb_vif.pready  <= 1'b0;
        apb_vif.prdata  <= 32'h0000_0000;
        apb_vif.pslverr <= 1'b0;

        forever begin

            // One APB response item is required for one APB transfer.
            seq_item_port.get_next_item(req);

            // Wait until the DUT starts an APB ACCESS phase.
            do begin
                @(posedge apb_vif.clk);
            end
            while (!(
                (apb_vif.psel    === 1'b1) &&
                (apb_vif.penable === 1'b1)
            ));

            held_addr  = apb_vif.paddr;
            held_wdata = apb_vif.pwdata;
            held_write = apb_vif.pwrite;

            `uvm_info(
                "APB_DRV",
                $sformatf(
                    "ACCESS DETECTED: WRITE=%0d ADDR=%h WDATA=%h WAIT=%0d PSLVERR_CFG=%0d",
                    held_write, held_addr, held_wdata,
                    req.wait_cycles, req.inject_slverr
                ),
                UVM_MEDIUM
            )

            // -------------------------------------------------
            // Directed APB wait states
            // -------------------------------------------------
            for (i = 0; i < req.wait_cycles; i = i + 1) begin

                apb_vif.pready <= 1'b0;

                `uvm_info(
                    "APB_DRV",
                    $sformatf(
                        "WAIT STATE %0d/%0d: PREADY=0",
                        i+1, req.wait_cycles
                    ),
                    UVM_MEDIUM
                )

                @(posedge apb_vif.clk);

                if (apb_vif.penable !== 1'b1)
                    `uvm_error("APB_DRV", "PENABLE dropped while PREADY=0")

                if (apb_vif.paddr !== held_addr)
                    `uvm_error("APB_DRV", "PADDR changed during wait state")

                if (apb_vif.pwrite !== held_write)
                    `uvm_error("APB_DRV", "PWRITE changed during wait state")

                if (held_write && (apb_vif.pwdata !== held_wdata))
                    `uvm_error("APB_DRV", "PWDATA changed during wait state")

            end

            // -------------------------------------------------
            // APB slave data behavior
            // -------------------------------------------------
            if (held_write === 1'b1) begin

                mem[held_addr] = held_wdata;

                `uvm_info(
                    "APB_DRV",
                    $sformatf(
                        "WRITE RESPONSE: ADDR=%h DATA=%h",
                        held_addr, held_wdata
                    ),
                    UVM_MEDIUM
                )

            end
            else begin

                if (mem.exists(held_addr))
                    apb_vif.prdata <= mem[held_addr];
                else
                    apb_vif.prdata <= req.response_data;

                `uvm_info(
                    "APB_DRV",
                    $sformatf(
                        "READ RESPONSE: ADDR=%h DATA=%h",
                        held_addr,
                        mem.exists(held_addr) ? mem[held_addr] : req.response_data
                    ),
                    UVM_MEDIUM
                )

            end

            apb_vif.pslverr <= req.inject_slverr;
            apb_vif.pready  <= 1'b1;

            `uvm_info(
                "APB_DRV",
                $sformatf(
                    "TRANSFER COMPLETE: PREADY=1 PSLVERR=%0d",
                    req.inject_slverr
                ),
                UVM_MEDIUM
            )

            // Keep the APB response valid through one completing edge.
            @(posedge apb_vif.clk);

            apb_vif.pready  <= 1'b0;
            apb_vif.prdata  <= 32'h0000_0000;
            apb_vif.pslverr <= 1'b0;

            seq_item_port.item_done();

        end

    endtask

endclass
