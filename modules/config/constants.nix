{ delib, ... }:
delib.module {
  name = "constants";

  options.constants = with delib; {
    username = readOnly (strOption "dylan");
    userfullname = readOnly (strOption "Dylan Henrich");
    useremail = readOnly (strOption "4733259+hierocles@users.noreply.github.com");
  };
}
