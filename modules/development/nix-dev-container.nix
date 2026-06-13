{ pkgs, ... }:

let
  baseImageRef = "localhost/nix-dev-container-base:latest";

  imagePackages = with pkgs; [
    bashInteractive
    cacert
    codex
    coreutils
    findutils
    gawk
    gitMinimal
    gnugrep
    gnused
    gnutar
    gzip
    nix
    openssh
    shadow
    sudo
    util-linux
    which
    xz
    zstd
  ];

  imagePath = pkgs.lib.makeBinPath imagePackages;

  image = pkgs.dockerTools.buildLayeredImage {
    name = "localhost/nix-dev-container-base";
    tag = "latest";

    contents = imagePackages;

    extraCommands = ''
      mkdir -m 1777 tmp
      mkdir -p etc
      cat > etc/nsswitch.conf <<'EOF'
      passwd: files
      group: files
      shadow: files
      hosts: files dns
      EOF
    '';

    fakeRootCommands = ''
      chmod 1777 ./tmp
      if [ -e .${pkgs.sudo}/bin/sudo ]; then
        chmod 4755 .${pkgs.sudo}/bin/sudo
      fi
    '';

    config = {
      Env = [
        "PATH=${imagePath}"
        "NIX_CONFIG=experimental-features = nix-command flakes"
        "NIX_REMOTE=daemon"
        "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
      ];
      Cmd = [ "${pkgs.bashInteractive}/bin/bash" ];
    };
  };

  entrypoint = pkgs.writeShellScript "nix-dev-container-entrypoint" ''
    set -euo pipefail

    export PATH="${imagePath}:$PATH"

    user="''${NIX_DEV_CONTAINER_USER:?}"
    uid="''${NIX_DEV_CONTAINER_UID:?}"
    gid="''${NIX_DEV_CONTAINER_GID:?}"
    home="''${NIX_DEV_CONTAINER_HOME:?}"
    workspace="''${NIX_DEV_CONTAINER_WORKSPACE:?}"
    env_file="''${NIX_DEV_CONTAINER_ENV_FILE:-}"

    mkdir -p /tmp "$home" "$home/.cache/nix"
    chmod 1777 /tmp 2>/dev/null || true
    chown "$uid:$gid" "$home" "$home/.cache" "$home/.cache/nix" 2>/dev/null || true
    cd "$workspace"

    export HOME="$home"
    export USER="$user"
    export LOGNAME="$user"
    export NIX_CONFIG="experimental-features = nix-command flakes"
    export NIX_REMOTE="daemon"
    export SSL_CERT_FILE="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"

    rcfile="/tmp/nix-dev-container-bashrc"
    cat > "$rcfile" <<EOF
    export PATH="${pkgs.codex}/bin:\$PATH"
    export NIX_REMOTE=daemon
    export NIX_CONFIG="experimental-features = nix-command flakes"
    export SSL_CERT_FILE="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
    [[ -f "$home/.bashrc" ]] && source "$home/.bashrc"
    EOF
    chown "$uid:$gid" "$rcfile" 2>/dev/null || true

    run_as_user() {
      exec setpriv \
        --reuid "$uid" \
        --regid "$gid" \
        --clear-groups \
        env \
        HOME="$home" \
        USER="$user" \
        LOGNAME="$user" \
        PATH="${pkgs.codex}/bin:$PATH" \
        NIX_REMOTE=daemon \
        NIX_CONFIG="experimental-features = nix-command flakes" \
        SSL_CERT_FILE="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt" \
        "$@"
    }

    if [[ $# -gt 0 ]]; then
      if [[ "$env_file" == "shell.nix" || ( -z "$env_file" && ! -f flake.nix && -f shell.nix ) ]]; then
        run_as_user nix-shell shell.nix --run "export PATH='${pkgs.codex}/bin':\$PATH; $(printf '%q ' "$@")"
      fi
      run_as_user nix --accept-flake-config develop "$workspace" -c "$@"
    fi

    if [[ "$env_file" == "flake.nix" || ( -z "$env_file" && -f flake.nix ) ]]; then
      run_as_user nix --accept-flake-config develop "$workspace" -c bash --init-file "$rcfile" -i
    fi

    if [[ "$env_file" == "shell.nix" || ( -z "$env_file" && -f shell.nix ) ]]; then
      run_as_user nix-shell shell.nix --run "bash --init-file '$rcfile' -i"
    fi

    run_as_user bash --init-file "$rcfile" -i
  '';

  nixDevContainer = pkgs.writeShellApplication {
    name = "nix-dev-container";
    runtimeInputs = with pkgs; [
      coreutils
      gnugrep
      gnused
      podman
    ];

    text = ''
      usage() {
        cat <<'EOF'
      Usage:
        nix-dev-container [PROJECT_DIR|flake.nix|shell.nix] [-- COMMAND...]
        nix-dev-container create [PROJECT_DIR|flake.nix|shell.nix]
        nix-dev-container rebuild [PROJECT_DIR|flake.nix|shell.nix]
        nix-dev-container start [--persist] [--force-run] [PROJECT_DIR|flake.nix|shell.nix] [-- COMMAND...]
        nix-dev-container clean [PROJECT_DIR|flake.nix|shell.nix]
        nix-dev-container destroy [PROJECT_DIR|flake.nix|shell.nix]

      Commands:
        create    Load and tag the current project's image if it does not exist.
        rebuild   Re-load and re-tag the current project's image.
        start     Start the current project container. This is the default command.
        clean     Remove the current project's persistent container.
        destroy   Remove the current project's image.

      Options:
        --persist                 Reuse a stable container instead of --rm.
        --force-run               Replace an existing persistent container after confirmation.
        --env-proxy               Pass common proxy environment variables from the host.
        --env=NAME[,NAME...]      Pass specific host environment variables by name.
        --env-all                 Pass all host environment variables. May expose secrets.
        NIX_DEV_CONTAINER_RUNTIME_ARGS
                                  Extra podman run args split by the shell.
      EOF
      }

      confirm() {
        local prompt="$1"
        local reply
        printf '%s [y/N] ' "$prompt" >&2
        read -r reply || reply=""
        [[ "$reply" == "y" || "$reply" == "Y" || "$reply" == "yes" || "$reply" == "YES" ]]
      }

      safe_name() {
        printf '%s' "$1" | tr -c 'A-Za-z0-9_-' '_'
      }

      valid_env_name() {
        [[ "$1" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]
      }

      add_env_name() {
        local name="$1"
        if ! valid_env_name "$name"; then
          echo "nix-dev-container: invalid environment variable name: $name" >&2
          exit 1
        fi
        env_names+=("$name")
      }

      add_env_list() {
        local list="$1"
        local name

        IFS=',' read -ra names <<< "$list"
        for name in "''${names[@]}"; do
          if [[ -n "$name" ]]; then
            add_env_name "$name"
          fi
        done
      }

      add_proxy_env_names() {
        local name
        for name in \
          http_proxy https_proxy ftp_proxy all_proxy no_proxy \
          HTTP_PROXY HTTPS_PROXY FTP_PROXY ALL_PROXY NO_PROXY; do
          add_env_name "$name"
        done
      }

      build_env_args() {
        env_args=()

        if [[ "$env_all" == "1" ]]; then
          local env_name
          while IFS='=' read -r env_name _; do
            if [[ -n "$env_name" && "$env_name" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]; then
              env_names+=("$env_name")
            fi
          done < <(env)
        fi

        local name
        for name in "''${env_names[@]}"; do
          if valid_env_name "$name" && [[ -v "$name" ]]; then
            env_args+=(--env "$name=''${!name}")
          fi
        done
      }

      parse_project() {
        local target="''${1:-$PWD}"

        target="$(realpath "$target")"
        env_file=""

        if [[ -f "$target" ]]; then
          env_file="$(basename "$target")"
          workspace="$(dirname "$target")"
        else
          workspace="$target"
        fi

        if [[ ! -d "$workspace" ]]; then
          echo "nix-dev-container: project path does not exist: $workspace" >&2
          exit 1
        fi

        if [[ -n "$env_file" && "$env_file" != "flake.nix" && "$env_file" != "shell.nix" ]]; then
          echo "nix-dev-container: expected flake.nix or shell.nix, got: $env_file" >&2
          exit 1
        fi

        if [[ -z "$env_file" ]]; then
          if [[ -f "$workspace/flake.nix" ]]; then
            env_file="flake.nix"
          elif [[ -f "$workspace/shell.nix" ]]; then
            env_file="shell.nix"
          fi
        fi

        if [[ -z "$env_file" ]]; then
          echo "nix-dev-container: warning: no flake.nix or shell.nix in $workspace" >&2
        fi

        project_hash="$(printf '%s' "$workspace" | sha256sum | cut -c1-16)"
        image_ref="localhost/nix-dev-container/$project_hash:latest"
        container_name="nix-dev-container-$project_hash"
      }

      load_base_image() {
        local force="''${1:-0}"

        if [[ "$force" == "1" ]]; then
          podman image exists "${baseImageRef}" && podman rmi -f "${baseImageRef}" >/dev/null
        fi

        if ! podman image exists "${baseImageRef}"; then
          echo "nix-dev-container: loading ${baseImageRef} into podman" >&2
          podman load -i ${image} >/dev/null
        fi
      }

      create_image() {
        local force="''${1:-0}"

        if [[ "$force" == "1" ]]; then
          podman image exists "$image_ref" && podman rmi -f "$image_ref" >/dev/null
        elif podman image exists "$image_ref"; then
          echo "nix-dev-container: image already exists: $image_ref" >&2
          return 0
        fi

        load_base_image "$force"
        podman tag "${baseImageRef}" "$image_ref"
        echo "nix-dev-container: image ready: $image_ref" >&2
      }

      persistent_container_exists() {
        podman container exists "$container_name"
      }

      make_runtime_etc() {
        runtime_dir_is_temp=0
        if [[ "$persist" == "1" ]]; then
          runtime_dir="''${XDG_STATE_HOME:-$HOME/.local/state}/nix-dev-container/$project_hash"
          mkdir -p "$runtime_dir"
        else
          runtime_dir="$(mktemp -d -t nix-dev-container.XXXXXX)"
          runtime_dir_is_temp=1
        fi

        local user_name group_name uid gid home_dir sudo_path

        user_name="$(safe_name "$(id -un)")"
        group_name="$(safe_name "$(id -gn)")"
        uid="$(id -u)"
        gid="$(id -g)"
        home_dir="$HOME"
        sudo_path="${
          pkgs.lib.makeBinPath [
            pkgs.sudo
            pkgs.coreutils
            pkgs.findutils
            pkgs.gnugrep
            pkgs.gnused
            pkgs.util-linux
          ]
        }"

        cat > "$runtime_dir/passwd" <<EOF
      root:x:0:0:root:/root:/bin/bash
      $user_name:x:$uid:$gid:$user_name:$home_dir:/bin/bash
      EOF

        cat > "$runtime_dir/group" <<EOF
      root:x:0:
      wheel:x:10:$user_name
      $group_name:x:$gid:$user_name
      EOF

        cat > "$runtime_dir/sudoers" <<EOF
      Defaults env_keep += "HOME USER LOGNAME PATH NIX_CONFIG NIX_REMOTE SSL_CERT_FILE"
      Defaults secure_path="$sudo_path:${imagePath}"
      root ALL=(ALL:ALL) ALL
      %wheel ALL=(ALL:ALL) NOPASSWD: ALL
      $user_name ALL=(ALL:ALL) NOPASSWD: ALL
      EOF
        chmod 0440 "$runtime_dir/sudoers"
      }

      cleanup_runtime_etc() {
        if [[ "''${runtime_dir_is_temp:-0}" == "1" && -n "''${runtime_dir:-}" && -d "$runtime_dir" ]]; then
          rm -rf "$runtime_dir"
        fi
      }

      run_new_container() {
        make_runtime_etc

        local rm_args=()
        local name_args=()
        if [[ "$persist" == "1" ]]; then
          name_args=(--name "$container_name")
        else
          rm_args=(--rm)
        fi

        local tty_args=(-i)
        if [[ -t 0 && -t 1 ]]; then
          tty_args=(-it)
        fi

        local runtime_args=()
        if [[ -n "''${NIX_DEV_CONTAINER_RUNTIME_ARGS:-}" ]]; then
          # shellcheck disable=SC2206
          runtime_args=(''${NIX_DEV_CONTAINER_RUNTIME_ARGS})
        fi

        local codex_args=()
        if [[ -d "$HOME/.codex" ]]; then
          codex_args+=(--volume "$HOME/.codex:$HOME/.codex:rw")
        fi

        local etc_nix_args=()
        if [[ -d /etc/nix ]]; then
          etc_nix_args+=(--volume /etc/nix:/etc/nix:ro)
        fi

        local nix_home_args=()
        mkdir -p "$HOME/.cache/nix"
        nix_home_args+=(--volume "$HOME/.cache/nix:$HOME/.cache/nix:rw")

        build_env_args

        set +e
        podman run \
          "''${rm_args[@]}" \
          "''${name_args[@]}" \
          "''${tty_args[@]}" \
          --network host \
          --userns "keep-id:uid=$(id -u),gid=$(id -g)" \
          --user 0:0 \
          --security-opt label=disable \
          --label "nix-dev-container.workspace=$workspace" \
          "''${runtime_args[@]}" \
          --volume "$workspace:$workspace:rw" \
          --volume /nix/store:/nix/store:ro \
          --volume /nix/var/nix/daemon-socket:/nix/var/nix/daemon-socket:rw \
          --volume "$runtime_dir/passwd:/etc/passwd:ro" \
          --volume "$runtime_dir/group:/etc/group:ro" \
          --volume "$runtime_dir/sudoers:/etc/sudoers:ro" \
          "''${etc_nix_args[@]}" \
          "''${codex_args[@]}" \
          "''${nix_home_args[@]}" \
          "''${env_args[@]}" \
          --workdir "$workspace" \
          --env "NIX_DEV_CONTAINER_USER=$(safe_name "$(id -un)")" \
          --env "NIX_DEV_CONTAINER_UID=$(id -u)" \
          --env "NIX_DEV_CONTAINER_GID=$(id -g)" \
          --env "NIX_DEV_CONTAINER_HOME=$HOME" \
          --env "NIX_DEV_CONTAINER_WORKSPACE=$workspace" \
          --env "NIX_DEV_CONTAINER_ENV_FILE=$env_file" \
          --env "NIX_CONFIG=experimental-features = nix-command flakes" \
          --env "NIX_REMOTE=daemon" \
          --env "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt" \
          "$image_ref" \
          ${entrypoint} \
          "''${container_command[@]}"
        local status=$?
        set -e

        cleanup_runtime_etc
        exit "$status"
      }

      start_container() {
        create_image 0

        if [[ "$force_run" == "1" && "$persist" != "1" ]]; then
          echo "nix-dev-container: --force-run requires --persist" >&2
          exit 1
        fi

        if [[ "$persist" == "1" && "$force_run" == "1" ]] && persistent_container_exists; then
          if confirm "Remove existing persistent container $container_name?"; then
            podman rm -f "$container_name" >/dev/null
          else
            echo "nix-dev-container: cancelled" >&2
            exit 1
          fi
        fi

        if [[ "$persist" == "1" ]] && persistent_container_exists; then
          if [[ "$env_all" == "1" || "''${#env_names[@]}" -gt 0 ]]; then
            echo "nix-dev-container: warning: existing persistent container keeps its original environment; use --force-run to recreate it" >&2
          fi

          if [[ "$(podman inspect -f '{{.State.Running}}' "$container_name")" == "true" ]]; then
            exec podman attach "$container_name"
          fi
          exec podman start -ai "$container_name"
        fi

        run_new_container
      }

      clean_container() {
        if ! podman container exists "$container_name"; then
          echo "nix-dev-container: no persistent container for $workspace" >&2
          return 0
        fi

        if confirm "Remove persistent container $container_name?"; then
          podman rm -f "$container_name" >/dev/null
          echo "nix-dev-container: removed $container_name" >&2
        else
          echo "nix-dev-container: cancelled" >&2
          exit 1
        fi
      }

      destroy_image() {
        if ! podman image exists "$image_ref"; then
          echo "nix-dev-container: no image for $workspace" >&2
          return 0
        fi

        if confirm "Remove image $image_ref?"; then
          podman rmi -f "$image_ref" >/dev/null
          echo "nix-dev-container: removed $image_ref" >&2
        else
          echo "nix-dev-container: cancelled" >&2
          exit 1
        fi
      }

      command_name="start"
      if [[ $# -gt 0 ]]; then
        case "$1" in
          create | rebuild | start | clean | destroy | destory)
            command_name="$1"
            shift
            ;;
          -h | --help)
            usage
            exit 0
            ;;
        esac
      fi

      persist=0
      force_run=0
      env_all=0
      env_names=()
      target=""
      container_command=()

      if [[ "$command_name" == "start" ]]; then
        while [[ $# -gt 0 ]]; do
          case "$1" in
            --persist)
              persist=1
              shift
              ;;
            --force-run)
              force_run=1
              shift
              ;;
            --env-proxy)
              add_proxy_env_names
              shift
              ;;
            --env-all)
              env_all=1
              shift
              ;;
            --env=*)
              add_env_list "''${1#--env=}"
              shift
              ;;
            -h | --help)
              usage
              exit 0
              ;;
            --)
              target="''${target:-$PWD}"
              shift
              container_command=("$@")
              break
              ;;
            -*)
              echo "nix-dev-container: unknown start option: $1" >&2
              exit 1
              ;;
            *)
              target="$1"
              shift
              if [[ "''${1:-}" == "--" ]]; then
                shift
                container_command=("$@")
              elif [[ $# -gt 0 ]]; then
                echo "nix-dev-container: command arguments must follow --" >&2
                exit 1
              fi
              break
              ;;
          esac
        done
      else
        if [[ "''${1:-}" == "-h" || "''${1:-}" == "--help" ]]; then
          usage
          exit 0
        fi

        target="''${1:-$PWD}"
        if [[ $# -gt 1 ]]; then
          echo "nix-dev-container: $command_name accepts at most one path argument" >&2
          exit 1
        fi
      fi

      parse_project "''${target:-$PWD}"

      case "$command_name" in
        create)
          create_image 0
          ;;
        rebuild)
          create_image 1
          ;;
        start)
          start_container
          ;;
        clean)
          clean_container
          ;;
        destroy | destory)
          destroy_image
          ;;
        *)
          echo "nix-dev-container: unknown command: $command_name" >&2
          usage >&2
          exit 1
          ;;
      esac
    '';
  };
in
{
  environment.systemPackages = [
    nixDevContainer
  ];
}
