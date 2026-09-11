#!/usr/bin/env bash
# Tool registry — defines how to check and install each tool
# Sourced by check-and-install.sh

# ============================================================
# Playbook tool lists
# ============================================================

TOOLS_WEB_APP=(
    subfinder httpx nuclei katana ffuf feroxbuster
    dalfox sqlmap gau waybackurls arjun
    gospider hakrawler wfuzz jwt_tool tplmap
    nmap curl jq
)

TOOLS_API=(
    httpx nuclei curl jq
    ffuf arjun sqlmap
    nmap
)

TOOLS_BINARY=(
    gdb checksec ropper file readelf
    strace ltrace objdump
    python3 pip3 pwntools angr
    afl-fuzz
)

TOOLS_MOBILE=(
    jadx apktool adb frida objection
    mitmproxy curl jq
)

TOOLS_OPENSOURCE=(
    git semgrep trufflehog
    python3 pip3 node npm
)

TOOLS_CLOUD=(
    nmap subfinder httpx nuclei
    aws gcloud az
    kubectl docker
    scoutsuite prowler pacu
    enumerate-iam kube-hunter trivy
    dig curl jq
)

# ============================================================
# Check functions — return 0 if installed
# ============================================================

check_tool() {
    local tool="$1"
    case "$tool" in
        # Go tools (check binary)
        subfinder|httpx|nuclei|katana|ffuf|gau|arjun|gospider|hakrawler)
            command -v "$tool" &>/dev/null ;;
        feroxbuster)
            command -v feroxbuster &>/dev/null ;;
        dalfox)
            command -v dalfox &>/dev/null ;;
        waybackurls)
            command -v waybackurls &>/dev/null ;;

        # Python tools
        sqlmap)
            command -v sqlmap &>/dev/null || python3 -c "import sqlmap" &>/dev/null ;;
        semgrep)
            command -v semgrep &>/dev/null ;;
        trufflehog)
            command -v trufflehog &>/dev/null ;;
        mitmproxy)
            command -v mitmproxy &>/dev/null ;;
        objection)
            command -v objection &>/dev/null ;;
        frida)
            command -v frida &>/dev/null || pip3 show frida-tools &>/dev/null ;;
        wfuzz)
            command -v wfuzz &>/dev/null ;;
        jwt_tool)
            command -v jwt_tool &>/dev/null || [[ -f ~/jwt_tool/jwt_tool.py ]] ;;
        tplmap)
            command -v tplmap &>/dev/null || [[ -f ~/tplmap/tplmap.py ]] ;;
        angr)
            python3 -c "import angr" &>/dev/null ;;
        scoutsuite)
            command -v scout &>/dev/null || pip3 show ScoutSuite &>/dev/null ;;
        prowler)
            command -v prowler &>/dev/null ;;
        pacu)
            command -v pacu &>/dev/null || pip3 show pacu &>/dev/null ;;
        enumerate-iam)
            command -v enumerate-iam &>/dev/null || [[ -f ~/enumerate-iam/enumerate-iam.py ]] ;;
        kube-hunter)
            command -v kube-hunter &>/dev/null || pip3 show kube-hunter &>/dev/null ;;
        trivy)
            command -v trivy &>/dev/null ;;

        # Android tools
        jadx)
            command -v jadx &>/dev/null ;;
        apktool)
            command -v apktool &>/dev/null ;;
        adb)
            command -v adb &>/dev/null ;;

        # Binary tools
        gdb)
            command -v gdb &>/dev/null ;;
        checksec)
            command -v checksec &>/dev/null || (command -v checksec.sh &>/dev/null) ;;
        ropper)
            command -v ropper &>/dev/null || pip3 show ropper &>/dev/null ;;
        pwntools)
            python3 -c "import pwn" &>/dev/null ;;
        afl-fuzz)
            command -v afl-fuzz &>/dev/null ;;

        # System tools
        nmap|curl|jq|git|dig|file|readelf|strace|ltrace|objdump)
            command -v "$tool" &>/dev/null ;;
        python3|pip3|node|npm)
            command -v "$tool" &>/dev/null ;;

        # Cloud CLIs
        aws)
            command -v aws &>/dev/null ;;
        gcloud)
            command -v gcloud &>/dev/null ;;
        az)
            command -v az &>/dev/null ;;
        kubectl)
            command -v kubectl &>/dev/null ;;
        docker)
            command -v docker &>/dev/null ;;

        # Rust tools
        cargo)
            command -v cargo &>/dev/null ;;

        *)
            command -v "$tool" &>/dev/null ;;
    esac
}

# ============================================================
# Install functions
# ============================================================

detect_os() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        echo "$ID"
    elif [[ "$(uname)" == "Darwin" ]]; then
        echo "macos"
    else
        echo "unknown"
    fi
}

has_go() { command -v go &>/dev/null; }
has_pip() { command -v pip3 &>/dev/null; }
has_cargo() { command -v cargo &>/dev/null; }
has_brew() { command -v brew &>/dev/null; }
has_apt() { command -v apt-get &>/dev/null; }

install_go_tool() {
    local pkg="$1"
    if ! has_go; then
        echo "Go not installed. Installing Go first..."
        install_go
    fi
    go install "$pkg" 2>&1
}

install_go() {
    local os=$(detect_os)
    case "$os" in
        ubuntu|debian|kali)
            sudo apt-get update && sudo apt-get install -y golang-go ;;
        macos)
            brew install go ;;
        *)
            echo "Please install Go manually: https://go.dev/dl/"
            return 1 ;;
    esac
}

install_tool() {
    local tool="$1"
    local os=$(detect_os)

    case "$tool" in
        # === Go tools ===
        subfinder)
            install_go_tool "github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest" ;;
        httpx)
            install_go_tool "github.com/projectdiscovery/httpx/cmd/httpx@latest" ;;
        nuclei)
            install_go_tool "github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest" ;;
        katana)
            install_go_tool "github.com/projectdiscovery/katana/cmd/katana@latest" ;;
        ffuf)
            install_go_tool "github.com/ffuf/ffuf/v2@latest" ;;
        gau)
            install_go_tool "github.com/lc/gau/v2/cmd/gau@latest" ;;
        waybackurls)
            install_go_tool "github.com/tomnomnom/waybackurls@latest" ;;
        dalfox)
            install_go_tool "github.com/hahwul/dalfox/v2@latest" ;;
        arjun)
            pip3 install arjun 2>&1 ;;
        gospider)
            install_go_tool "github.com/jaeles-project/gospider@latest" ;;
        hakrawler)
            install_go_tool "github.com/hakluke/hakrawler@latest" ;;

        # === Rust tools ===
        feroxbuster)
            if has_cargo; then
                cargo install feroxbuster 2>&1
            elif has_apt; then
                sudo apt-get update && sudo apt-get install -y feroxbuster 2>&1
            elif has_brew; then
                brew install feroxbuster 2>&1
            else
                echo "Install Rust first: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
                return 1
            fi ;;

        # === Python tools ===
        sqlmap)
            pip3 install sqlmap 2>&1 ;;
        semgrep)
            pip3 install semgrep 2>&1 ;;
        trufflehog)
            pip3 install trufflehog 2>&1 || install_go_tool "github.com/trufflesecurity/trufflehog@latest" ;;
        mitmproxy)
            pip3 install mitmproxy 2>&1 ;;
        frida)
            pip3 install frida-tools 2>&1 ;;
        objection)
            pip3 install objection 2>&1 ;;
        ropper)
            pip3 install ropper 2>&1 ;;
        pwntools)
            pip3 install pwntools 2>&1 ;;
        wfuzz)
            pip3 install wfuzz 2>&1 ;;
        jwt_tool)
            git clone https://github.com/ticarpi/jwt_tool.git ~/jwt_tool 2>&1
            pip3 install -r ~/jwt_tool/requirements.txt 2>&1
            chmod +x ~/jwt_tool/jwt_tool.py
            sudo ln -sf ~/jwt_tool/jwt_tool.py /usr/local/bin/jwt_tool ;;
        tplmap)
            git clone https://github.com/epinna/tplmap.git ~/tplmap 2>&1
            pip3 install -r ~/tplmap/requirements.txt 2>&1 || true
            chmod +x ~/tplmap/tplmap.py
            sudo ln -sf ~/tplmap/tplmap.py /usr/local/bin/tplmap ;;
        angr)
            pip3 install angr 2>&1 ;;
        scoutsuite)
            pip3 install scoutsuite 2>&1 ;;
        prowler)
            pip3 install prowler 2>&1 ;;
        pacu)
            pip3 install pacu 2>&1 ;;
        enumerate-iam)
            git clone https://github.com/andresriancho/enumerate-iam.git ~/enumerate-iam 2>&1
            pip3 install -r ~/enumerate-iam/requirements.txt 2>&1 || true
            chmod +x ~/enumerate-iam/enumerate-iam.py
            sudo ln -sf ~/enumerate-iam/enumerate-iam.py /usr/local/bin/enumerate-iam ;;
        kube-hunter)
            pip3 install kube-hunter 2>&1 ;;
        trivy)
            case "$os" in
                ubuntu|debian|kali)
                    sudo apt-get install -y wget apt-transport-https gnupg lsb-release 2>&1
                    wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo gpg --dearmor -o /usr/share/keyrings/trivy.gpg 2>&1
                    echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" | sudo tee /etc/apt/sources.list.d/trivy.list
                    sudo apt-get update && sudo apt-get install -y trivy 2>&1 ;;
                macos)
                    brew install trivy 2>&1 ;;
                *)
                    echo "Install trivy manually: https://aquasecurity.github.io/trivy/"
                    return 1 ;;
            esac ;;
        afl-fuzz)
            case "$os" in
                ubuntu|debian|kali)
                    sudo apt-get update && sudo apt-get install -y afl++ 2>&1 ;;
                macos)
                    brew install aflplusplus 2>&1 ;;
                *)
                    echo "Install AFL++ manually: https://github.com/AFLplusplus/AFLplusplus"
                    return 1 ;;
            esac ;;

        # === System packages ===
        nmap|curl|jq|git|dig|file|readelf|strace|ltrace|objdump|gdb)
            case "$os" in
                ubuntu|debian|kali)
                    local pkg="$tool"
                    [[ "$tool" == "dig" ]] && pkg="dnsutils"
                    [[ "$tool" == "readelf" || "$tool" == "objdump" ]] && pkg="binutils"
                    sudo apt-get update && sudo apt-get install -y "$pkg" 2>&1 ;;
                macos)
                    brew install "$tool" 2>&1 ;;
                *)
                    echo "Please install $tool manually"
                    return 1 ;;
            esac ;;

        checksec)
            if has_apt; then
                sudo apt-get update && sudo apt-get install -y checksec 2>&1
            else
                # Install from source
                curl -sL https://raw.githubusercontent.com/slimm609/checksec.sh/master/checksec -o /usr/local/bin/checksec 2>&1
                chmod +x /usr/local/bin/checksec
            fi ;;

        # === Android tools ===
        jadx)
            case "$os" in
                ubuntu|debian|kali)
                    sudo apt-get update && sudo apt-get install -y jadx 2>&1 || {
                        echo "Installing jadx from GitHub release..."
                        local ver=$(curl -s https://api.github.com/repos/skylot/jadx/releases/latest | jq -r .tag_name)
                        curl -sL "https://github.com/skylot/jadx/releases/download/${ver}/jadx-${ver#v}.zip" -o /tmp/jadx.zip
                        sudo unzip -o /tmp/jadx.zip -d /opt/jadx
                        sudo ln -sf /opt/jadx/bin/jadx /usr/local/bin/jadx
                        rm /tmp/jadx.zip
                    } ;;
                macos)
                    brew install jadx 2>&1 ;;
            esac ;;
        apktool)
            case "$os" in
                ubuntu|debian|kali)
                    sudo apt-get update && sudo apt-get install -y apktool 2>&1 ;;
                macos)
                    brew install apktool 2>&1 ;;
            esac ;;
        adb)
            case "$os" in
                ubuntu|debian|kali)
                    sudo apt-get update && sudo apt-get install -y android-tools-adb 2>&1 ;;
                macos)
                    brew install android-platform-tools 2>&1 ;;
            esac ;;

        # === Node tools ===
        node|npm)
            case "$os" in
                ubuntu|debian|kali)
                    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
                    sudo apt-get install -y nodejs 2>&1 ;;
                macos)
                    brew install node 2>&1 ;;
            esac ;;

        python3|pip3)
            case "$os" in
                ubuntu|debian|kali)
                    sudo apt-get update && sudo apt-get install -y python3 python3-pip 2>&1 ;;
                macos)
                    brew install python 2>&1 ;;
            esac ;;

        # === Cloud CLIs ===
        aws)
            curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
            unzip -o /tmp/awscliv2.zip -d /tmp/aws
            sudo /tmp/aws/aws/install 2>&1
            rm -rf /tmp/awscliv2.zip /tmp/aws ;;
        kubectl)
            curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
            chmod +x kubectl && sudo mv kubectl /usr/local/bin/ 2>&1 ;;
        docker)
            curl -fsSL https://get.docker.com | sh 2>&1 ;;

        *)
            echo "No installer defined for: $tool"
            echo "Please install manually."
            return 1 ;;
    esac
}
