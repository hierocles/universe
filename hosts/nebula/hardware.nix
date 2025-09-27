{ delib, ... }:
delib.host {
  name = "nebula";

  system = "aarch64-darwin";

  home.home.stateVersion = "24.05"; 

  darwin = {
    system.stateVersion = 6; 
  };
}
