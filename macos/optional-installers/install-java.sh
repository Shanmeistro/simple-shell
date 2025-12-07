#!/usr/bin/env bash
set -e
source ../scripts/helpers.sh

print_header "Installing Java Development Environment for macOS"

# Install SDKMAN! via Homebrew or direct installation
if [ ! -d "$HOME/.sdkman" ]; then
    print_header "Installing SDKMAN!"
    curl -s "https://get.sdkman.io" | bash
    source "$HOME/.sdkman/bin/sdkman-init.sh"
else
    print_warning "SDKMAN! already installed"
    source "$HOME/.sdkman/bin/sdkman-init.sh"
fi

# Add SDKMAN to shell profiles
for profile in ~/.bashrc ~/.bash_profile ~/.zshrc; do
    if [ -f "$profile" ]; then
        if ! grep -q 'sdkman-init.sh' "$profile"; then
            echo '' >> "$profile"
            echo '# SDKMAN!' >> "$profile"
            echo 'export SDKMAN_DIR="$HOME/.sdkman"' >> "$profile"
            echo '[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"' >> "$profile"
        fi
    fi
done

# Install Java versions (Temurin/Eclipse Adoptium)
print_header "Installing Java Versions"
sdk install java 21.0.1-tem  # Java 21 LTS
sdk install java 17.0.9-tem  # Java 17 LTS  
sdk install java 11.0.21-tem # Java 11 LTS
sdk default java 21.0.1-tem

# Install build tools
print_header "Installing Build Tools"
sdk install gradle
sdk install maven
sdk install ant

# Install Kotlin
print_header "Installing Kotlin"
sdk install kotlin

# Install Scala
print_header "Installing Scala"
sdk install scala
sdk install sbt

# Install useful JVM tools
print_header "Installing JVM Development Tools"
sdk install jbang      # Script runner for Java
sdk install visualvm   # Visual profiler
sdk install jmc        # Java Mission Control

# Install Spring Boot CLI
sdk install springboot

# Install additional development tools via Homebrew
print_header "Installing Additional Tools"
brew_install jenv      # Java version manager alternative
brew_install maven-completion
brew_install gradle-completion

# Install IntelliJ IDEA Community Edition (optional)
echo "Would you like to install IntelliJ IDEA Community Edition? (y/n)"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    print_header "Installing IntelliJ IDEA Community Edition"
    brew_cask_install intellij-idea-ce
fi

print_success "Java Development Environment Installed!"
echo ""
echo "☕ Java versions available:"
sdk list java | grep -E "installed|local" | head -10
echo ""
echo "🛠️ Build tools installed:"
echo "• Gradle $(gradle --version 2>/dev/null | grep 'Gradle' | head -1 || echo 'installed')"
echo "• Maven $(mvn --version 2>/dev/null | head -1 || echo 'installed')"
echo "• Ant $(ant -version 2>/dev/null | head -1 || echo 'installed')"
echo ""
echo "🌿 Languages installed:"
echo "• Kotlin $(kotlin -version 2>/dev/null | head -1 || echo 'installed')"
echo "• Scala $(scala -version 2>/dev/null | head -1 || echo 'installed')"
echo ""
echo "🚀 Development tools:"
echo "• Spring Boot CLI $(spring --version 2>/dev/null || echo 'installed')"
echo "• JBang - Java script runner"
echo "• VisualVM - Performance profiler"
echo "• Java Mission Control - Advanced profiler"
echo ""
echo "💡 Usage:"
echo "• Switch Java version: 'sdk use java 17.0.9-tem'"
echo "• List available versions: 'sdk list java'"
echo "• Create Spring project: 'spring init myproject'"
echo "• Run Java script: 'jbang Hello.java'"
echo "• Profile application: 'visualvm' or 'jmc'"
echo "• Use with jenv: 'jenv versions'"