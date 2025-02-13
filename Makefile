
test:
	@echo "===> Testing"
	@nvim --headless --noplugin -u tests/nvim_config.vim \
		-c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/nvim_config.vim'}"

fmt:
	@echo "===> Formatting"
	stylua lua/ --config-path=.stylua.toml

lint:
	@echo "===> Linting"
	luacheck lua/ --globals vim


pr-ready: test
