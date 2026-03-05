#!/bin/bash

# 1. Basic Kubernetes Aliases
alias k='kubectl'
alias kgp='k get pods'
alias kgn='k get nodes'
alias kgs='k get svc'
alias ccat='pygmentize -g'

# 2. The "q" Mapping Function
q() {
    local num=$1
    local name=""
    case $num in
        1)  name="Question-1 MariaDB-Persistent volume" ;;
        2)  name="Question-2 ArgoCD" ;;
        3)  name="Question-3 Sidecar" ;;
        4)  name="Question-4 Resource-Allocation" ;;
        5)  name="Question-5 HPA" ;;
        6)  name="Question-6 CRDs" ;;
        7)  name="Question-7 PriorityClass" ;;
        8)  name="Question-8 CNI & Network Policy" ;;
        9)  name="Question-9 Cri-Dockerd" ;;
        10) name="Question-10 Taints-Tolerations" ;;
        11) name="Question-11 Gateway-API" ;;
        12) name="Question-12 Ingress" ;;
        13) name="Question-13 Network-Policy" ;;
        14) name="Question-14 Storage-Class" ;;
        15) name="Question-15 Etcd-Fix" ;;
        16) name="Question-16 NodePort" ;;
        17) name="Question-17 TLS-Config" ;;
        *) echo "Usage: q <number> (e.g., q 8)"; return 1 ;;
    esac

    echo "Launching: $name"
    # Logic to find the script path dynamically
    SCRIPT_PATH="$(pwd)/scripts/run-question.sh"
    bash "$SCRIPT_PATH" "$name"
}

# Export the function so it's available in the shell
export -f q

echo "✅ Environment Ready! Use 'q 1' to 'q 17' to launch labs."
