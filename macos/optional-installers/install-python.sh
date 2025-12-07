#!/usr/bin/env bash
set -e
source ../scripts/helpers.sh

print_header "Installing Python Development Environment for macOS"

# Install pyenv via Homebrew
print_header "Installing pyenv"
brew_install pyenv
brew_install pyenv-virtualenv

# Add pyenv to shell profiles
for profile in ~/.bashrc ~/.bash_profile ~/.zshrc; do
    if [ -f "$profile" ]; then
        if ! grep -q 'pyenv init' "$profile"; then
            echo '' >> "$profile"
            echo '# pyenv configuration' >> "$profile"
            echo 'export PYENV_ROOT="$HOME/.pyenv"' >> "$profile"
            echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> "$profile"
            echo 'eval "$(pyenv init -)"' >> "$profile"
            echo 'eval "$(pyenv virtualenv-init -)"' >> "$profile"
        fi
    fi
done

# Source pyenv for current session
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# Install Python build dependencies
print_header "Installing Python Build Dependencies"
brew_install openssl
brew_install readline
brew_install sqlite3
brew_install xz
brew_install zlib
brew_install tcl-tk

# Set environment variables for Python compilation
export LDFLAGS="-L$(brew --prefix openssl)/lib -L$(brew --prefix readline)/lib -L$(brew --prefix sqlite)/lib -L$(brew --prefix zlib)/lib"
export CPPFLAGS="-I$(brew --prefix openssl)/include -I$(brew --prefix readline)/include -I$(brew --prefix sqlite)/include -I$(brew --prefix zlib)/include"
export PKG_CONFIG_PATH="$(brew --prefix openssl)/lib/pkgconfig:$(brew --prefix readline)/lib/pkgconfig:$(brew --prefix sqlite)/lib/pkgconfig:$(brew --prefix zlib)/lib/pkgconfig"

# Install latest Python versions
print_header "Installing Python Versions"
PYTHON_LATEST=$(pyenv install --list | grep -E '^  [0-9]+\.[0-9]+\.[0-9]+$' | tail -1 | tr -d ' ')
PYTHON_311=$(pyenv install --list | grep -E '^  3\.11\.[0-9]+$' | tail -1 | tr -d ' ')
PYTHON_310=$(pyenv install --list | grep -E '^  3\.10\.[0-9]+$' | tail -1 | tr -d ' ')

print_info "Installing Python $PYTHON_LATEST (latest)"
CFLAGS="-I$(brew --prefix openssl)/include -I$(brew --prefix sqlite)/include" \
LDFLAGS="-L$(brew --prefix openssl)/lib -L$(brew --prefix sqlite)/lib" \
pyenv install "$PYTHON_LATEST"

print_info "Installing Python $PYTHON_311 (3.11 LTS)"
CFLAGS="-I$(brew --prefix openssl)/include -I$(brew --prefix sqlite)/include" \
LDFLAGS="-L$(brew --prefix openssl)/lib -L$(brew --prefix sqlite)/lib" \
pyenv install "$PYTHON_311"

pyenv global "$PYTHON_LATEST"

# Install pip and essential packages
print_header "Installing Essential Python Packages"
pip install --upgrade pip setuptools wheel
pip install \
    virtualenv \
    pipenv \
    poetry \
    pipx \
    black \
    flake8 \
    mypy \
    pytest \
    pytest-cov \
    jupyter \
    ipython \
    requests \
    flask \
    django \
    fastapi \
    pandas \
    numpy \
    matplotlib \
    seaborn \
    scikit-learn

# Install pipx for isolated package installations
print_header "Setting up pipx"
pipx ensurepath

# Install useful Python tools via pipx
print_header "Installing Python Development Tools"
pipx install cookiecutter
pipx install httpie
pipx install youtube-dl
pipx install streamlit
pipx install pre-commit

print_success "Python Development Environment Installed!"
echo ""
echo "🐍 Python versions available:"
pyenv versions
echo ""
echo "🛠️ Package managers installed:"
echo "• pip $(pip --version | cut -d' ' -f2)"
echo "• pipenv $(pipenv --version 2>/dev/null | cut -d' ' -f3 || echo 'not found')"
echo "• poetry $(poetry --version 2>/dev/null | cut -d' ' -f3 || echo 'not found')"
echo "• pipx $(pipx --version 2>/dev/null || echo 'not found')"
echo ""
echo "💡 Usage:"
echo "• Switch Python version: 'pyenv global 3.x.x'"
echo "• Create virtual env: 'python -m venv myproject'"
echo "• Use Poetry: 'poetry init' and 'poetry install'"
echo "• Use pipx: 'pipx install <package>' for CLI tools"
echo "• Jupyter notebook: 'jupyter notebook'"