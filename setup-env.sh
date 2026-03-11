#!/bin/bash

# 1. Define the base directory explicitly
export BASE_DIR="$(pwd)"

# 2. Automatically make all .bash and .sh files executable
# Added a check: if BASE_DIR is empty, use current directory (.)
find "${BASE_DIR:-.}" -type f \( -name "*.bash" -o -name "*.sh" \) -exec chmod +x {} +

# Define the function
q() {
    local num=$1
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

    # Using the BASE_DIR variable we defined above for consistency
    bash "$BASE_DIR/scripts/run-question.sh" "$name"
}

# Create aliases q1, q2... q20
for i in {1..20}; do
    alias "q$i"="q $i"
done

echo "✅ Ready! You can now use 'q 1' OR just 'q1' to start labs."
