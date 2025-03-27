config cfg_gate;
  design test.rocketTestHarness;
  default liblist `BSG_TEST_LIB_NAME work;
  instance rocketTestHarness.dut.chip liblist work;
endconfig
