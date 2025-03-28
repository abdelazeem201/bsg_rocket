### Overview ###

This repository contains **portable chip designs**, as opposed to verilog modules, and
as opposed to a chip mapped to a particular tech node. A chip design
contains the following:

- a top level verilog file
- a list of files containing verilog modules instantiated by the chip design
- a list of include paths necessary to get those modules to work
- a list of timing constraint files for the top level module
- in some cases, some chip-design specific verilog modules that have been
  factored out of multiple similar chip designs
- a list of testing files for the testbench

## Usage ##

For a given chip design, we have many parallel flows:

- VCS simulation at RTL level
- FPGA simulation at RTL level
- Node specific processing (e.g. TSMC 250 or 16); e.g. Backend
     + Design Compiler synthesis for a particular tech node (e.g. TSMC 16 or 250)
     + IC Compiler P&R
     + VCS simulation of intermediate netlists
     + Formal Verification (e.g. Formality, Calibre)
     + DRC checking, LVS, etc.
     + Spice simulation

We want all of these views to be consistent and use the same set of files.
**For this reason, those tools should reference the files in bsg_design directly,
transforming them from the bsg_design versions to what the back end flow needs in an automatic
fashion.** Typically the files can be used directly (e.g. TCL or Make). This
way we can update the chip in bsg_design and the corresponding flows will automatically
make use of the changes without human intervention.

For node-specific processing, you sometimes want to substitute in node-specific
files; for example RAMs. The way this is done, is that files with the same interface
and name are implemented using the non-portable flow-specific primitives, and stored
with that flow. Then scripts should substitute the non-portable files in the bsg_design
file list automatically.

Here is a diagram that shows how components flow from modules to ASIC/FPGA:


                                       cad (ref-flow)--->|
    bsg_ip_cores (lib) -->|                              |-> chip (sim/tech-flow) -> ASIC
                          |-> bsg_designs (top-level)|-->|
    bsg_packaging (pkg) ->|                          |
                                                     |--> bsg_fpga (emulation) -> FPGA

### Organization ###

A sample directory structure or skeleton for bsg_designs is:

    |-- modules
    |   `-- module_foo                        # sub-top-level-module instantiated by bsg_chip.v
    |      |-- module_foo.v                  # these have been factored between multiple chips in bsg_design
    |      `-- submodule_bar_of_module_foo.v
    `-- toplevels
        |-- common
        |   |-- bsg_comm_link.constraint.tcl  # factored standard-ucsd-package-io constraints
        `-- bsg_two_loopback_manycore_clk_gen
            |
            |-- testing                       # testing directory
            |   |-- Makefile.vcs.include      # makefile variables specific to this design
            |   |-- filelist.tcl              # verilog files for testbench code
            |   |-- include.tcl               # include paths for the testbench code
            |   `-- bsg_gateway_chip.v        # toplevel for gateway chip
            |                                 # this is a (potentially non-synthesizeable) chip
            |                                 # that connects through PCB to your ASIC
            |                                 # and will use bsg_comm_link (master_p=1) if your
            |                                 # ASIC uses bsg_comm_link
            |                                 # typically sends test packets over bsg_comm_link
            |-- tcl
            |   |-- filelist.tcl              # list of modules required by bsg_chip.v
            |   |-- include.tcl               # list of paths required by bsg_chip.v
            |   |-- constraints.tcl           # main constraint file for toplevel
            |   |-- Makefile.include          # optional reference Makefile for env-variables
            |   |-- report_timing.tcl         # customized timing script for design
            |   `-- hard
            |       |
            |       `_ tsmc_180         
            |          |- filelist_deltas.tcl # files to replace from tcl/filelist.tcl for hardened version
            |          |- macro_placement.tcl # IC compiler script to place macros in floorplanning
            |          `- placement.tcl       # IC compiler script to place bounds and rp_groups
            `-- v
                |-- bsg_chip.v                # top-level-chip instance, contains I/Os, clk gens etc
                |-- bsg_test_node_client.v    # if module uses bsg_commlink, main digital block goes here
                `-- *.v                       # other design-specific files

### Adapting node-specific flow to use bsg_designs ###

- As mentioned earlier, bsg_designs only contains generic modules which means that
design-specific modules (e.g. RAMs) are replaced in each design inside the chip-repository.
Preferably this is done automatically by script, so as to reduce overhead for when source
is transferred, say from UCSD to Michigan.

For example, the scripts in charge of this replacement in chip 
(our TSMC 180 repo for Synopsys, be sure to checkout the bsg_tsmc180 branch), 
which are located at:

    |-- chip
        `-- design_foo
            `-- scripts
                `-- dc
                    |-- bsg_chip.filelist.tcl # source bsg_designs(filelist.tcl)
                    `-- bsg_chip.include.tcl  # source bsg_designs(include.tcl)

- Testing Simulation can be done using the chip repository, the testing environment is
organized as follows. 

This is currently for IC compiler and has not been ported to Cadence yet.

    |-- chip
        `-- design_foo
            `-- testing
                `-- rtl        # source bsg_designs(filelist.tcl, include.tcl)
                |              # this is the "portable verilog" version
                |-- rtl_hard   # source chip(bsg_chip.filelist.tcl, bsg_chip.include.tcl)
                |              # simulates process (e.g tsmc 180) specific code
                `-- post_place_and_route # simulates final netlist outputed from IC compiler

           
