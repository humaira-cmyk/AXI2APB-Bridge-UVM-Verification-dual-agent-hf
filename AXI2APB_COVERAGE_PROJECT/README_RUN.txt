AXI2APB UVM - VCS 2016 / UVM 1.2
=================================

IMPORTANT
---------
Keep the project in a Linux path with NO spaces and NO parentheses.
Example safe path:
  /root/Documents/AXI2APB_COVERAGE_PROJECT

Always run commands from the sim/ directory.

1) COMPILE ONLY
---------------
make compile TEST=axi2apb_single_write_test

2) SIMULATE ONLY
----------------
make sim TEST=axi2apb_single_write_test

3) OPEN WAVEFORM
----------------
make gui TEST=axi2apb_single_write_test

4) REGRESSION
-------------
make regression

5) CODE COVERAGE
----------------
make code_covg
make code_covg_gui

6) FUNCTIONAL COVERAGE
----------------------
make func_covg
make func_covg_gui

7) CLEAN
--------
make clean TEST=axi2apb_single_write_test
make clean_all

Notes
-----
- make compile does ONLY compilation.
- make sim does ONLY simulation and requires that test to be compiled first.
- regression compiles then simulates every directed test.
- single write/read virtual sequences keep their requested uvm_do_on_with randomization.
- RTL is not modified.


COVERAGE CLOSURE ADDITIONS
==========================
New tests:
  axi2apb_code_coverage_test
  axi2apb_functional_coverage_test
  axi2apb_read_pslverr_test

Recommended flow from sim/:
  make clean_all
  make regression
  make all_covg
  make code_covg_gui
  make func_covg_gui

Functional model notes:
  * AXI EXOKAY/SLVERR/DECERR are ignored because supplied RTL always returns OKAY.
  * Simultaneous arbitration WRITE_FIRST is ignored because supplied RTL has READ priority.
  * RLAST=0 is ignored because this environment verifies single-beat LEN=0 transfers only.
These are unsupported/unreachable implementation states, not stimulus coverage holes.
