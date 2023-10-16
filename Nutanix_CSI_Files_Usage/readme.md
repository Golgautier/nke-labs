_Difficulty: 3/5_

# Summary:

This exercise will teach you how to use Nutanix CSI for Nutanix Files

# Prerequisites

- A Nutanix cluster with a kubernetes cluster deployed with NKE
- A Nutanix Files server deployed
- `kubectl` command must be installed on your laptop.

# Presentation / Context

Nutanix provides a CSI driver to consume storage with kubernetes.

The CSI driver can use block storage (using Nutanix Volumes) and files storage (using Nutanix Files). We often use block storage by default, for RWO (Read Write Once persistent Volume) and files storage for RWX (Read WRite Many) access.

To create a persistent volume (PV) on a Kubernetes cluster, you need to do a persistent volume claim (PVC). This PVC will use a storage class (SC) to get all needed informations to request PV creation.

You can have (only) one default Storage Class on your kubernetes cluster. If your PVC does not specify Storage Class, the default one will be used.

Two Nutanix Files mode can be created :

- Static : A share, located on a Nutanix File Server will be used to store all volumes created by the CSI. It doesn't require any specific access to Prism Element, as it will target directly Nutanix Files NFS Server
- Dynamic : One dedicated share will be created for each volume created by the CSI. A secret storing Prism Element username and passward, and Nutanix Files API username and password will be required.

# Exercise

## Create a new storage class named nutanix-files-static

1. You'll need to create a dedicated storageclass named nutanix-files-static. Create a manifest defining the secret and apply it.
   <details>
   <summary>Answer</summary>

   > 1. Create a manifest to deploy :
   >    ```yaml
   >    ---
   >    kind: StorageClass
   >    apiVersion: storage.k8s.io/v1
   >    metadata:
   >      name: nutanix-files-static
   >      annotations:
   >        storageclass.kubernetes.io/is-default-class: "false"
   >    provisioner: csi.nutanix.com
   >    parameters:
   >      nfsServer: <your file server>
   >      nfsPath: /<your share name>
   >      storageType: NutanixFiles
   >    reclaimPolicy: Delete or Retain
   >    volumeBindingMode: Immediate
   >    ```

2. Apply the manifest, and check if a new storageclass is created
   <details>
   <summary>Answer</summary>
    
   > 1. Launch command `kubectl apply -f <your manifest file>`
   > 1. Then launch command `kubectl get storageclass`<br>You shloud have this output :
   >    ```
   >    NAME                             PROVISIONER       RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
   >    default-storageclass (default)   csi.nutanix.com   Delete          Immediate           true                   6d
   >    nutanix-files-static             csi.nutanix.com   Delete          Immediate           false                  2m6s
   >    ```

## Create a new storage class named nutanix-files-dynamic

1. First, you'll need to create a secret named pe-files-dynamic-secret. Create a manifest defining the secret and apply it.
   <details>
   <summary>Answer</summary>

   > 1. Create a manifest to deploy :
   >    ```yaml
   >    ---
   >    apiVersion: v1
   >    kind: Secret
   >    metadata:
   >      name: pe-files-dynamic-secret
   >      namespace: kube-system
   >    stringData:
   >      # Provide Nutanix Prism Element credentials which is a default UI credential separated by colon in "key:".
   >      # Provide Nutanix File Server credentials which is a REST API user created on File server UI separated by colon in "files-key:".
   >      key: "<PE IP or FQDN>:9440:<PE username>:<PE password>"
   >      files-key: "<your-file-server>:<file-server rest api user>:<fileserver rest api password>"
   >    ```

2. You'll need to create a dedicated storageclass named nutanix-files-dynamic. Create a manifest defining the secret and apply it.
   <details>
   <summary>Answer</summary>

   > 1. Create a manifest to deploy :
   >    ```yaml
   >    ---
   >    apiVersion: storage.k8s.io/v1
   >    kind: StorageClass
   >    metadata:
   >      name: nutanix-files-dynamic
   >    parameters:
   >      csi.storage.k8s.io/node-publish-secret-name: pe-files-dynamic-secret
   >      csi.storage.k8s.io/node-publish-secret-namespace: kube-system
   >      csi.storage.k8s.io/controller-expand-secret-name: pe-files-dynamic-secret
   >      csi.storage.k8s.io/controller-expand-secret-namespace: kube-system
   >      csi.storage.k8s.io/provisioner-secret-name: pe-files-dynamic-secret
   >      csi.storage.k8s.io/provisioner-secret-namespace: kube-system
   >      storageType: NutanixFiles
   >      squashType: root-squash
   >      nfsServerName: <your file server>
   >      dynamicProv: ENABLED
   >    provisioner: csi.nutanix.com
   >    reclaimPolicy: Delete
   >    volumeBindingMode: Immediate
   >    allowVolumeExpansion: true
   >    ```

3. Apply the manifest, and check if a new storageclass is created
   <details>
   <summary>Answer</summary>
    
   > 1. Launch command `kubectl apply -f <your manifest file>`
   > 1. Then launch command `kubectl get storageclass`<br>You shloud have this output :
   >    ```
   >    NAME                             PROVISIONER       RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
   >    default-storageclass (default)   csi.nutanix.com   Delete          Immediate           true                   6d
   >    nutanix-files-dynamic            csi.nutanix.com   Delete          Immediate           true                   2s
   >    nutanix-files-static             csi.nutanix.com   Delete          Immediate           false                  3m3s
   >    ```

   </details><br>

## Create Stateful Application with ReplicaSet, with a persistent volume using Nutanix Files Static StorageClass

1. Look at these page. and use the replicaset manifest example to test the Nutanix Files deployment. : [link](https://portal.nutanix.com/page/documents/details?targetId=CSI-Volume-Driver-v2_6:csi-csi-plugin-deploy-pvc-files-replicaset-t.html). Name your replicaset nginx-replicaset-on-nutanix-files-static
1. Create a manifest to deploy :

   - a replicaset named replicaset-my-app-files-static
   - a 3GB pvc using the storage class nutanix-files-static, in ReadWriteMany (RWX) mode
     - this volume will be mounted in /usr/share/nginx/html in the pod

1. Test the PVC has been created, and has a Bound status.
   <details>
   <summary>Answer</summary>

   > 1. Create a manifest to deploy :
   >    ```yaml
   >    ---
   >    apiVersion: v1
   >    kind: PersistentVolumeClaim
   >    metadata:
   >      name: pvc-my-app-files-static
   >      labels:
   >        app: my-app-files-static
   >    spec:
   >      storageClassName: nutanix-files-static
   >      accessModes:
   >        - ReadWriteMany
   >      resources:
   >        requests:
   >          storage: 3Gi
   >    ---
   >    apiVersion: apps/v1
   >    kind: ReplicaSet
   >    metadata:
   >      name: replicaset-my-app-files-static
   >      labels:
   >        app: my-app-files-static
   >    spec:
   >      replicas: 5
   >      selector:
   >        matchLabels:
   >          app: my-app-files-static
   >      template:
   >        metadata:
   >          labels:
   >            app: my-app-files-static
   >        spec:
   >          volumes:
   >            - name: pv-my-app-files-static
   >              persistentVolumeClaim:
   >                claimName: pvc-my-app-files-static
   >          containers:
   >            - name: my-app-files-static
   >              image: gautierleblanc/nke-labs:latest
   >              ports:
   >                - containerPort: 80
   >                  name: "http-server"
   >              volumeMounts:
   >                - mountPath: "/data"
   >                  name: pv-my-app-files-static
   >    ```
   > 2. Launch command `kubectl apply -f <your manifest file>`
   > 3. Test the PVC is in bound mode `kubectl get pvc`
   >    ```
   >    NAME                       STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS           AGE
   >    pvc-my-app-files-static    Bound    pvc-75a2b351-81a6-4fc7-a24c-a44e03fe8607   3Gi        RWX            nutanix-files-static   6m30s
   >    ```

## Create Stateful Application with ReplicaSet, with a persistent volume using Nutanix Files Dynamic StorageClass

1. Look at these page. and use the replicaset manifest example to test the Nutanix Files deployment. : [link](https://portal.nutanix.com/page/documents/details?targetId=CSI-Volume-Driver-v2_6:csi-csi-plugin-deploy-pvc-files-replicaset-t.html). Name your replicaset nginx-replicaset-on-nutanix-files-static
1. Create a manifest to deploy :

   - a replicaset named replicaset-my-app-files-dynamic
   - a 3GB pvc using the storage class nutanix-files-dynamic, in ReadWriteMany (RWX) mode
     - this volume will be mounted in /data in the pod

1. Test the PVC has been created, and has a Bound status.
   <details>
   <summary>Answer</summary>

   > 1. Create a manifest to deploy :
   >    ```yaml
   >    ---
   >    apiVersion: v1
   >    kind: PersistentVolumeClaim
   >    metadata:
   >      name: pvc-my-app-files-dynamic
   >      labels:
   >        app: my-app-files-dynamic
   >    spec:
   >      storageClassName: nutanix-files-dynamic
   >      accessModes:
   >        - ReadWriteMany
   >      resources:
   >        requests:
   >          storage: 3Gi
   >    ---
   >    apiVersion: apps/v1
   >    kind: ReplicaSet
   >    metadata:
   >      name: my-app-files-dynamic-replicaset-on-nutanix-files-dynamic
   >      labels:
   >        app: my-app-files-dynamic
   >    spec:
   >      replicas: 5
   >      selector:
   >        matchLabels:
   >          app: my-app-files-dynamic
   >      template:
   >        metadata:
   >          labels:
   >            app: my-app-files-dynamic
   >        spec:
   >          volumes:
   >            - name: pv-my-app-files-dynamic
   >              persistentVolumeClaim:
   >                claimName: pvc-my-app-files-dynamic
   >          containers:
   >            - name: my-app-files-dynamic
   >              image: gautierleblanc/nke-labs:latest
   >              ports:
   >                - containerPort: 80
   >                  name: "http-server"
   >              volumeMounts:
   >                - mountPath: "/data"
   >                  name: pv-my-app-files-dynamic
   >    ```
   > 2. Launch command `kubectl apply -f <your manifest file>`
   > 3. Test the PVC is in bound mode `kubectl get pvc`
   >    ```
   >    NAME                        STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS            AGE
   >    pvc-my-app-files-dynamic    Bound    pvc-ec98ee67-5454-4a7f-b9ab-2e0d92f40d89   3Gi        RWX            nutanix-files-dynamic   44s
   >    pvc-my-app-files-static     Bound    pvc-75a2b351-81a6-4fc7-a24c-a44e03fe8607   3Gi        RWX            nutanix-files-static    13m
   >    ```
   > 4. Under the Prism Central interface, the task list should show a couple of export task that as been triggered by the Nutanix CSI Files, when using Dynamic Provisionning mode.
   > 5. In the main menu, select `Files` / `File Server`/ Click on the configured file server`<br>![Image 1](images/1.png?raw=true)
   > 6. On the `Shares` Tab, you should see a newly created share named `pvc-...`<br>![Image 2](images/2.png?raw=true)

# Takeover

Nutanix CSI configured with file can create an mount static or dynamic share.
