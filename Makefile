
test:
	@echo "===> Testing"
	@nvim --headless --noplugin -u tests/nvim_config.vim \
		-c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/nvim_config.vim'}"

pr-ready: test
