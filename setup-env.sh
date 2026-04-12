#!/bin/bash

# 1. Define the base directory explicitly
export BASE_DIR="$(pwd)"

# 2. Automatically make all .bash and .sh files executable
find "${BASE_DIR:-.}" -type f \( -name "*.bash" -o -name "*.sh" \) -exec chmod +x {} +

# Define the function
q() {
    local num=$1
    local name=""
    case $num in
        1)  name="Question-01-MariaDB-PV" ;;
        2)  name="Question-02-ArgoCD" ;;
        3)  name="Question-03-Sidecar" ;;
        4)  name="Question-04-Resource-Allocation" ;;
        5)  name="Question-05-HPA" ;;
        6)  name="Question-06-CRDs" ;;
        7)  name="Question-07-PriorityClass" ;;
        8)  name="Question-08-CNI-Network-Policy" ;;
        9)  name="Question-09-Cri-Dockerd" ;;
        10) name="Question-10-Taints-Tolerations" ;;
        11) name="Question-11-Gateway-API" ;;
        12) name="Question-12-Ingress" ;;
        13) name="Question-13-Network-Policy" ;;
        14) name="Question-14-Storage-Class" ;;
        15) name="Question-15-Etcd-Fix" ;;
        16) name="Question-16-NodePort" ;;
        17) name="Question-17-TLS-Config" ;;
        18) name="Question-18-Control-Plane-Issues" ;;
        19) name="Question-19-Data-Plane-Issues" ;;
        20) name="Question-20-Etcd-Disaster-Recovery" ;;
        *) echo "Usage: q <num>"; return 1 ;;
    esac

    # CHANGE 1: Automatically CD into the folder
    cd "$BASE_DIR/$name" || { echo "❌ Folder $name not found!"; return 1; }

    # CHANGE 2: Execute LabSetUp.bash if it exists
    if [ -f "LabSetUp.bash" ]; then
        echo "🚀 Setting up environment for $name..."
        bash LabSetUp.bash
    fi

    # CHANGE 3: Display the content of Questions.bash
    if [ -f "Questions.bash" ]; then
        echo -e "\n📝 --- QUESTION DETAILS ---"
        cat Questions.bash
        echo -e "---------------------------\n"
    else
        echo "⚠️  Questions.bash not found in this directory."
    fi
}

# Create aliases q1, q2... q20
for i in {1..20}; do
    alias "q$i"="q $i"
done

echo "✅ Environment Ready! Type 'q1' to jump into Question 1."
