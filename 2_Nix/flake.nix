{
  description = "Advent of Code 2024, day 2";

  inputs.nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.11";

  outputs = { self, nixpkgs }: {
    default = import ./solution.nix {
      lib = nixpkgs.lib;
    };
    part-1 = self.outputs.default.safeCount;
    part-2 = self.outputs.default.safeCountDampened;
  };
}
