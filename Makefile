targets=1_Kotlin 2_Nix 3_Go 4_Zig 5_Elixir 6_Java 7_Prolog 8_Gleam 9_1_Ansible 9_2_Python 10_PHP 11_Rust 12_TypeScript 13_CSharp 14_Vala 15_V 16_Dart

all:
	$(foreach target,$(targets),$(MAKE) -C $(target) run &&) true
