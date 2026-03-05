#!/bin/bash

# Define the function as before
q() {
    local num=$1
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
        *) echo "Usage: q <num> or q<num>"; return 1 ;;
    esac
    
    bash "$(pwd)/scripts/run-question.sh" "$name"
}

# NEW: This loop automatically creates aliases q1, q2... q17
for i in {1..17}; do
    alias "q$i"="q $i"
done

echo "✅ Ready! You can now use 'q 1' OR just 'q1' to start labs."
