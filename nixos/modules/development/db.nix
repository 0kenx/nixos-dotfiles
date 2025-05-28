{ pkgs, pkgs-unstable, ... }:

{
  environment.systemPackages = with pkgs; [
    # Database clients and tools
    postgresql
    redli
    sqlx-cli
    # surrealdb
    # surrealdb-migrations
    # surrealist
  ] ++ [
    # Packages from unstable channel
      # pkgs-unstable.beekeeper-studio
  ];
}
