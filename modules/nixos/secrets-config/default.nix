{
  options,
  config,
  lib,
  namespace,
  inputs,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.secrets-config;

  # Get the secrets directly from the flake outputs
  secretsData = inputs.secrets-repo;
in {
  options.${namespace}.secrets-config = with types; {
    enable = mkBoolOpt false "Whether or not to enable secrets configuration.";
  };

  config = mkIf cfg.enable {
    # Make secrets available via _module.args
    _module.args.secretsConfig = secretsData;
  };
}
