#!/usr/bin/env bash
# Simple SSH setup + test script for GitHub, GitLab and Azure DevOps
# Intended to run standalone: ./configure_ssh.sh
# Added: --dry-run, --scan to interactively scan/update ~/.ssh/config and allow dry-run checks

set -o errexit
set -o nounset
set -o pipefail

SCRIPT_NAME="$(basename "$0")"

usage() {
    cat <<EOF
Usage: $SCRIPT_NAME [--no-agent] [--no-copy] [--yes] [--dry-run] [--scan]
Options:
  --no-agent    Don't start ssh-agent or add keys automatically
  --no-copy     Don't attempt to copy public key to clipboard
  --yes         Assume yes to prompts (non-interactive friendly)
  --dry-run     Show what would be done, but don't change anything
  --scan        Scan ~/.ssh/config and interactively offer fixes/updates
  -h, --help    Show this help
EOF
    exit 0
}

NO_AGENT=false
NO_COPY=false
ASSUME_YES=false
DRY_RUN=false
DO_SCAN=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --no-agent) NO_AGENT=true; shift;;
        --no-copy) NO_COPY=true; shift;;
        --yes) ASSUME_YES=true; shift;;
        --dry-run) DRY_RUN=true; shift;;
        --scan) DO_SCAN=true; shift;;
        -h|--help) usage;;
        *) echo "Unknown argument: $1"; usage;;
    esac
done

confirm() {
    local prompt="${1:-Proceed?} (y/N): "
    if $ASSUME_YES; then
        return 0
    fi
    read -r -p "$prompt" answer
    case "$answer" in
        [Yy]|[Yy][Ee][Ss]) return 0 ;;
        *) return 1 ;;
    esac
}

info(){ printf '\e[1;34m%s\e[0m\n' "$*"; }
ok(){ printf '\e[1;32m%s\e[0m\n' "$*"; }
warn(){ printf '\e[1;33m%s\e[0m\n' "$*"; }
err(){ printf '\e[1;31m%s\e[0m\n' "$*"; }

SSH_DIR="$HOME/.ssh"
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

list_keys() {
    info "Existing public keys in $SSH_DIR:"
    ls -1 "${SSH_DIR}"/*.pub 2>/dev/null || echo "  (none)"
}

find_preferred_key() {
    # prefer ed25519, then rsa, then ecdsa
    for k in id_ed25519 id_rsa id_ecdsa; do
        [ -f "$SSH_DIR/$k" ] && { printf '%s\n' "$SSH_DIR/$k"; return 0; }
    done
    return 1
}

generate_key() {
    local type="$1"
    local filepath="$2"
    local comment="$3"

    if [ -f "$filepath" ] || [ -f "${filepath}.pub" ]; then
        warn "Key $filepath already exists, skipping generation."
        return 0
    fi

    if $DRY_RUN; then
        info "DRY RUN: would generate $type key at $filepath with comment '$comment'"
        return 0
    fi

    case "$type" in
        ed25519)
            ssh-keygen -t ed25519 -C "$comment" -f "$filepath"
            ;;
        rsa)
            ssh-keygen -t rsa -b 4096 -C "$comment" -f "$filepath"
            ;;
        ecdsa)
            ssh-keygen -t ecdsa -b 521 -C "$comment" -f "$filepath"
            ;;
        *)
            err "Unknown key type: $type"
            return 1
            ;;
    esac

    chmod 600 "$filepath"
    chmod 644 "${filepath}.pub"
    ok "Generated key: $filepath"
}

start_agent_and_add() {
    if $NO_AGENT; then
        warn "Skipping ssh-agent start / ssh-add due to --no-agent"
        return 0
    fi

    if $DRY_RUN; then
        info "DRY RUN: would start ssh-agent (if needed) and add key $1"
        return 0
    fi

    # start ssh-agent if not running
    if [ -z "${SSH_AUTH_SOCK:-}" ] || ! ssh-add -l >/dev/null 2>&1; then
        info "Starting ssh-agent..."
        eval "$(ssh-agent -s)" >/dev/null
    fi

    # add private key
    local key="$1"
    if [ -f "$key" ]; then
        ssh-add "$key" >/dev/null 2>&1 || warn "ssh-add returned non-zero; you may need to enter the key passphrase."
        ok "Added $key to ssh-agent"
    else
        warn "Key not found: $key"
    fi
}

copy_to_clipboard() {
    local pub="$1"
    if $NO_COPY; then
        warn "Skipping clipboard copy due to --no-copy"
        return 0
    fi
    if $DRY_RUN; then
        info "DRY RUN: would copy $pub to clipboard (if a clipboard utility exists)"
        return 0
    fi
    if command -v xclip >/dev/null 2>&1; then
        xclip -selection clipboard < "$pub" && ok "Public key copied to clipboard (xclip)."
        return 0
    fi
    if command -v xsel >/dev/null 2>&1; then
        xsel --clipboard --input < "$pub" && ok "Public key copied to clipboard (xsel)."
        return 0
    fi
    if command -v wl-copy >/dev/null 2>&1; then
        wl-copy < "$pub" && ok "Public key copied to clipboard (wl-copy)."
        return 0
    fi
    if command -v pbcopy >/dev/null 2>&1; then
        pbcopy < "$pub" && ok "Public key copied to clipboard (pbcopy)."
        return 0
    fi
    warn "No clipboard utility found (xclip/xsel/wl-copy/pbcopy). Public key not copied automatically."
}

create_ssh_config() {
    local cfg="$SSH_DIR/config"
    local sample="$(mktemp)"
    cat > "$sample" <<'EOF'
# SSH config added by configure_ssh.sh
Host github.com
  HostName github.com
  User git
  IdentitiesOnly yes

Host gitlab.com
  HostName gitlab.com
  User git
  IdentitiesOnly yes

Host ssh.dev.azure.com
  HostName ssh.dev.azure.com
  User git
  IdentitiesOnly yes
EOF

    if [ -f "$cfg" ]; then
        info "SSH config already exists at $cfg"
        if confirm "Open and edit existing config?"; then
            if $DRY_RUN; then
                info "DRY RUN: would open $cfg in editor (${EDITOR:-nano})"
            else
                ${EDITOR:-nano} "$cfg"
            fi
        fi
        rm -f "$sample"
        return
    fi

    if $DRY_RUN; then
        info "DRY RUN: would write sample SSH config to $cfg"
        printf '%s\n' "----- sample config -----"
        cat "$sample"
        printf '%s\n' "-------------------------"
        rm -f "$sample"
        return
    fi

    mv "$sample" "$cfg"
    chmod 600 "$cfg"
    ok "Wrote sample SSH config to $cfg"
    info "Edit it if you need custom IdentityFile entries or different Host aliases."
}

# Produce a cleaned representation of ~/.ssh/config for scanning
_normalize_config() {
    # remove comments and leading/trailing whitespace for easier grepping
    sed -e 's/#.*$//' -e 's/^[[:space:]]*//; s/[[:space:]]*$//' "$1" 2>/dev/null || true
}

scan_ssh_config() {
    local cfg="$SSH_DIR/config"
    if [ ! -f "$cfg" ]; then
        info "No SSH config at $cfg"
        if confirm "Create a sample SSH config now?"; then
            create_ssh_config
        fi
        return
    fi

    info "Scanning $cfg for Host entries and IdentityFile settings..."
    local norm
    norm="$(mktemp)"
    _normalize_config "$cfg" > "$norm"

    local hosts
    hosts="$(awk '/^Host[[:space:]]+/ {print $2}' "$norm" | sort -u || true)"
    info "Found Host entries:"
    if [ -z "$hosts" ]; then
        echo "  (none)"
    else
        printf '  %s\n' $hosts
    fi

    # For each service, check Host block for IdentityFile
    local services=("github.com" "gitlab.com" "ssh.dev.azure.com")
    local changed=false
    local tmp_new cfg_backup tmp_tmp
    tmp_new="$(mktemp)"
    cp "$cfg" "$tmp_new"

    for svc in "${services[@]}"; do
        # find Host block (simple approach)
        if grep -E -q "^Host[[:space:]]+$svc(\$|[[:space:]])" "$cfg"; then
            info "Host $svc present in config."
            # check for IdentityFile in block
            if awk "/^Host[[:space:]]+$svc/,/^Host[[:space:]]+/ { if(/^IdentityFile[[:space:]]+/) print \$0 }" "$cfg" | grep -q .; then
                info "  IdentityFile set for $svc"
            else
                warn "  No IdentityFile found for $svc"
                if confirm "Add IdentityFile pointing to your key for $svc?"; then
                    # propose adding IdentityFile under the Host block
                    # naive insertion: append IdentityFile after Host line
                    if $DRY_RUN; then
                        info "DRY RUN: would add '  IdentityFile $current_key' to Host $svc block"
                    else
                        # insert after the Host line
                        awk -v svc="$svc" -v key="$current_key" '
                            BEGIN{added=0}
                            /^Host[[:space:]]+/{print; if($2==svc){print "  IdentityFile " key; added=1; next}}
                            {print}
                            END{ if(added==0){} }
                        ' "$tmp_new" > "${tmp_new}.new" && mv "${tmp_new}.new" "$tmp_new"
                        changed=true
                        ok "Added IdentityFile for $svc to proposed config"
                    fi
                fi
            fi
        else
            warn "No Host block for $svc"
            if confirm "Add a Host block for $svc with IdentityFile pointing to your key?"; then
                if $DRY_RUN; then
                    info "DRY RUN: would append Host block for $svc with IdentityFile $current_key"
                else
                    {
                        printf '\nHost %s\n  HostName %s\n  User git\n  IdentitiesOnly yes\n  IdentityFile %s\n' "$svc" "$svc" "$current_key"
                    } >> "$tmp_new"
                    changed=true
                    ok "Appended Host block for $svc"
                fi
            fi
        fi
    done

    if $DRY_RUN; then
        info "DRY RUN: proposed config changes (no file written):"
        printf '%s\n' "----- proposed ~/.ssh/config -----"
        cat "$tmp_new"
        printf '%s\n' "----------------------------------"
        rm -f "$tmp_new" "$norm"
        return
    fi

    if [ "$changed" = true ]; then
        cfg_backup="${cfg}.bak.$(date +%Y%m%d%H%M%S)"
        cp "$cfg" "$cfg_backup"
        mv "$tmp_new" "$cfg"
        chmod 600 "$cfg"
        ok "Applied changes to $cfg (backup saved to $cfg_backup)"
    else
        info "No changes made to $cfg"
        rm -f "$tmp_new"
    fi

    rm -f "$norm"
}

test_ssh_connection() {
    local host="$1"
    local ssh_target="$2"   # e.g., git@github.com
    info "Testing SSH connection to $host ($ssh_target)..."
    # Use BatchMode to avoid prompt; capture stdout+stderr
    local out
    if ! out="$(ssh -T -o BatchMode=yes -o StrictHostKeyChecking=accept-new "$ssh_target" 2>&1)"; then
        # non-zero exit: still may be successful (GitHub returns 1 after successful auth)
        :
    fi
    printf '%s\n' "$out"

    local out_lc
    out_lc="$(printf '%s' "$out" | tr '[:upper:]' '[:lower:]')"
    if printf '%s' "$out_lc" | grep -q -e 'authenticated' -e 'welcome to gitlab' -e 'welcome to azure' -e 'successfully authenticated' -e 'welcome to'; then
        ok "SSH to $host appears successful."
        return 0
    fi

    warn "Could not confirm successful authentication to $host from SSH output. Please check manually."
    return 1
}

open_web_add_key() {
    local service="$1"
    local url="$2"
    if command -v xdg-open >/dev/null 2>&1; then
        if confirm "Open $service key settings page in browser?"; then
            if $DRY_RUN; then
                info "DRY RUN: would open $url in browser"
            else
                xdg-open "$url" >/dev/null 2>&1 || warn "xdg-open failed to open $url"
            fi
        fi
    else
        info "Open this URL in your browser to add the key: $url"
    fi
}

interactive_menu() {
    while true; do
        echo
        echo "Select an action:"
        echo "  1) Show keys / generate key"
        echo "  2) Start agent & add key"
        echo "  3) Scan or update ~/.ssh/config"
        echo "  4) Copy public key to clipboard"
        echo "  5) Open web pages to add key to services"
        echo "  6) Test SSH connections to services"
        echo "  7) Exit"
        read -r -p "Choice [1-7]: " choice
        case "$choice" in
            1)
                list_keys
                if confirm "Generate a new key?"; then
                    if confirm "Generate ed25519?"; then
                        key_type="ed25519"; keyfile="$SSH_DIR/id_ed25519"
                    else
                        key_type="rsa"; keyfile="$SSH_DIR/id_rsa"
                    fi
                    read -r -p "Enter key comment (email) [${USER}@$(hostname --short)]: " key_comment
                    key_comment="${key_comment:-$USER@$(hostname --short)}"
                    generate_key "$key_type" "$keyfile" "$key_comment"
                    current_key="$keyfile"
                fi
                ;;
            2)
                start_agent_and_add "${current_key:-$(find_preferred_key 2>/dev/null || echo '')}"
                ;;
            3)
                scan_ssh_config
                ;;
            4)
                copy_to_clipboard "${current_key:-${SSH_DIR}/id_ed25519.pub}"
                ;;
            5)
                open_web_add_key "GitHub" "https://github.com/settings/keys"
                open_web_add_key "GitLab" "https://gitlab.com/-/profile/keys"
                open_web_add_key "Azure DevOps" "https://dev.azure.com"
                ;;
            6)
                test_ssh_connection "GitHub" "git@github.com" || warn "GitHub SSH test had issues."
                test_ssh_connection "GitLab" "git@gitlab.com" || warn "GitLab SSH test had issues."
                test_ssh_connection "Azure DevOps" "git@ssh.dev.azure.com" || warn "Azure DevOps SSH test had issues."
                ;;
            7) break ;;
            *) warn "Invalid choice" ;;
        esac
    done
}

main() {
    info "SSH configuration helper"

    list_keys

    if find_preferred_key >/dev/null 2>&1; then
        current_key="$(find_preferred_key)"
        ok "Found existing key: $current_key"
    else
        warn "No existing preferred private key found (id_ed25519, id_rsa, id_ecdsa)."

        if ! confirm "Generate a new ed25519 key now?"; then
            if ! confirm "Generate RSA 4096-bit key instead?"; then
                warn "No key generated."
                # allow user to continue (they may want to scan or only test)
            else
                key_type="rsa"
                keyfile="$SSH_DIR/id_rsa"
                read -r -p "Enter an email/comment for the key (e.g. your_email@example.com): " key_comment
                key_comment="${key_comment:-$USER@$(hostname --short)}"
                generate_key "$key_type" "$keyfile" "$key_comment"
                current_key="$keyfile"
            fi
        else
            key_type="ed25519"
            keyfile="$SSH_DIR/id_ed25519"
            read -r -p "Enter an email/comment for the key (e.g. your_email@example.com): " key_comment
            key_comment="${key_comment:-$USER@$(hostname --short)}"
            generate_key "$key_type" "$keyfile" "$key_comment"
            current_key="$keyfile"
        fi
    fi

    # set pub_key variable if key exists
    pub_key="${current_key:-}${current_key:+.pub}"
    if [ -n "${current_key:-}" ] && [ -f "${pub_key:-}" ]; then
        info "Public key:"
        printf '%s\n' "------------------------"
        cat "$pub_key"
        printf '%s\n' "------------------------"
    else
        if [ -z "${current_key:-}" ]; then
            warn "No key selected/generated to show public key for."
        else
            err "Public key not found at $pub_key"
        fi
    fi

    # If --scan was passed, perform scan now (interactive prompts happen inside)
    if $DO_SCAN; then
        scan_ssh_config
    fi

    # If not in dry-run and user wants, offer to start agent and add
    if confirm "Start ssh-agent and add your key to the agent?"; then
        start_agent_and_add "${current_key:-${SSH_DIR}/id_rsa}"
    fi

    # Offer to create or edit SSH config (will be handled by scan_ssh_config if chosen)
    if confirm "Create or open a sample ~/.ssh/config with Host entries for GitHub/GitLab/Azure DevOps?"; then
        create_ssh_config
    fi

    # Offer to open web pages for adding keys
    if confirm "Open web pages to add your public key to services (GitHub, GitLab, Azure DevOps)?"; then
        open_web_add_key "GitHub" "https://github.com/settings/keys"
        open_web_add_key "GitLab" "https://gitlab.com/-/profile/keys"
        open_web_add_key "Azure DevOps" "https://dev.azure.com"
    fi

    # Offer interactive menu for more actions (scan, dry-run checks, tests)
    if $DRY_RUN; then
        info "Running in DRY RUN mode: no changes will be made."
    fi

    if confirm "Would you like to run the interactive action menu (scan/update/test)?"; then
        interactive_menu
    else
        # Quick test run if user prefers no menu
        if confirm "Run quick SSH tests for GitHub/GitLab/Azure DevOps now?"; then
            test_ssh_connection "GitHub" "git@github.com" || warn "GitHub SSH test had issues."
            test_ssh_connection "GitLab" "git@gitlab.com" || warn "GitLab SSH test had issues."
            test_ssh_connection "Azure DevOps" "git@ssh.dev.azure.com" || warn "Azure DevOps SSH test had issues."
        fi
    fi

    ok "Done. If any tests failed, re-check your public key is added to the services and that the correct IdentityFile is used in ~/.ssh/config or supplied via ssh-agent."
}

main "$@"

