{
  pkgs,
  lib,
  config,
  ...
}: {
  options = with lib; {
    services.trash.enable = mkEnableOption "trash auto clean service";
  };

  config = lib.mkIf config.services.trash.enable {
    systemd.user = {
      services.purge-old-trash = {
        Unit.Description = "Delete trashed files older than 30 days";

        Service = {
          Type = "oneshot";
          ExecStart =
            lib.getExe
            <| pkgs.writeShellScriptBin "clean-trash"
            # bash
            ''
              TRASH_INFO_DIR="$HOME/.local/share/Trash/info"
              TRASH_FILES_DIR="$HOME/.local/share/Trash/files"

              now=$(date +%s)

              find "$TRASH_INFO_DIR" -type f -name '*.trashinfo' | while read -r info_file; do
                  deletion_date=$(grep '^DeletionDate=' "$info_file" | cut -d'=' -f2)
                  deletion_epoch=$(date -d "$deletion_date" +%s 2>/dev/null)

                  if [[ -n "$deletion_epoch" && $((now - deletion_epoch)) -ge 2592000 ]]; then
                      base_name=$(basename "$info_file" .trashinfo)

                      file_path="$TRASH_FILES_DIR/$base_name"

                      echo "Deleting trashed file: $file_path (trashed on $deletion_date)"
                      rm -rf "$file_path"
                      rm -f "$info_file"
                  fi
              done
            '';
        };
      };

      timers.purge-old-trash = {
        Unit.Description = "Run daily to clean up old trash";

        Timer = {
          OnCalendar = "daily";
          Persistent = true;
        };

        Install.WantedBy = ["timers.target"];
      };
    };
  };
}
