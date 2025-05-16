{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Database clients and tools
    postgresql
    beekeeper-studio
    redli
    sqlx-cli
    # surrealdb
    # surrealdb-migrations
    # surrealist
  ];
}