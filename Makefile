targets=1_Kotlin 2_Nix 3_Go 4_Zig 5_Elixir 6_Java 7_Prolog 8_Gleam

all:
	$(foreach target,$(targets),$(MAKE) -C $(target) run &&) true
