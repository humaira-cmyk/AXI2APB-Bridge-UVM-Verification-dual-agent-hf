# ============================================================
# AXI2APB UVM VERIFICATION - CLEAN MAKEFILE
# Synopsys VCS L-2016.06 Full64 + UVM 1.2
#
# Run all commands from the sim/ directory.
#
#   make compile TEST=<test_name>   -> compile only
#   make sim     TEST=<test_name>   -> simulate only
#   make gui     TEST=<test_name>   -> open waveform
#   make regression                 -> compile + simulate all tests
#   make code_covg                  -> merged code coverage WITH exclusions
#   make code_covg_raw              -> merged code coverage WITHOUT exclusions
#   make func_covg                  -> merged functional coverage report
#
# IMPORTANT:
#   sim/cm_hier.cfg must contain:
#
#       +tree axi2apb_tb_top
#
#   Put the exclusion file here:
#
#       sim/exclu.el
# ============================================================

VCS  := vcs
URG  := urg

TEST ?= axi2apb_single_write_test

UVM_DIR   := ../uvm
OUT_DIR   := out
RUN_DIR   := $(OUT_DIR)/build_$(TEST)

CM        := line+cond+tgl
CM_HIER   := cm_hier.cfg
EXCL_FILE := exclu.el

# ============================================================
# DIRECTED REGRESSION TESTS
# ============================================================
TESTS := \
	axi2apb_single_write_test \
	axi2apb_single_read_test \
	axi2apb_reset_test \
	axi2apb_wait_state_test \
	axi2apb_write_backpressure_test \
	axi2apb_read_backpressure_test \
	axi2apb_simultaneous_rw_test \
	axi2apb_back_to_back_write_test \
	axi2apb_back_to_back_read_test \
	axi2apb_mixed_rw_test \
	axi2apb_id_test \
	axi2apb_user_test \
	axi2apb_pslverr_test \
	axi2apb_code_coverage_test \
	axi2apb_functional_coverage_test \
	axi2apb_read_pslverr_test

# ============================================================
# COMPILE ONLY
# ============================================================
compile:
	@case "$(CURDIR)" in \
		*" "*|*"("*|*")"*) \
			echo "ERROR: VCS 2016 cannot safely build from a path containing spaces or parentheses."; \
			echo "Move/rename the project to a simple path, for example:"; \
			echo "  /root/Documents/AXI2APB_COVERAGE_PROJECT"; \
			exit 1 ;; \
	esac

	@if [ ! -f "$(CM_HIER)" ]; then \
		echo "ERROR: $(CM_HIER) not found in sim/."; \
		exit 1; \
	fi

	@echo "============================================================"
	@echo " COMPILE: $(TEST)"
	@echo " Coverage hierarchy file: $(CM_HIER)"
	@echo "============================================================"

	@mkdir -p $(OUT_DIR)
	@rm -rf $(RUN_DIR)
	@mkdir -p $(RUN_DIR)

	@cd $(UVM_DIR) && \
	rm -rf csrc simv.daidir simv.vdb simv vc_hdrs.h \
	       ucli.key cm.log tr_db.log

	cd $(UVM_DIR) && $(VCS) \
		-full64 \
		-sverilog \
		-timescale=1ns/1ps \
		-ntb_opts uvm-1.2 \
		-debug_access+all \
		-lca \
		-cm $(CM) \
		-cm_noconst \
		-cm_hier ../sim/$(CM_HIER) \
		-f build.flist \
		-top axi2apb_tb_top \
		-o simv \
		-l ../sim/$(RUN_DIR)/compile_$(TEST).log

	@cd $(UVM_DIR) && \
	for f in csrc simv.daidir simv.vdb simv vc_hdrs.h \
	         ucli.key cm.log tr_db.log; do \
		if [ -e "$$f" ]; then \
			mv "$$f" ../sim/$(RUN_DIR)/; \
		fi; \
	done

	@echo "Compile complete: $(RUN_DIR)"

# ============================================================
# SIMULATION ONLY
# ============================================================
sim:
	@if [ ! -x "$(RUN_DIR)/simv" ]; then \
		echo "ERROR: $(RUN_DIR)/simv not found."; \
		echo "First run:"; \
		echo "  make compile TEST=$(TEST)"; \
		exit 1; \
	fi

	@echo "============================================================"
	@echo " SIMULATION: $(TEST)"
	@echo "============================================================"

	cd $(RUN_DIR) && ./simv \
		-cm $(CM) \
		+UVM_TESTNAME=$(TEST) \
		-l log_build_$(TEST).log

	@echo "Simulation complete: $(RUN_DIR)"

# ============================================================
# OPEN WAVEFORM
# ============================================================
gui:
	@if [ ! -f "$(RUN_DIR)/waveform.vpd" ]; then \
		echo "ERROR: $(RUN_DIR)/waveform.vpd not found."; \
		echo "Compile and simulate the test first."; \
		exit 1; \
	fi
	cd $(RUN_DIR) && dve -vpd waveform.vpd &

# ============================================================
# REGRESSION
# ============================================================
regression:
	@echo "============================================================"
	@echo " AXI2APB DIRECTED REGRESSION STARTED"
	@echo "============================================================"

	@for t in $(TESTS); do \
		echo ""; \
		echo "------------------------------------------------------------"; \
		echo " TEST: $$t"; \
		echo "------------------------------------------------------------"; \
		$(MAKE) compile TEST=$$t || exit $$?; \
		$(MAKE) sim TEST=$$t || exit $$?; \
	done

	@echo ""
	@echo "============================================================"
	@echo " AXI2APB DIRECTED REGRESSION FINISHED"
	@echo "============================================================"

# ============================================================
# CODE COVERAGE WITH EXCLUSION FILE
#
# Complete top hierarchy is collected using cm_hier.cfg:
#   +tree axi2apb_tb_top
# Then sim/exclu.el is applied by URG.
# ============================================================
code_covg:
	@echo "============================================================"
	@echo " CODE COVERAGE: COMPLETE TOP + EXCLUSIONS"
	@echo " Hierarchy: $(CM_HIER)"
	@echo " Exclusion file: $(EXCL_FILE)"
	@echo "============================================================"

	@if [ ! -f "$(EXCL_FILE)" ]; then \
		echo "ERROR: exclusion file $(EXCL_FILE) not found."; \
		echo "Expected location: sim/$(EXCL_FILE)"; \
		exit 1; \
	fi

	@if ! ls $(OUT_DIR)/build_*/simv.vdb >/dev/null 2>&1; then \
		echo "ERROR: no coverage databases found."; \
		echo "Run make regression first."; \
		exit 1; \
	fi

	rm -rf $(OUT_DIR)/code_coverage_report

	@dirs=""; \
	for d in $(OUT_DIR)/build_*/simv.vdb; do \
		if [ -d "$$d" ]; then \
			dirs="$$dirs -dir $$d"; \
		fi; \
	done; \
	$(URG) $$dirs \
		-metric line+cond+tgl \
		-elfile $(EXCL_FILE) \
		-report $(OUT_DIR)/code_coverage_report

	@echo "Adjusted code coverage report:"
	@echo "$(OUT_DIR)/code_coverage_report/dashboard.html"

# ============================================================
# RAW CODE COVERAGE WITHOUT EXCLUSIONS
# ============================================================
code_covg_raw:
	@echo "============================================================"
	@echo " RAW CODE COVERAGE: COMPLETE TOP, NO EXCLUSIONS"
	@echo "============================================================"

	@if ! ls $(OUT_DIR)/build_*/simv.vdb >/dev/null 2>&1; then \
		echo "ERROR: no coverage databases found."; \
		echo "Run make regression first."; \
		exit 1; \
	fi

	rm -rf $(OUT_DIR)/code_coverage_raw_report

	@dirs=""; \
	for d in $(OUT_DIR)/build_*/simv.vdb; do \
		if [ -d "$$d" ]; then \
			dirs="$$dirs -dir $$d"; \
		fi; \
	done; \
	$(URG) $$dirs \
		-metric line+cond+tgl \
		-report $(OUT_DIR)/code_coverage_raw_report

	@echo "Raw code coverage report:"
	@echo "$(OUT_DIR)/code_coverage_raw_report/dashboard.html"

# ============================================================
# FUNCTIONAL COVERAGE
# ============================================================
func_covg:
	@if ! ls $(OUT_DIR)/build_*/simv.vdb >/dev/null 2>&1; then \
		echo "ERROR: no coverage databases found."; \
		echo "Run tests or make regression first."; \
		exit 1; \
	fi

	rm -rf $(OUT_DIR)/functional_coverage_report

	@dirs=""; \
	for d in $(OUT_DIR)/build_*/simv.vdb; do \
		if [ -d "$$d" ]; then \
			dirs="$$dirs -dir $$d"; \
		fi; \
	done; \
	$(URG) $$dirs \
		-metric group \
		-report $(OUT_DIR)/functional_coverage_report

	@echo "Functional coverage report:"
	@echo "$(OUT_DIR)/functional_coverage_report/dashboard.html"

# ============================================================
# GENERATE BOTH COVERAGE REPORTS
# ============================================================
all_covg: code_covg func_covg
	@echo "Both code and functional coverage reports generated."

# ============================================================
# OPEN COVERAGE REPORTS
# ============================================================
code_covg_gui:
	@if [ ! -f "$(OUT_DIR)/code_coverage_report/dashboard.html" ]; then \
		echo "ERROR: adjusted code coverage report not found."; \
		echo "Run make code_covg first."; \
		exit 1; \
	fi
	firefox $(OUT_DIR)/code_coverage_report/dashboard.html &

code_covg_raw_gui:
	@if [ ! -f "$(OUT_DIR)/code_coverage_raw_report/dashboard.html" ]; then \
		echo "ERROR: raw code coverage report not found."; \
		echo "Run make code_covg_raw first."; \
		exit 1; \
	fi
	firefox $(OUT_DIR)/code_coverage_raw_report/dashboard.html &

func_covg_gui:
	@if [ ! -f "$(OUT_DIR)/functional_coverage_report/dashboard.html" ]; then \
		echo "ERROR: functional coverage report not found."; \
		echo "Run make func_covg first."; \
		exit 1; \
	fi
	firefox $(OUT_DIR)/functional_coverage_report/dashboard.html &

# ============================================================
# CLEAN
# ============================================================
clean:
	rm -rf $(RUN_DIR)

clean_all:
	rm -rf $(OUT_DIR)/build_*
	rm -rf $(OUT_DIR)/code_coverage_report
	rm -rf $(OUT_DIR)/code_coverage_raw_report
	rm -rf $(OUT_DIR)/functional_coverage_report

.PHONY: compile sim gui regression \
	code_covg code_covg_raw func_covg all_covg \
	code_covg_gui code_covg_raw_gui func_covg_gui \
	clean clean_all

