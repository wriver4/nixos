{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ 
    lynis
    strace
  ];

}