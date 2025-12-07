#!/usr/bin/env bash
set -e
source ../scripts/helpers.sh

print_header "Installing Java Development Environment"

# Install SDKMAN!
if [ ! -d "$HOME/.sdkman" ]; then
    print_header "Installing SDKMAN!"
    curl -s "https://get.sdkman.io" | bash
    source "$HOME/.sdkman/bin/sdkman-init.sh"
else
    print_warning "SDKMAN! already installed"
    source "$HOME/.sdkman/bin/sdkman-init.sh"
fi

# Install Java versions
print_header "Installing Java Versions"
sdk install java 21.0.1-tem  # Temurin (Eclipse Adoptium) LTS
sdk install java 17.0.9-tem  # Temurin LTS
sdk install java 11.0.21-tem # Temurin LTS
sdk default java 21.0.1-tem

# Install Gradle and Maven
print_header "Installing Build Tools"
sdk install gradle
sdk install maven

# Install Kotlin
print_header "Installing Kotlin"
sdk install kotlin

# Install useful JVM tools
print_header "Installing JVM Development Tools"
sdk install jbang      # Script runner
sdk install visualvm   # Profiler

# Install Spring Boot CLI
sdk install springboot

print_success "Java Development Environment Installed!"
echo ""
echo "☕ Java versions available:"
sdk list java | grep -E "installed|local"
echo ""
echo "🛠️ Build tools installed:"
echo "• Gradle $(gradle --version | head -1)"
echo "• Maven $(mvn --version | head -1)"
echo "• Kotlin $(kotlin -version)"
echo "• Spring Boot CLI $(spring --version)"
echo ""
echo "💡 Usage:"
echo "• Switch Java version: 'sdk use java 17.0.9-tem'"
echo "• List available versions: 'sdk list java'"
echo "• Create Spring project: 'spring init myproject'"
echo "• Run Kotlin script: 'jbang script.kt'"
echo "• Profile application: 'visualvm'"