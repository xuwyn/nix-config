{inputs, ...}: {
  imports = [inputs.flake-parts.flakeModules.modules];
  systems = ["x86_64-linux" "aarch64-darwin"];

  perSystem = {system, ...}: {
    formatter = inputs.alejandra.packages.${system}.default;
  };
}
