{
  description = "Advent of Code 2024, day 2";

  inputs.nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.11";

  outputs = { self, nixpkgs }: {
    part-1 = import ./solution.nix {
      lib = nixpkgs.lib;
    };
  };
}
