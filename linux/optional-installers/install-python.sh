#!/usr/bin/env bash
set -e
source ../scripts/helpers.sh

print_header "Installing Python Development Environment"

# Install Python via pyenv
if ! command -v pyenv &> /dev/null; then
    print_header "Installing pyenv"
    curl https://pyenv.run | bash
    
    # Add pyenv to shell profiles
    for profile in ~/.bashrc ~/.zshrc; do
        if [ -f "$profile" ]; then
            echo '' >> "$profile"
            echo '# pyenv configuration' >> "$profile"
            echo 'export PYENV_ROOT="$HOME/.pyenv"' >> "$profile"
            echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> "$profile"
            echo 'eval "$(pyenv init -)"' >> "$profile"
        fi
    done
    
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
else
    print_warning "pyenv already installed"
fi

# Install Python build dependencies
print_header "Installing Python Build Dependencies"
sudo apt-get install -y make build-essential libssl-dev zlib1g-dev \
    libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
    libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

# Install latest Python versions
print_header "Installing Python Versions"
PYTHON_LATEST=$(pyenv install --list | grep -E '^  [0-9]+\.[0-9]+\.[0-9]+$' | tail -1 | tr -d ' ')
PYTHON_311=$(pyenv install --list | grep -E '^  3\.11\.[0-9]+$' | tail -1 | tr -d ' ')

pyenv install "$PYTHON_LATEST"
pyenv install "$PYTHON_311"
pyenv global "$PYTHON_LATEST"

# Install pip and essential packages
print_header "Installing Essential Python Packages"
pip install --upgrade pip
pip install \
    virtualenv \
    pipenv \
    poetry \
    black \
    flake8 \
    mypy \
    pytest \
    jupyter \
    ipython \
    requests \
    flask \
    django \
    fastapi \
    pandas \
    numpy \
    matplotlib \
    seaborn

print_success "Python Development Environment Installed!"
echo ""
echo "🐍 Python versions available:"
pyenv versions
echo ""
echo "💡 Usage:"
echo "• Switch Python version: 'pyenv global 3.x.x'"
echo "• List available versions: 'pyenv install --list'"
echo "• Create virtual env: 'python -m venv myproject'"
echo "• Use Poetry: 'poetry init' and 'poetry install'"