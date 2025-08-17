{
  config,
  pkgs,
  ...
}: {
  hardware.cpu.intel.updateMicrocode = true;
  boot.kernelParams = ["i915.enable_guc=2"];
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      vaapiIntel
      intel-media-driver
      intel-media-sdk
    ];
  };
}
