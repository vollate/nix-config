{ username, ... }:

{
  users.users.${username}.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG0+ARV51tOmWpQ9ZFCelPPV4nx7Sbf8e9EQra1gbZDx lambillda@TBLD24"
  ];
}
