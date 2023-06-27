#!/bin/bash

echo='echo -e'

if [ $# -ne 2 ]
then
    $echo "\033[091m"
    $echo "ERROR : Wrong parameters numbers. 2 kubeconfig files are required."
    $echo "        Usage : $0 <kubeconfig file for source cluster> <kubeconfig file for target cluster>"
    $echo "Exit."
    $echo "\033[0m"
    exit 3
fi

KUBECONFIG_SOURCE=$1
KUBECONFIG_TARGET=$2

if [ -f $KUBECONFIG_SOURCE ] && [ -f $KUBECONFIG_TARGET ]
then
    $echo "Files found..."
else    
    e$echocho "One of these files do not exist. Exit"
    exit 4
fi

CLUSTER_SOURCE=`kubectl config view --kubeconfig $KUBECONFIG_SOURCE -o jsonpath='{.clusters[0].name}'`
CLUSTER_TARGET=`kubectl config view --kubeconfig $KUBECONFIG_TARGET -o jsonpath='{.clusters[0].name}'`

$echo "====================================================================="
$echo "= \033[036mPrecheck\033[0m"
$echo "====================================================================="
$echo "We are going to use \033[093m$CLUSTER_SOURCE\033[0m as source"
$echo "We are going to use \033[093m$CLUSTER_TARGET\033[0m as target"
$echo ""
$echo "Are you ok [y/n] ? \c"
read TMP

if ! [ ${TMP^} == "Y" ]
then
    $echo "Exit"
    exit 5
fi

$echo "Checking..."

kubectl --kubeconfig $KUBECONFIG_SOURCE get namespaces >/dev/null 2>&1
if [ $? == 0 ]
then
    $echo "Connection to $CLUSTER_SOURCE : \033[032mOk\033[0m"
else
    $echo "Error connecting to \033[091m$CLUSTER_SOURCE\033[0m. Check it please"
    exit 6
fi

kubectl --kubeconfig $KUBECONFIG_TARGET get namespaces >/dev/null 2>&1
if [ $? == 0 ]
then
    $echo "Connection to $CLUSTER_TARGET : \033[032mOk\033[0m"
else
    $echo "Error connecting to \033[091m$CLUSTER_TARGET\033[0m. Check it please"
    exit 6
fi
$echo ""
$echo "Source namespace (on source cluster) : \c"
read NS_SOURCE
$echo "Target namespace (on target cluster) : \c"
read NS_TARGET
$echo ""

$echo "Confirm pairing creation [y/n] ? \c"
read TMP

if ! [ ${TMP^} == "Y" ]
then
    $echo "Exit"
    exit 5
fi

# ======= Namespace target Creation =======

$echo "Create target ns $NS_TARGET on target cluster... \c"
kubectl --kubeconfig $KUBECONFIG_TARGET create ns $NS_TARGET >/dev/null 2>&1
if [ $? -eq 0 ]
then
    $echo "\033[032mOk\033[0m"
else
    $echo "\033[091mKo\033[0m. Exiting"
    exit 7
fi

# ======= SA Creation =======

$echo "Create service account $NS_TARGET-sa on target cluster... \c"
kubectl --kubeconfig $KUBECONFIG_TARGET -n $NS_TARGET apply -f - >/dev/null 2>&1 <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: $NS_TARGET-sa
secrets:
 - name: $NS_TARGET-sa-secret
EOF

if [ $? -eq 0 ]
then
    $echo "\033[032mOk\033[0m"
else
    $echo "\033[091mKo\033[0m. Exiting"
    exit 7
fi

# ======= Token Creation =======

$echo "Create secret for service account $NS_TARGET-sa on target cluster... \c"
kubectl --kubeconfig $KUBECONFIG_TARGET -n $NS_TARGET apply -f - >/dev/null 2>&1 <<EOF
apiVersion: v1
kind: Secret
type: kubernetes.io/service-account-token
metadata:
 name: $NS_TARGET-sa-secret
 annotations:
   kubernetes.io/service-account.name: "$NS_TARGET-sa"
EOF

if [ $? -eq 0 ]
then
    $echo "\033[032mOk\033[0m"
else
    $echo "\033[091mKo\033[0m. Exiting"
    exit 7
fi

# ======= ClusterRole Creation =======

$echo "Create ClusterRole on target cluster... \c"
kubectl --kubeconfig $KUBECONFIG_TARGET apply -f - >/dev/null 2>&1 <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: bcdr-cluster-role
rules:
- apiGroups: ["dataservices.nutanix.com"]
  resources: ["applicationsnapshotcontents", "applicationsnapshotcontents/status"]
  verbs: ["create", "update", "get"]
- apiGroups: ["dataservices.nutanix.com"]
  resources: ["storageclusters"]
  verbs: ["get", "watch", "list"]
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["create", "get", "update"]  
EOF

if [ $? -eq 0 ]
then
    $echo "\033[032mOk\033[0m"
else
    $echo "\033[091mKo\033[0m. Exiting"
    exit 7
fi

# ======= Role Creation =======

$echo "Create Role on target cluster... \c"
kubectl --kubeconfig $KUBECONFIG_TARGET -n $NS_TARGET apply -f - >/dev/null 2>&1 <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: $NS_TARGET
  name: $NS_TARGET-role
rules:
- apiGroups: ["*"]
  resources: ["*"]
  verbs: ["*"]
EOF

if [ $? -eq 0 ]
then
    $echo "\033[032mOk\033[0m"
else
    $echo "\033[091mKo\033[0m. Exiting"
    exit 7
fi

# ======= ClusterRoleBinding Creation =======

$echo "Create ClusterRoleBinding on target cluster... \c"
kubectl --kubeconfig $KUBECONFIG_TARGET apply -f - >/dev/null 2>&1 <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: bcdr-cluster-role-binding
subjects:
- kind: ServiceAccount
  name: $NS_TARGET-sa
  apiGroup: ""
  namespace: $NS_TARGET
roleRef:
  kind: ClusterRole
  name: bcdr-cluster-role
  apiGroup: rbac.authorization.k8s.io
EOF

if [ $? -eq 0 ]
then
    $echo "\033[032mOk\033[0m"
else
    $echo "\033[091mKo\033[0m. Exiting"
    exit 7
fi

# ======= RoleBinding Creation =======

$echo "Create RoleBinding on target cluster... \c"
kubectl --kubeconfig $KUBECONFIG_TARGET -n $NS_TARGET  apply -f - >/dev/null 2>&1 <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: $NS_TARGET-role-binding
subjects:
- kind: ServiceAccount
  name: $NS_TARGET-sa
  apiGroup: ""
  namespace: $NS_TARGET
roleRef:
  kind: Role
  name: $NS_TARGET-role
  apiGroup: ""
EOF


if [ $? -eq 0 ]
then
    $echo "\033[032mOk\033[0m"
else
    $echo "\033[091mKo\033[0m. Exiting"
    exit 7
fi

# ======= kubecoinfig Creation =======
$echo "Retrieve kubeconfig for this service account... \c"

server=$(kubectl --kubeconfig $KUBECONFIG_TARGET config view --minify --raw -o jsonpath='{.clusters[].cluster.server}' | sed 's/"//')
secretName=$(kubectl --kubeconfig $KUBECONFIG_TARGET --namespace $NS_TARGET get serviceAccount ${NS_TARGET}-sa -o jsonpath='{.secrets[0].name}')
ca=$(kubectl --kubeconfig $KUBECONFIG_TARGET --namespace $NS_TARGET get secret/$secretName -o jsonpath='{.data.ca\.crt}')
token=$(kubectl --kubeconfig $KUBECONFIG_TARGET --namespace $NS_TARGET get secret/$secretName -o jsonpath='{.data.token}' | base64 --decode)

echo "
---
apiVersion: v1
kind: Config
clusters:
  - name: ${CLUSTER_TARGET}
    cluster:
      certificate-authority-data: ${ca}
      server: ${server}
contexts:
  - name: ${NS_TARGET}-sa@${CLUSTER_TARGET}
    context:
      cluster: ${CLUSTER_TARGET}
      namespace: ${NS_TARGET}
      user: ${NS_TARGET}-sa
users:
  - name: ${NS_TARGET}-sa
    user:
      token: ${token}
current-context: ${NS_TARGET}-sa@${CLUSTER_TARGET}
" > tmp.yaml

$echo "\033[032mOk\033[0m"

# ======= Secret Creation =======

$echo "Create Secret with kubeconfig from target cluster on source cluster... \c"
kubectl --kubeconfig $KUBECONFIG_SOURCE create secret generic $NS_TARGET-secret -n $NS_SOURCE --from-file=KUBECONFIG=tmp.yaml >/dev/null 2>&1 

if [ $? -eq 0 ]
then
    $echo "\033[032mOk\033[0m"
else
    $echo "\033[091mKo\033[0m. Exiting"
    exit 7
fi

rm -f ./tmp.yaml

# ======= ReplicationTarget Creation =======

$echo "Create replication target on source cluster... \c"
kubectl apply --kubeconfig $KUBECONFIG_SOURCE -n $NS_SOURCE -f - >/dev/null 2>&1  <<EOF
apiVersion: dataservices.nutanix.com/v1alpha1
kind: ReplicationTarget
metadata:
  name: target-k8s-cluster
spec:
  setupForSyncVolumeReplication: true
  targetClusterSecretRef:
    name: $NS_TARGET-secret
    key: KUBECONFIG
    
EOF

if [ $? -eq 0 ]
then
    $echo "\033[032mOk\033[0m"
else
    $echo "\033[091mKo\033[0m. Exiting"
    exit 7
fi
