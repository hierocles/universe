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
  cfg = config.${namespace}.security.gpg;
  gpgConf = "${inputs.gpg-base-conf}/gpg.conf";
  gpgAgentConf = ''
    enable-ssh-support
    default-cache-ttl 60
    max-cache-ttl 120
    pinentry-program ${pkgs.pinentry-curses}/bin/pinentry-curses
    allow-loopback-pinentry
  '';
in {
  options.${namespace}.security.gpg = with types; {
    enable = mkBoolOpt false "Whether or not to enable GPG.";
    agentTimeout = mkOpt int 5 "The amount of time to wait before continuing with shell init.";
    default-key = mkOpt str "26FD3C8C50BCB978" "The default GPG key ID to use for signing.";
  };

  config = mkIf cfg.enable {
    services.pcscd.enable = true;
    # NOTE: This should already have been added by programs.gpg, but
    # keeping it here for now just in case.
    environment.shellInit = ''
      export GPG_TTY="$(tty)"
      export SSH_AUTH_SOCK=$(${pkgs.gnupg}/bin/gpgconf --list-dirs agent-ssh-socket)

      ${pkgs.coreutils}/bin/timeout ${builtins.toString cfg.agentTimeout} ${pkgs.gnupg}/bin/gpgconf --launch gpg-agent
      gpg_agent_timeout_status=$?

      if [ "$gpg_agent_timeout_status" = 124 ]; then
        # Command timed out...
        echo "GPG Agent timed out..."
        echo 'Run "gpgconf --launch gpg-agent" to try and launch it again.'
      fi
    '';

    environment.systemPackages = with pkgs; [
      cryptsetup
      gnupg
      pinentry-curses
    ];

    programs = {
      ssh.startAgent = false;

      gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
        enableExtraSocket = true;
      };
    };

    universe = {
      home.file = {
        ".gnupg/.keep".text = "";

        ".gnupg/gpg.conf".text = ''
          ${builtins.readFile gpgConf}
          use-agent
          pinentry-mode loopback
        '';
        ".gnupg/gpg-agent.conf".text = gpgAgentConf;

        # Import the GPG public key
        ".gnupg/dylan-gpg-public.asc".text = ''
          -----BEGIN PGP PUBLIC KEY BLOCK-----

          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
          myGWDXj47Y86e0T6LjLFAfXDP84/tWbYMA==
          =EMmG
          -----END PGP PUBLIC KEY BLOCK-----
        '';
      };
    };

    # Import the GPG key on system activation
    system.activationScripts.importGpgKey = ''
      if [ -f /home/${config.${namespace}.user.name}/.gnupg/dylan-gpg-public.asc ]; then
        ${pkgs.sudo}/bin/sudo -u ${config.${namespace}.user.name} ${pkgs.gnupg}/bin/gpg --import /home/${config.${namespace}.user.name}/.gnupg/dylan-gpg-public.asc 2>/dev/null || true
      fi
    '';
  };
}
