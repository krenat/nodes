### install 
mkdir -p "$HOME/dria" && wget --no-cache -q -O "$HOME/dria/dria_setup_docker.sh" "https://raw.githubusercontent.com/krenat/nodes/refs/heads/main/dria/dria_setup_docker.sh" && sudo chmod +x "$HOME/dria/dria_setup_docker.sh" && "$HOME/dria/dria_setup_docker.sh"

### install DRIA only one script 
mkdir -p "$HOME/p_dria" && wget --no-cache -q -O "$HOME/p_dria/dria.sh" "https://raw.githubusercontent.com/krenat/nodes/refs/heads/main/dria/dria.sh" && sudo chmod +x "$HOME/p_dria/dria.sh" && "$HOME/p_dria/dria.sh"