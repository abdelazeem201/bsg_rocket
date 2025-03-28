rv64ui-p-asm-tests = \
	rv64ui-p-simple \
	rv64ui-p-add \
	rv64ui-p-addi \
	rv64ui-p-and \
	rv64ui-p-andi \
	rv64ui-p-auipc \
	rv64ui-p-beq \
	rv64ui-p-bge \
	rv64ui-p-bgeu \
	rv64ui-p-blt \
	rv64ui-p-bltu \
	rv64ui-p-bne \
	rv64ui-p-fence_i \
	rv64ui-p-j \
	rv64ui-p-jal \
	rv64ui-p-jalr \
	rv64ui-p-lb \
	rv64ui-p-lbu \
	rv64ui-p-lh \
	rv64ui-p-lhu \
	rv64ui-p-lui \
	rv64ui-p-lw \
	rv64ui-p-or \
	rv64ui-p-ori \
	rv64ui-p-sb \
	rv64ui-p-sh \
	rv64ui-p-sw \
	rv64ui-p-sll \
	rv64ui-p-slli \
	rv64ui-p-slt \
	rv64ui-p-slti \
	rv64ui-p-sra \
	rv64ui-p-srai \
	rv64ui-p-srl \
	rv64ui-p-srli \
	rv64ui-p-sub \
	rv64ui-p-xor \
	rv64ui-p-xori \
	rv64ui-p-addw \
	rv64ui-p-addiw \
	rv64ui-p-ld \
	rv64ui-p-lwu \
	rv64ui-p-sd \
	rv64ui-p-slliw \
	rv64ui-p-sllw \
	rv64ui-p-sltiu \
	rv64ui-p-sltu \
	rv64ui-p-sraiw \
	rv64ui-p-sraw \
	rv64ui-p-srliw \
	rv64ui-p-srlw \
	rv64ui-p-subw

$(addprefix $(ASM_TESTS_DIR)/, $(addsuffix .hex, $(rv64ui-p-asm-tests))): $(ASM_TESTS_DIR)/%.hex: $(RISCV)/riscv64-unknown-elf/share/riscv-tests/isa/%.hex
	mkdir -p $(ASM_TESTS_DIR)
	ln -fs $< $@

$(addprefix $(ASM_TESTS_DIR)/, $(rv64ui-p-asm-tests)): $(ASM_TESTS_DIR)/%: $(RISCV)/riscv64-unknown-elf/share/riscv-tests/isa/%
	mkdir -p $(ASM_TESTS_DIR)
	ln -fs $< $@

run-rv64ui-p-asm-tests: $(addprefix $(BSG_OUT_DIR)/, $(addsuffix .out, $(rv64ui-p-asm-tests)))
	@echo; perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' $^; echo;

run-rv64ui-p-asm-tests-debug: $(addprefix $(BSG_OUT_DIR)/, $(addsuffix .vpd, $(rv64ui-p-asm-tests)))
	@echo; perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' $(patsubst %.vpd,%.out,$^); echo;

rv64si-p-asm-tests = \
	rv64si-p-csr \
	rv64si-p-illegal \
	rv64si-p-ma_fetch \
	rv64si-p-ma_addr \
	rv64si-p-scall \
	rv64si-p-sbreak \
	rv64si-p-wfi

$(addprefix $(ASM_TESTS_DIR)/, $(addsuffix .hex, $(rv64si-p-asm-tests))): $(ASM_TESTS_DIR)/%.hex: $(RISCV)/riscv64-unknown-elf/share/riscv-tests/isa/%.hex
	mkdir -p $(ASM_TESTS_DIR)
	ln -fs $< $@

$(addprefix $(ASM_TESTS_DIR)/, $(rv64si-p-asm-tests)): $(ASM_TESTS_DIR)/%: $(RISCV)/riscv64-unknown-elf/share/riscv-tests/isa/%
	mkdir -p $(ASM_TESTS_DIR)
	ln -fs $< $@

run-rv64si-p-asm-tests: $(addprefix $(BSG_OUT_DIR)/, $(addsuffix .out, $(rv64si-p-asm-tests)))
	@echo; perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' $^; echo;

run-rv64si-p-asm-tests-debug: $(addprefix $(BSG_OUT_DIR)/, $(addsuffix .vpd, $(rv64si-p-asm-tests)))
	@echo; perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' $(patsubst %.vpd,%.out,$^); echo;

rv64mi-p-asm-tests = \
	rv64mi-p-csr \
	rv64mi-p-mcsr \
	rv64mi-p-wfi \
	rv64mi-p-dirty \
	rv64mi-p-illegal \
	rv64mi-p-ma_addr \
	rv64mi-p-ma_fetch \
	rv64mi-p-sbreak \
	rv64mi-p-scall \
	rv64mi-p-timer

$(addprefix $(ASM_TESTS_DIR)/, $(addsuffix .hex, $(rv64mi-p-asm-tests))): $(ASM_TESTS_DIR)/%.hex: $(RISCV)/riscv64-unknown-elf/share/riscv-tests/isa/%.hex
	mkdir -p $(ASM_TESTS_DIR)
	ln -fs $< $@

$(addprefix $(ASM_TESTS_DIR)/, $(rv64mi-p-asm-tests)): $(ASM_TESTS_DIR)/%: $(RISCV)/riscv64-unknown-elf/share/riscv-tests/isa/%
	mkdir -p $(ASM_TESTS_DIR)
	ln -fs $< $@

run-rv64mi-p-asm-tests: $(addprefix $(BSG_OUT_DIR)/, $(addsuffix .out, $(rv64mi-p-asm-tests)))
	@echo; perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' $^; echo;

run-rv64mi-p-asm-tests-debug: $(addprefix $(BSG_OUT_DIR)/, $(addsuffix .vpd, $(rv64mi-p-asm-tests)))
	@echo; perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' $(patsubst %.vpd,%.out,$^); echo;

rv64ui-pt-asm-tests = \
	rv64ui-pt-simple \
	rv64ui-pt-add \
	rv64ui-pt-addi \
	rv64ui-pt-and \
	rv64ui-pt-andi \
	rv64ui-pt-auipc \
	rv64ui-pt-beq \
	rv64ui-pt-bge \
	rv64ui-pt-bgeu \
	rv64ui-pt-blt \
	rv64ui-pt-bltu \
	rv64ui-pt-bne \
	rv64ui-pt-fence_i \
	rv64ui-pt-j \
	rv64ui-pt-jal \
	rv64ui-pt-jalr \
	rv64ui-pt-lb \
	rv64ui-pt-lbu \
	rv64ui-pt-lh \
	rv64ui-pt-lhu \
	rv64ui-pt-lui \
	rv64ui-pt-lw \
	rv64ui-pt-or \
	rv64ui-pt-ori \
	rv64ui-pt-sb \
	rv64ui-pt-sh \
	rv64ui-pt-sw \
	rv64ui-pt-sll \
	rv64ui-pt-slli \
	rv64ui-pt-slt \
	rv64ui-pt-slti \
	rv64ui-pt-sra \
	rv64ui-pt-srai \
	rv64ui-pt-srl \
	rv64ui-pt-srli \
	rv64ui-pt-sub \
	rv64ui-pt-xor \
	rv64ui-pt-xori \
	rv64ui-pt-addw \
	rv64ui-pt-addiw \
	rv64ui-pt-ld \
	rv64ui-pt-lwu \
	rv64ui-pt-sd \
	rv64ui-pt-slliw \
	rv64ui-pt-sllw \
	rv64ui-pt-sltiu \
	rv64ui-pt-sltu \
	rv64ui-pt-sraiw \
	rv64ui-pt-sraw \
	rv64ui-pt-srliw \
	rv64ui-pt-srlw \
	rv64ui-pt-subw

$(addprefix $(ASM_TESTS_DIR)/, $(addsuffix .hex, $(rv64ui-pt-asm-tests))): $(ASM_TESTS_DIR)/%.hex: $(RISCV)/riscv64-unknown-elf/share/riscv-tests/isa/%.hex
	mkdir -p $(ASM_TESTS_DIR)
	ln -fs $< $@

$(addprefix $(ASM_TESTS_DIR)/, $(rv64ui-pt-asm-tests)): $(ASM_TESTS_DIR)/%: $(RISCV)/riscv64-unknown-elf/share/riscv-tests/isa/%
	mkdir -p $(ASM_TESTS_DIR)
	ln -fs $< $@

run-rv64ui-pt-asm-tests: $(addprefix $(BSG_OUT_DIR)/, $(addsuffix .out, $(rv64ui-pt-asm-tests)))
	@echo; perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' $^; echo;

run-rv64ui-pt-asm-tests-debug: $(addprefix $(BSG_OUT_DIR)/, $(addsuffix .vpd, $(rv64ui-pt-asm-tests)))
	@echo; perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' $(patsubst %.vpd,%.out,$^); echo;

rv64um-pt-asm-tests = \
	rv64ui-pt-mul \
	rv64ui-pt-mulh \
	rv64ui-pt-mulhsu \
	rv64ui-pt-mulhu \
	rv64ui-pt-div \
	rv64ui-pt-divu \
	rv64ui-pt-rem \
	rv64ui-pt-remu \
	rv64ui-pt-divuw \
	rv64ui-pt-divw \
	rv64ui-pt-mulw \
	rv64ui-pt-remuw \
	rv64ui-pt-remw

$(addprefix $(ASM_TESTS_DIR)/, $(addsuffix .hex, $(rv64um-pt-asm-tests))): $(ASM_TESTS_DIR)/%.hex: $(RISCV)/riscv64-unknown-elf/share/riscv-tests/isa/%.hex
	mkdir -p $(ASM_TESTS_DIR)
	ln -fs $< $@

$(addprefix $(ASM_TESTS_DIR)/, $(rv64um-pt-asm-tests)): $(ASM_TESTS_DIR)/%: $(RISCV)/riscv64-unknown-elf/share/riscv-tests/isa/%
	mkdir -p $(ASM_TESTS_DIR)
	ln -fs $< $@

run-rv64um-pt-asm-tests: $(addprefix $(BSG_OUT_DIR)/, $(addsuffix .out, $(rv64um-pt-asm-tests)))
	@echo; perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' $^; echo;

run-rv64um-pt-asm-tests-debug: $(addprefix $(BSG_OUT_DIR)/, $(addsuffix .vpd, $(rv64um-pt-asm-tests)))
	@echo; perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' $(patsubst %.vpd,%.out,$^); echo;

rv64ua-pt-asm-tests = \
	rv64ui-pt-amoadd_w \
	rv64ui-pt-amoand_w \
	rv64ui-pt-amoor_w \
	rv64ui-pt-amoxor_w \
	rv64ui-pt-amoswap_w \
	rv64ui-pt-amomax_w \
	rv64ui-pt-amomaxu_w \
	rv64ui-pt-amomin_w \
	rv64ui-pt-amominu_w \
	rv64ui-pt-amoadd_d \
	rv64ui-pt-amoand_d \
	rv64ui-pt-amoor_d \
	rv64ui-pt-amoxor_d \
	rv64ui-pt-amoswap_d \
	rv64ui-pt-amomax_d \
	rv64ui-pt-amomaxu_d \
	rv64ui-pt-amomin_d \
	rv64ui-pt-amominu_d

$(addprefix $(ASM_TESTS_DIR)/, $(addsuffix .hex, $(rv64ua-pt-asm-tests))): $(ASM_TESTS_DIR)/%.hex: $(RISCV)/riscv64-unknown-elf/share/riscv-tests/isa/%.hex
	mkdir -p $(ASM_TESTS_DIR)
	ln -fs $< $@

$(addprefix $(ASM_TESTS_DIR)/, $(rv64ua-pt-asm-tests)): $(ASM_TESTS_DIR)/%: $(RISCV)/riscv64-unknown-elf/share/riscv-tests/isa/%
	mkdir -p $(ASM_TESTS_DIR)
	ln -fs $< $@

run-rv64ua-pt-asm-tests: $(addprefix $(BSG_OUT_DIR)/, $(addsuffix .out, $(rv64ua-pt-asm-tests)))
	@echo; perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' $^; echo;

run-rv64ua-pt-asm-tests-debug: $(addprefix $(BSG_OUT_DIR)/, $(addsuffix .vpd, $(rv64ua-pt-asm-tests)))
	@echo; perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' $(patsubst %.vpd,%.out,$^); echo;

rv64ui-v-asm-tests = \
	rv64ui-v-simple \
	rv64ui-v-add \
	rv64ui-v-addi \
	rv64ui-v-and \
	rv64ui-v-andi \
	rv64ui-v-auipc \
	rv64ui-v-beq \
	rv64ui-v-bge \
	rv64ui-v-bgeu \
	rv64ui-v-blt \
	rv64ui-v-bltu \
	rv64ui-v-bne \
	rv64ui-v-fence_i \
	rv64ui-v-j \
	rv64ui-v-jal \
	rv64ui-v-jalr \
	rv64ui-v-lb \
	rv64ui-v-lbu \
	rv64ui-v-lh \
	rv64ui-v-lhu \
	rv64ui-v-lui \
	rv64ui-v-lw \
	rv64ui-v-or \
	rv64ui-v-ori \
	rv64ui-v-sb \
	rv64ui-v-sh \
	rv64ui-v-sw \
	rv64ui-v-sll \
	rv64ui-v-slli \
	rv64ui-v-slt \
	rv64ui-v-slti \
	rv64ui-v-sra \
	rv64ui-v-srai \
	rv64ui-v-srl \
	rv64ui-v-srli \
	rv64ui-v-sub \
	rv64ui-v-xor \
	rv64ui-v-xori \
	rv64ui-v-addw \
	rv64ui-v-addiw \
	rv64ui-v-ld \
	rv64ui-v-lwu \
	rv64ui-v-sd \
	rv64ui-v-slliw \
	rv64ui-v-sllw \
	rv64ui-v-sltiu \
	rv64ui-v-sltu \
	rv64ui-v-sraiw \
	rv64ui-v-sraw \
	rv64ui-v-srliw \
	rv64ui-v-srlw \
	rv64ui-v-subw

$(addprefix $(ASM_TESTS_DIR)/, $(addsuffix .hex, $(rv64ui-v-asm-tests))): $(ASM_TESTS_DIR)/%.hex: $(RISCV)/riscv64-unknown-elf/share/riscv-tests/isa/%.hex
	mkdir -p $(ASM_TESTS_DIR)
	ln -fs $< $@

$(addprefix $(ASM_TESTS_DIR)/, $(rv64ui-v-asm-tests)): $(ASM_TESTS_DIR)/%: $(RISCV)/riscv64-unknown-elf/share/riscv-tests/isa/%
	mkdir -p $(ASM_TESTS_DIR)
	ln -fs $< $@

run-rv64ui-v-asm-tests: $(addprefix $(BSG_OUT_DIR)/, $(addsuffix .out, $(rv64ui-v-asm-tests)))
	@echo; perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' $^; echo;

run-rv64ui-v-asm-tests-debug: $(addprefix $(BSG_OUT_DIR)/, $(addsuffix .vpd, $(rv64ui-v-asm-tests)))
	@echo; perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' $(patsubst %.vpd,%.out,$^); echo;

rv64um-v-asm-tests = \
	rv64ui-v-mul \
	rv64ui-v-mulh \
	rv64ui-v-mulhsu \
	rv64ui-v-mulhu \
	rv64ui-v-div \
	rv64ui-v-divu \
	rv64ui-v-rem \
	rv64ui-v-remu \
	rv64ui-v-divuw \
	rv64ui-v-divw \
	rv64ui-v-mulw \
	rv64ui-v-remuw \
	rv64ui-v-remw

$(addprefix $(ASM_TESTS_DIR)/, $(addsuffix .hex, $(rv64um-v-asm-tests))): $(ASM_TESTS_DIR)/%.hex: $(RISCV)/riscv64-unknown-elf/share/riscv-tests/isa/%.hex
	mkdir -p $(ASM_TESTS_DIR)
	ln -fs $< $@

$(addprefix $(ASM_TESTS_DIR)/, $(rv64um-v-asm-tests)): $(ASM_TESTS_DIR)/%: $(RISCV)/riscv64-unknown-elf/share/riscv-tests/isa/%
	mkdir -p $(ASM_TESTS_DIR)
	ln -fs $< $@

run-rv64um-v-asm-tests: $(addprefix $(BSG_OUT_DIR)/, $(addsuffix .out, $(rv64um-v-asm-tests)))
	@echo; perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' $^; echo;

run-rv64um-v-asm-tests-debug: $(addprefix $(BSG_OUT_DIR)/, $(addsuffix .vpd, $(rv64um-v-asm-tests)))
	@echo; perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' $(patsubst %.vpd,%.out,$^); echo;

rv64ua-v-asm-tests = \
	rv64ui-v-amoadd_w \
	rv64ui-v-amoand_w \
	rv64ui-v-amoor_w \
	rv64ui-v-amoxor_w \
	rv64ui-v-amoswap_w \
	rv64ui-v-amomax_w \
	rv64ui-v-amomaxu_w \
	rv64ui-v-amomin_w \
	rv64ui-v-amominu_w \
	rv64ui-v-amoadd_d \
	rv64ui-v-amoand_d \
	rv64ui-v-amoor_d \
	rv64ui-v-amoxor_d \
	rv64ui-v-amoswap_d \
	rv64ui-v-amomax_d \
	rv64ui-v-amomaxu_d \
	rv64ui-v-amomin_d \
	rv64ui-v-amominu_d

$(addprefix $(ASM_TESTS_DIR)/, $(addsuffix .hex, $(rv64ua-v-asm-tests))): $(ASM_TESTS_DIR)/%.hex: $(RISCV)/riscv64-unknown-elf/share/riscv-tests/isa/%.hex
	mkdir -p $(ASM_TESTS_DIR)
	ln -fs $< $@

$(addprefix $(ASM_TESTS_DIR)/, $(rv64ua-v-asm-tests)): $(ASM_TESTS_DIR)/%: $(RISCV)/riscv64-unknown-elf/share/riscv-tests/isa/%
	mkdir -p $(ASM_TESTS_DIR)
	ln -fs $< $@

run-rv64ua-v-asm-tests: $(addprefix $(BSG_OUT_DIR)/, $(addsuffix .out, $(rv64ua-v-asm-tests)))
	@echo; perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' $^; echo;

run-rv64ua-v-asm-tests-debug: $(addprefix $(BSG_OUT_DIR)/, $(addsuffix .vpd, $(rv64ua-v-asm-tests)))
	@echo; perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' $(patsubst %.vpd,%.out,$^); echo;

rv64uf-p-asm-tests = \
	rv64uf-p-ldst \
	rv64uf-p-move \
	rv64uf-p-fsgnj \
	rv64uf-p-fcmp \
	rv64uf-p-fcvt \
	rv64uf-p-fcvt_w \
	rv64uf-p-fclass \
	rv64uf-p-fadd \
	rv64uf-p-fdiv \
	rv64uf-p-fmin \
	rv64uf-p-fmadd \
	rv64uf-p-structural

$(addprefix $(ASM_TESTS_DIR)/, $(addsuffix .hex, $(rv64uf-p-asm-tests))): $(ASM_TESTS_DIR)/%.hex: $(RISCV)/riscv64-unknown-elf/share/riscv-tests/isa/%.hex
	mkdir -p $(ASM_TESTS_DIR)
	ln -fs $< $@

$(addprefix $(ASM_TESTS_DIR)/, $(rv64uf-p-asm-tests)): $(ASM_TESTS_DIR)/%: $(RISCV)/riscv64-unknown-elf/share/riscv-tests/isa/%
	mkdir -p $(ASM_TESTS_DIR)
	ln -fs $< $@

run-rv64uf-p-asm-tests: $(addprefix $(BSG_OUT_DIR)/, $(addsuffix .out, $(rv64uf-p-asm-tests)))
	@echo; perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' $^; echo;

run-rv64uf-p-asm-tests-debug: $(addprefix $(BSG_OUT_DIR)/, $(addsuffix .vpd, $(rv64uf-p-asm-tests)))
	@echo; perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' $(patsubst %.vpd,%.out,$^); echo;

rv64uf-pt-asm-tests = \
	rv64uf-pt-ldst \
	rv64uf-pt-move \
	rv64uf-pt-fsgnj \
	rv64uf-pt-fcmp \
	rv64uf-pt-fcvt \
	rv64uf-pt-fcvt_w \
	rv64uf-pt-fclass \
	rv64uf-pt-fadd \
	rv64uf-pt-fdiv \
	rv64uf-pt-fmin \
	rv64uf-pt-fmadd \
	rv64uf-pt-structural

$(addprefix $(ASM_TESTS_DIR)/, $(addsuffix .hex, $(rv64uf-pt-asm-tests))): $(ASM_TESTS_DIR)/%.hex: $(RISCV)/riscv64-unknown-elf/share/riscv-tests/isa/%.hex
	mkdir -p $(ASM_TESTS_DIR)
	ln -fs $< $@

$(addprefix $(ASM_TESTS_DIR)/, $(rv64uf-pt-asm-tests)): $(ASM_TESTS_DIR)/%: $(RISCV)/riscv64-unknown-elf/share/riscv-tests/isa/%
	mkdir -p $(ASM_TESTS_DIR)
	ln -fs $< $@

run-rv64uf-pt-asm-tests: $(addprefix $(BSG_OUT_DIR)/, $(addsuffix .out, $(rv64uf-pt-asm-tests)))
	@echo; perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' $^; echo;

run-rv64uf-pt-asm-tests-debug: $(addprefix $(BSG_OUT_DIR)/, $(addsuffix .vpd, $(rv64uf-pt-asm-tests)))
	@echo; perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' $(patsubst %.vpd,%.out,$^); echo;

rv64uf-v-asm-tests = \
	rv64uf-v-ldst \
	rv64uf-v-move \
	rv64uf-v-fsgnj \
	rv64uf-v-fcmp \
	rv64uf-v-fcvt \
	rv64uf-v-fcvt_w \
	rv64uf-v-fclass \
	rv64uf-v-fadd \
	rv64uf-v-fdiv \
	rv64uf-v-fmin \
	rv64uf-v-fmadd \
	rv64uf-v-structural

$(addprefix $(ASM_TESTS_DIR)/, $(addsuffix .hex, $(rv64uf-v-asm-tests))): $(ASM_TESTS_DIR)/%.hex: $(RISCV)/riscv64-unknown-elf/share/riscv-tests/isa/%.hex
	mkdir -p $(ASM_TESTS_DIR)
	ln -fs $< $@

$(addprefix $(ASM_TESTS_DIR)/, $(rv64uf-v-asm-tests)): $(ASM_TESTS_DIR)/%: $(RISCV)/riscv64-unknown-elf/share/riscv-tests/isa/%
	mkdir -p $(ASM_TESTS_DIR)
	ln -fs $< $@

run-rv64uf-v-asm-tests: $(addprefix $(BSG_OUT_DIR)/, $(addsuffix .out, $(rv64uf-v-asm-tests)))
	@echo; perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' $^; echo;

run-rv64uf-v-asm-tests-debug: $(addprefix $(BSG_OUT_DIR)/, $(addsuffix .vpd, $(rv64uf-v-asm-tests)))
	@echo; perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' $(patsubst %.vpd,%.out,$^); echo;

run-asm-pt-tests: $(addprefix $(BSG_OUT_DIR)/, $(addsuffix .out, $(rv64ui-pt-asm-tests) $(rv64um-pt-asm-tests) $(rv64ua-pt-asm-tests) $(rv64uf-pt-asm-tests)))
	@echo; perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' $^; echo;
run-asm-pt-tests-debug: $(addprefix $(BSG_OUT_DIR)/, $(addsuffix .vpd, $(rv64ui-pt-asm-tests) $(rv64um-pt-asm-tests) $(rv64ua-pt-asm-tests) $(rv64uf-pt-asm-tests)))
	@echo; perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' $(patsubst %.vpd,%.out,$^); echo;
run-asm-pt-tests-fast: $(addprefix $(ASM_TESTS_DIR)/, $(addsuffix .run, $(rv64ui-pt-asm-tests) $(rv64um-pt-asm-tests) $(rv64ua-pt-asm-tests) $(rv64uf-pt-asm-tests)))
	@echo; perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' $^; echo;


run-asm-v-tests: $(addprefix $(BSG_OUT_DIR)/, $(addsuffix .out, $(rv64ui-v-asm-tests) $(rv64um-v-asm-tests) $(rv64ua-v-asm-tests) $(rv64uf-v-asm-tests)))
	@echo; perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' $^; echo;
run-asm-v-tests-debug: $(addprefix $(BSG_OUT_DIR)/, $(addsuffix .vpd, $(rv64ui-v-asm-tests) $(rv64um-v-asm-tests) $(rv64ua-v-asm-tests) $(rv64uf-v-asm-tests)))
	@echo; perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' $(patsubst %.vpd,%.out,$^); echo;
run-asm-v-tests-fast: $(addprefix $(ASM_TESTS_DIR)/, $(addsuffix .run, $(rv64ui-v-asm-tests) $(rv64um-v-asm-tests) $(rv64ua-v-asm-tests) $(rv64uf-v-asm-tests)))
	@echo; perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' $^; echo;


run-asm-p-tests: $(addprefix $(BSG_OUT_DIR)/, $(addsuffix .out, $(rv64ui-p-asm-tests) $(rv64si-p-asm-tests) $(rv64mi-p-asm-tests) $(rv64uf-p-asm-tests)))
	@echo; perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' $^; echo;
run-asm-p-tests-debug: $(addprefix $(BSG_OUT_DIR)/, $(addsuffix .vpd, $(rv64ui-p-asm-tests) $(rv64si-p-asm-tests) $(rv64mi-p-asm-tests) $(rv64uf-p-asm-tests)))
	@echo; perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' $(patsubst %.vpd,%.out,$^); echo;
run-asm-p-tests-fast: $(addprefix $(ASM_TESTS_DIR)/, $(addsuffix .run, $(rv64ui-p-asm-tests) $(rv64si-p-asm-tests) $(rv64mi-p-asm-tests) $(rv64uf-p-asm-tests)))
	@echo; perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' $^; echo;

run-asm-tests: $(addprefix $(BSG_OUT_DIR)/, $(addsuffix .out, $(rv64ui-p-asm-tests) $(rv64si-p-asm-tests) $(rv64mi-p-asm-tests) $(rv64ui-pt-asm-tests) $(rv64um-pt-asm-tests) $(rv64ua-pt-asm-tests) $(rv64ui-v-asm-tests) $(rv64um-v-asm-tests) $(rv64ua-v-asm-tests) $(rv64uf-p-asm-tests) $(rv64uf-pt-asm-tests) $(rv64uf-v-asm-tests)))
	@echo; perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' $^; echo;
run-asm-tests-debug: $(addprefix $(BSG_OUT_DIR)/, $(addsuffix .vpd, $(rv64ui-p-asm-tests) $(rv64si-p-asm-tests) $(rv64mi-p-asm-tests) $(rv64ui-pt-asm-tests) $(rv64um-pt-asm-tests) $(rv64ua-pt-asm-tests) $(rv64ui-v-asm-tests) $(rv64um-v-asm-tests) $(rv64ua-v-asm-tests) $(rv64uf-p-asm-tests) $(rv64uf-pt-asm-tests) $(rv64uf-v-asm-tests)))
	@echo; perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' $(patsubst %.vpd,%.out,$^); echo;
run-asm-tests-fast: $(addprefix $(ASM_TESTS_DIR)/, $(addsuffix .run, $(rv64ui-p-asm-tests) $(rv64si-p-asm-tests) $(rv64mi-p-asm-tests) $(rv64ui-pt-asm-tests) $(rv64um-pt-asm-tests) $(rv64ua-pt-asm-tests) $(rv64ui-v-asm-tests) $(rv64um-v-asm-tests) $(rv64ua-v-asm-tests) $(rv64uf-p-asm-tests) $(rv64uf-pt-asm-tests) $(rv64uf-v-asm-tests)))
	@echo; perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' $^; echo;

basic-bmark-tests = \
	median.riscv \
	multiply.riscv \
	qsort.riscv \
	towers.riscv \
	vvadd.riscv \
	mm.riscv \
	dhrystone.riscv \
	spmv.riscv \
	mt-vvadd.riscv \
	mt-matmul.riscv

$(addprefix $(ASM_TESTS_DIR)/, $(addsuffix .hex, $(basic-bmark-tests))): $(ASM_TESTS_DIR)/%.hex: $(RISCV)/riscv64-unknown-elf/share/riscv-tests/benchmarks/%.hex
	mkdir -p $(ASM_TESTS_DIR)
	ln -fs $< $@

$(addprefix $(ASM_TESTS_DIR)/, $(basic-bmark-tests)): $(ASM_TESTS_DIR)/%: $(RISCV)/riscv64-unknown-elf/share/riscv-tests/benchmarks/%
	mkdir -p $(ASM_TESTS_DIR)
	ln -fs $< $@

run-basic-bmark-tests: $(addprefix $(BSG_OUT_DIR)/, $(addsuffix .out, $(basic-bmark-tests)))
	@echo; perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' $^; echo;

run-basic-bmark-tests-debug: $(addprefix $(BSG_OUT_DIR)/, $(addsuffix .vpd, $(basic-bmark-tests)))
	@echo; perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' $(patsubst %.vpd,%.out,$^); echo;

run-bmark-tests: $(addprefix $(BSG_OUT_DIR)/, $(addsuffix .out, $(basic-bmark-tests)))
	@echo; perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' $^; echo;
run-bmark-tests-debug: $(addprefix $(BSG_OUT_DIR)/, $(addsuffix .vpd, $(basic-bmark-tests)))
	@echo; perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' $(patsubst %.vpd,%.out,$^); echo;
run-bmark-tests-fast: $(addprefix $(ASM_TESTS_DIR)/, $(addsuffix .run, $(basic-bmark-tests)))
	@echo; perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' $^; echo;
