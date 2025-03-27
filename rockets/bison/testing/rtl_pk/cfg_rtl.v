config cfg_rtl;
  design test.rocketTestHarness;
  default liblist `BSG_TEST_LIB_NAME;
  instance rocketTestHarness.dut.chip liblist `BSG_CHIP_LIB_NAME;
endconfig
