#!/usr/bin/env bash
set -eo pipefail

OS="$(uname -s)"

#Set branch to master unless specified by the user
declare -x QV_BRANCH="${QV_BRANCH:-"main"}"
declare -xr QV_REMOTE="${QV_REMOTE:-quantumfate/qvim.git}"
declare -xr INSTALL_PREFIX="${INSTALL_PREFIX:-"$HOME/.local"}"

declare -xir QV_FIRST_TIME_SETUP=1

declare -xr XDG_DATA_HOME="${XDG_DATA_HOME:-"$HOME/.local/share"}"
declare -xr XDG_CACHE_HOME="${XDG_CACHE_HOME:-"$HOME/.cache"}"
declare -xr XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-"$HOME/.config"}"

declare -xr QUANTUMVIM_CACHE_DIR="${QUANTUMVIM_CACHE_DIR:-"$XDG_CACHE_HOME/qvim"}"
declare -xr QUANTUMVIM_DIR="${QUANTUMVIM_DIR:-"$XDG_CONFIG_HOME/qvim"}"
declare -xr QUANTUMVIM_LOG_LEVEL="${QUANTUMVIM_LOG_LEVEL:-warn}"

declare BASEDIR
BASEDIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
BASEDIR="$(dirname -- "$(dirname -- "$BASEDIR")")"
readonly BASEDIR

declare ARGS_OVERWRITE=0
declare ARGS_INSTALL_DEPENDENCIES=1
declare INTERACTIVE_MODE=1
declare ADDITIONAL_WARNINGS=""
declare USE_SSH=0

declare -a __qvim_dirs=(
    "$QUANTUMVIM_CACHE_DIR"
    "$QUANTUMVIM_DIR"
)

declare -a __npm_deps=(
  "neovim"
)
# treesitter installed with brew causes conflicts #3738
if ! command -v tree-sitter &>/dev/null; then
  __npm_deps+=("tree-sitter-cli")
fi

declare -a __pip_deps=(
  "pynvim"
)

declare -a __rust_deps=(
  "fd::fd-find"
  "rg::ripgrep"
)

function usage() {
    echo "Usage: install.sh [<options>]"
    echo ""
    echo "Options:"
    echo "    -h, --help                               Print this help message"
    echo "    --ssh                                    Use git clone with ssh"
    echo "    -y, --yes                                Disable confirmation prompts (answer yes to all questions)"
    echo "    --overwrite                              Overwrite previous QuantumVim configuration (a backup is always performed first)"
    echo "    --[no-]install-dependencies              Whether to automatically install external dependencies (will prompt by default)"
}

function parse_arguments() {
    while [ "$#" -gt 0 ]; do
        case "$1" in
            --overwrite)
                ARGS_OVERWRITE=1
                ;;
            --ssh)
                USE_SSH=1
                ;;
            -y | --yes)
              INTERACTIVE_MODE=0
              ;;
            --install-dependencies)
              ARGS_INSTALL_DEPENDENCIES=1
              ;;
            --no-install-dependencies)
              ARGS_INSTALL_DEPENDENCIES=0
                 ;;
            -h | --help)
                usage
                exit 0
                ;;
        esac
        shift
    done
}

function print_missing_dep_msg() {
    if [ "$#" -eq 1 ]; then
        echo "[ERROR]: Unable to find dependency [$1]"
        echo "Please install it first and re-run the installer. Try: $RECOMMEND_INSTALL $1"
    else
        local cmds
        cmds=$(for i in "$@"; do echo "$RECOMMEND_INSTALL $i"; done)
        printf "[ERROR]: Unable to find dependencies [%s]" "$@"
        printf "Please install any one of the dependencies and re-run the installer. Try: \n%s\n" "$cmds"
    fi
}

function msg() {
    local text="$1"
    local div_width="80"
    printf "%${div_width}s\n" ' ' | tr ' ' -
    printf "%s\n" "$text"
}

function confirm() {
 local question="$1"
 while true; do
   msg "$question"
   read -p "[y]es or [n]o (default: no) : " -r answer
   case "$answer" in
     y | Y | yes | YES | Yes)
       return 0
       ;;
     n | N | no | NO | No | *[[:blank:]]* | "")
       return 1
       ;;
     *)
       msg "Please answer [y]es or [n]o."
       ;;
   esac
 done
}

function stringify_array() {
    echo -n "${@}" | sed 's/ /, /'
}

function detect_platform() {
 case "$OS" in
   Linux)
     if [ -f "/etc/arch-release" ] || [ -f "/etc/artix-release" ]; then
       RECOMMEND_INSTALL="sudo pacman -S"
     elif [ -f "/etc/fedora-release" ] || [ -f "/etc/redhat-release" ]; then
       RECOMMEND_INSTALL="sudo dnf install -y"
     elif [ -f "/etc/gentoo-release" ]; then
       RECOMMEND_INSTALL="emerge -tv"
     else # assume debian based
       RECOMMEND_INSTALL="sudo apt install -y"
     fi
     ;;
   FreeBSD)
     RECOMMEND_INSTALL="sudo pkg install -y"
     ;;
   NetBSD)
     RECOMMEND_INSTALL="sudo pkgin install"
     ;;
   OpenBSD)
     RECOMMEND_INSTALL="doas pkg_add"
     ;;
   Darwin)
     RECOMMEND_INSTALL="brew install"
     ;;
   *)
     echo "OS $OS is not currently supported."
     exit 1
     ;;
 esac
}

function check_neovim_min_version() {
    local verify_version_cmd='if !has("nvim-0.8") | cquit | else | quit | endif'

    # exit with an error if min_version not found
    if ! nvim --headless -u NONE -c "$verify_version_cmd"; then
        echo "[ERROR]: QuantumVim requires at least Neovim v0.8 or higher"
        exit 1
    fi
}

function validate_install_prefix() {
    local prefix="$1"
    case $PATH in
        *"$prefix/bin"*)
            return
            ;;
    esac
    local profile="$HOME/.profile"
    test -z "$ZSH_VERSION" && profile="$HOME/.zshenv"
    ADDITIONAL_WARNINGS="[WARN] the folder $prefix/bin is not on PATH, consider adding 'export PATH=$prefix/bin:\$PATH' to your $profile"

    # avoid problems when calling any verify_* function
    export PATH="$prefix/bin:$PATH"
}

function __install_nodejs_deps_pnpm() {
  echo "Installing node modules with pnpm.."
  pnpm install -g "${__npm_deps[@]}"
  echo "All NodeJS dependencies are successfully installed"
}

function __install_nodejs_deps_npm() {
  echo "Installing node modules with npm.."
  for dep in "${__npm_deps[@]}"; do
    if ! npm ls -g "$dep" &>/dev/null; then
      printf "installing %s .." "$dep"
      npm install -g "$dep"
    fi
  done

  echo "All NodeJS dependencies are successfully installed"
}

function __install_nodejs_deps_yarn() {
  echo "Installing node modules with yarn.."
  yarn global add "${__npm_deps[@]}"
  echo "All NodeJS dependencies are successfully installed"
}

function __validate_node_installation() {
  local pkg_manager="$1"
  local manager_home

  if ! command -v "$pkg_manager" &>/dev/null; then
    return 1
  fi

  if [ "$pkg_manager" == "npm" ]; then
    manager_home="$(npm config get prefix 2>/dev/null)"
  elif [ "$pkg_manager" == "pnpm" ]; then
    manager_home="$(pnpm config get prefix 2>/dev/null)"
  else
    manager_home="$(yarn global bin 2>/dev/null)"
  fi

  if [ ! -d "$manager_home" ] || [ ! -w "$manager_home" ]; then
    return 1
  fi

  return 0
}

function install_nodejs_deps() {
  local -a pkg_managers=("pnpm" "yarn" "npm")
  for pkg_manager in "${pkg_managers[@]}"; do
    if __validate_node_installation "$pkg_manager"; then
      eval "__install_nodejs_deps_$pkg_manager"
      return
    fi
  done
  echo "[WARN]: skipping installing optional nodejs dependencies due to insufficient permissions."
  echo "check how to solve it: https://docs.npmjs.com/resolving-eacces-permissions-errors-when-installing-packages-globally"
}

function install_python_deps() {
  echo "Verifying that pip is available.."
  if ! python3 -m ensurepip >/dev/null; then
    if ! python3 -m pip --version &>/dev/null; then
      echo "[WARN]: skipping installing optional python dependencies"
      return 1
    fi
  fi
  echo "Installing with pip.."
  for dep in "${__pip_deps[@]}"; do
    python3 -m pip install --user "$dep" || return 1
  done
  echo "All Python dependencies are successfully installed"
}

function __attempt_to_install_with_cargo() {
  if command -v cargo &>/dev/null; then
    echo "Installing missing Rust dependency with cargo"
    cargo install "$1"
  else
    echo "[WARN]: Unable to find cargo. Make sure to install it to avoid any problems"
    exit 1
  fi
}

# we try to install the missing one with cargo even though it's unlikely to be found
function install_rust_deps() {
  for dep in "${__rust_deps[@]}"; do
    if ! command -v "${dep%%::*}" &>/dev/null; then
      __attempt_to_install_with_cargo "${dep##*::}"
    fi
  done
  echo "All Rust dependencies are successfully installed"
}

function check_system_deps() {

    validate_install_prefix "$INSTALL_PREFIX"

    if ! command -v git &>/dev/null; then
        print_missing_dep_msg "git"
        exit 1
    fi
    if ! command -v nvim &>/dev/null; then
        print_missing_dep_msg "neovim"
        exit 1
    fi
    check_neovim_min_version
}

function __backup_dir() {
    local src="$1"
    if [ ! -d "$src" ]; then
        return
    fi
    mkdir -p "$src.old"
    msg "Backing up old $src to $src.old"
    if command -v rsync &>/dev/null; then
        rsync --archive --quiet --backup --partial --copy-links --cvs-exclude "$src"/ "$src.old"
    else
        case "$OS" in
            Darwin)
                cp -R "$src/." "$src.old/."
                ;;
            *)
                cp -r "$src/." "$src.old/."
                ;;
        esac
    fi
}

function verify_qvim_dirs() {
    for dir in "${__qvim_dirs[@]}"; do
        if [ -d "$dir" ]; then
            if [ "$ARGS_OVERWRITE" -eq 0 ]; then
                __backup_dir "$dir"
            fi
            rm -rf "$dir"
        fi
        mkdir -p "$dir"
    done
}

function clone_qvim() {
    msg "Cloning QuantumVim configuration"

    if [ "$USE_SSH" -eq 0 ]; then

	    if ! git clone --branch "$QV_BRANCH" \
        "https://github.com/${QV_REMOTE}" "$QUANTUMVIM_DIR"; then
        echo "Failed to clone repository. Installation failed."
        exit 1
	    fi
	else
	    if ! git clone --branch "$QV_BRANCH" \
        "git@github.com:${QV_REMOTE}" "$QUANTUMVIM_DIR"; then
        echo "Failed to clone repository. Installation failed."
        exit 1
	    fi
    fi
}

function setup_exec() {
    make -C "$QUANTUMVIM_DIR" install-bin
}

function remove_old_cache_files() {
    local lazy_cache="$QUANTUMVIM_CACHE_DIR/lazy/cache"
    if [ -e "$lazy_cache" ]; then
        msg "Removing old lazy cache file"
        rm -f "$lazy_cache"
    fi
}

function setup_qvim() {

    msg "Installing QuantumVim executable"

    setup_exec

    create_desktop_file

    echo "Preparing Lazy setup"

    "$INSTALL_PREFIX/bin/qvim" --headless -c 'quitall'

    echo "Lazy setup complete"

}

function create_desktop_file() {
    ([ "$OS" != "Linux" ] || ! command -v xdg-desktop-menu &>/dev/null) && return
    echo "Creating desktop file"

    for d in "$QUANTUMVIM_DIR"/utils/desktop/*/; do
        size_folder=$(basename "$d")
        mkdir -p "$XDG_DATA_HOME/icons/hicolor/$size_folder/apps/"
        cp "$QUANTUMVIM_DIR/utils/desktop/$size_folder/qvim.svg" "$XDG_DATA_HOME/icons/hicolor/$size_folder/apps"
    done

    xdg-desktop-menu install --novendor "$QUANTUMVIM_DIR/utils/desktop/qvim.desktop" || true
}

function print_logo() {
    cat <<'EOF'
     QQQQQQ\                                 QQ\                            QQ\    QQ\ QQ\
    QQ  __QQ\                                QQ |                           QQ |   QQ |\__|
    QQ /  QQ |QQ\   QQ\  QQQQQQ\  QQQQQQQ\ QQQQQQ\   QQ\   QQ\ QQQQQQ\QQQQ\ QQ |   QQ |QQ\ QQQQQQ\QQQQ\
    QQ |  QQ |QQ |  QQ | \____QQ\ QQ  __QQ\\_QQ  _|  QQ |  QQ |QQ  _QQ  _QQ\\QQ\  QQ  |QQ |QQ  _QQ  _QQ\
    QQ |  QQ |QQ |  QQ | QQQQQQQ |QQ |  QQ | QQ |    QQ |  QQ |QQ / QQ / QQ |\QQ\QQ  / QQ |QQ / QQ / QQ |
    QQ QQ\QQ |QQ |  QQ |QQ  __QQ |QQ |  QQ | QQ |QQ\ QQ |  QQ |QQ | QQ | QQ | \QQQ  /  QQ |QQ | QQ | QQ |
    \QQQQQQ / \QQQQQQ  |\QQQQQQQ |QQ |  QQ | \QQQQ  |\QQQQQQ  |QQ | QQ | QQ |  \Q  /   QQ |QQ | QQ | QQ |
     \___QQQ\  \______/  \_______|\__|  \__|  \____/  \______/ \__| \__| \__|   \_/    \__|\__| \__| \__|
         \___|
EOF
}

function main() {
    parse_arguments "$@"

    print_logo

    msg "Detecting platform for managing any additional neovim dependencies"
    detect_platform

    check_system_deps

  if [ "$ARGS_INSTALL_DEPENDENCIES" -eq 1 ]; then
    if [ "$INTERACTIVE_MODE" -eq 1 ]; then
      if confirm "Would you like to install QuantumVim's NodeJS dependencies: $(stringify_array "${__npm_deps[@]}")?"; then
        install_nodejs_deps
      fi
      if confirm "Would you like to install QuantumVim's Python dependencies: $(stringify_array "${__pip_deps[@]}")?"; then
        install_python_deps
      fi
      if confirm "Would you like to install QuantumVim's Rust dependencies: $(stringify_array "${__rust_deps[@]}")?"; then
        install_rust_deps
      fi
    else
      install_nodejs_deps
      install_python_deps
      install_rust_deps
    fi
  fi

    remove_old_cache_files

    verify_qvim_dirs

    clone_qvim

    setup_qvim

    msg "$ADDITIONAL_WARNINGS"
    msg "Thank you for installing QuantumVim!!"
    echo "You can start it by running: $INSTALL_PREFIX/bin/qvim"
    echo "Do not forget to use a font with glyphs (icons) support [https://github.com/ryanoasis/nerd-fonts]"
}

main "$@"
