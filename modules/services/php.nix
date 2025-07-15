{ config, pkgs, lib, inputs,  ...}:

{
  config = {
  environment.systemPackages = with pkgs; [
    php84
    php84Packages.composer
    php84Packages.composer-local-repo-plugin
    php84Packages.phpunit
    php84Packages.php-cs-fixer
    php84Packages.phpstan
    php84Packages.php-cs-fixer-composer-installer
    php84Packages.php-cs-fixer-fixer
  ];
};
}