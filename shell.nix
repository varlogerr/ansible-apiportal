let
  pkgs = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/1a56d76d718afb6c47dd96602c915b6d23f7c45d.tar.gz") {};

  hook = ''
    export CONFDIR=./conf
    export REQDIR=./requirements
    export PS1="[\[\033[1;32m\]nix-shell@\h \w\[\033[0m\]] "
    export PATH="$PATH:./bin"

    if [[ -f ./requirements.yml ]]; then
      ansible-galaxy collection install -r ./requirements.yml \
        -p "$REQDIR" > /dev/null
    fi
  '';

  pythonEnv = pkgs.python39.withPackages (pypkgs: with pypkgs; [
    pyyaml
  ]);
in pkgs.mkShell {
  buildInputs = with pkgs; [
    ansible
    git
    openssh
    pythonEnv
    sshpass
    which
  ];

  shellHook = hook;
}
