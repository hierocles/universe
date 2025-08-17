{
  options,
  config,
  pkgs,
  lib,
  inputs,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.security.sops;
in {
  options.${namespace}.security.sops = with types; {
    enable = mkBoolOpt false "Whether or not to enable SOPS for secrets management.";
    defaultSopsFile = mkOpt (nullOr path) null "The default SOPS file to use for secrets management.";
    ageSshKeyPaths = mkOpt (listOf str) [] "The paths to the SSH keys to use for SOPS.";
    secrets = mkOpt attrs {} "A set of secrets to manage.";
    ageKeyFile = mkOpt (nullOr str) null "The path to the age key file to use for SOPS.";
    validate = mkBoolOpt true "Whether or not to validate the SOPS files. Default: true";
    templates = mkOpt attrs {} "A set of templates to use for SOPS.";

    # Multi-user helpers
    userSecrets = mkOpt attrs {} "User-specific secrets organized by username.";
    sharedSecrets = mkOpt attrs {} "Secrets shared between multiple users.";
    serviceSecrets = mkOpt attrs {} "Secrets for system services.";
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.ageSshKeyPaths != [] || cfg.ageKeyFile != null;
        message = "At least one of universe.security.sops.ageSshKeyPaths or universe.security.sops.ageKeyFile must be set";
      }
      {
        assertion = cfg.defaultSopsFile != null;
        message = "universe.security.sops.defaultSopsFile must be set and not empty";
      }
      {
        assertion = builtins.pathExists cfg.defaultSopsFile;
        message = "universe.security.sops.defaultSopsFile path does not exist: ${toString cfg.defaultSopsFile}";
      }
      {
        assertion = cfg.secrets != {};
        message = "universe.security.sops.secrets must be set";
      }
      {
        assertion = cfg.ageKeyFile == null || (builtins.pathExists cfg.ageKeyFile);
        message = "universe.security.sops.ageKeyFile path does not exist: ${toString cfg.ageKeyFile}";
      }
    ];
    sops = {
      defaultSopsFile = cfg.defaultSopsFile;
      age.sshKeyPaths = mkIf (cfg.ageSshKeyPaths != []) cfg.ageSshKeyPaths;
      age.keyFile = mkIf (cfg.ageKeyFile != null) cfg.ageKeyFile;
      validateSopsFiles = mkIf cfg.validate true;
      templates = mkIf (cfg.templates != {}) cfg.templates;

      # Combine all secret types
      secrets =
        cfg.secrets
        // cfg.serviceSecrets
        // cfg.sharedSecrets
        // (
          # Flatten user secrets: users/alice/token -> users/alice/token
          lib.foldl' (
            acc: user:
              acc
              // (lib.mapAttrs' (
                  name: value:
                    lib.nameValuePair "users/${user}/${name}" (value // {owner = user;})
                )
                cfg.userSecrets.${user} or {})
          ) {} (builtins.attrNames cfg.userSecrets)
        );
    };
  };
}
