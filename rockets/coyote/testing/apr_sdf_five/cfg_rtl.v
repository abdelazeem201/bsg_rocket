config cfg_rtl;
  design test.test_five;
  default liblist `BSG_TEST_LIB_NAME;
  instance test_five.dut.chip liblist `BSG_CHIP_LIB_NAME `PDK_LIB_NAME;
  instance test_five.dut.chip.g.n_0__clnt liblist `COYOTE_LIB_NAME `PDK_LIB_NAME;
  instance test_five.dut.chip.g.n_1__clnt liblist `COYOTE_LIB_NAME `PDK_LIB_NAME;
  instance test_five.dut.chip.g.n_2__clnt liblist `COYOTE_LIB_NAME `PDK_LIB_NAME;
  instance test_five.dut.chip.g.n_3__clnt liblist `COYOTE_LIB_NAME `PDK_LIB_NAME;
  instance test_five.dut.chip.g.n_4__clnt liblist `COYOTE_LIB_NAME `PDK_LIB_NAME;
  instance test_five.dut.chip.g.acc.bnn_rocc_inst liblist `BNN_LIB_NAME `PDK_LIB_NAME;
  instance test_five.dut.chip.g.acc.manycore_rocc_inst.UUT liblist `MANYCORE_LIB_NAME `PDK_LIB_NAME;
  instance test_five.dut.chip.g.dcdc_block.dcdc_manycore liblist `DCDC_MANYCORE_LIB_NAME `PDK_LIB_NAME;
endconfig
