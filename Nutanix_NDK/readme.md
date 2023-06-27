*Difficulty: 4/5*

# Summary:

This exercise will teach you how use Nutanix Data-services for Kubernetes in Async mode


# Prerequisites
* 2 NKE cluster ready to use with kubeconfig to connect on as admin.
* NDK installed on these cluster (this is not a part of this lab)

# Presentation / Context

***NDK is still in EA mode, features may change for GA***

NDK is a Nutanix solution to protect kubernetes assets and data, on a single cluster (local snaphots) or a dual cluster solution (snapshots and replication).

All NDB interaction will be done with Custom ressources, created during NDK installation. You can find CR samples [here](../Manifest_models/ndk/)

# Exercise
    
1. Create a namespace `ns-<initials>` on source clustet
    <details>
    <summary>Answer</summary>
    
    > * Launch command `kubectl create ns <your namespace name>`

    </details><br>

1. Create an manifest to deploy a (not too) 'simple' app :
    * Create a deployement with one pod
    * image to use: `mysql:8.0`
    * Create a service to access to this pod
    * Create a secret with key `password` and a value `Nutanix/4u`
        * This password will be presented as an environment value `MYSQL_ROOT_PASSWORD` to your pod
    * A PVC will be created and mounted in `/var/lib/mysql` in this pod
    * Container is listening on port 3306

        <details>
        <summary>Answer</summary>
        
        > ```yaml
        > apiVersion: v1
        > kind: Secret
        > metadata:
        > name: mysql-password
        > type: opaque
        > stringData:
        > password: "Nutanix/4u"
        > ---
        > apiVersion: v1
        > kind: Service
        > metadata:
        > name: mysql-service
        > labels:
        >     app: mysql
        > spec:
        > ports:
        >     - port: 3306
        > selector:
        >     app: mysql
        >     tier: db
        > ---
        > apiVersion: v1
        > kind: PersistentVolumeClaim
        > metadata:
        > name: mysql-pv-claim
        > labels:
        >     app: mysql
        > spec:
        > accessModes:
        >     - ReadWriteOnce
        > resources:
        >     requests:
        >     storage: 2Gi
        > ---
        > apiVersion: apps/v1
        > kind: Deployment
        > metadata:
        > name: mysql-deployment
        > labels:
        >     app: mysql
        > spec:
        > selector:
        >     matchLabels:
        >     app: mysql
        >     tier: db
        > strategy:
        >     type: Recreate
        > template:
        >     metadata:
        >     labels:
        >         app: mysql
        >         tier: db
        >     spec:
        >     containers:
        >     - image: mysql:8.0
        >         name: mysql
        >         env:
        >         - name: MYSQL_ROOT_PASSWORD
        >         valueFrom:
        >             secretKeyRef:
        >             name: mysql-password
        >             key: password
        >         ports:
        >         - containerPort: 3306
        >         name: mysql
        >         volumeMounts:
        >         - name: mysql-persistent-storage
        >         mountPath: /var/lib/mysql
        >     volumes:
        >     - name: mysql-persistent-storage
        >         persistentVolumeClaim:
        >         claimName: mysql-pv-claim
        >```

        </details><br>

1. Apply it in your manifest and wait for deployment
1. Connect on your pod and create a file with some content un /var/lib/mysql/
1. Create a `NDK Application` using dedicated CRD, in the same namespace

    <details>
    <summary>Answer</summary>
    
    > 1. Create this manifest
    >
    >    ```yaml
    >    apiVersion: dataservices.nutanix.com/v1alpha1
    >    kind: Application
    >    metadata:
    >        name: my-app
    >    spec:
    >        applicationSelector:
    >    ```
    >
    > 1. Apply it in your namespace
    > 1. Check it was deployed with command `kubectl get application -n <your namespace>`
    </details><br>

1. Create an `ApplicationSnapshot` from your application

    <details>
    <summary>Answer</summary>
    
    > 1. Create this manifest
    >
    >    ```yaml
    >    apiVersion: dataservices.nutanix.com/v1alpha1
    >    kind: ApplicationSnapshot
    >    metadata:
    >       name: my-app-snap
    >    spec:
    >       source:
    >          applicationRef:
    >             name: my-app
    >             namespace: <namespace of the app>
    >    ```
    >
    > 1. Apply it in your namespace
    > 1. Check it was snapshotted with command `kubectl get applicationsnapshot -n <your namespace>`
    > 1. Wait for `READY` state becomes true (restart command regularly)
    </details><br>

1. Delete you secret, your PVC and your PV
1. Restore your snapshot

    <details>
    <summary>Answer</summary>
    
    > 1. Create this manifest
    >
    >    ```yaml
    >    apiVersion: dataservices.nutanix.com/v1alpha1
    >    kind: ApplicationRestoreRequest
    >    metadata:
    >      name: my-app-manual-snap-restore
    >    spec:
    >      applicationSnapshotName: my-app-snap
    >    ```
    >
    > 1. Apply it in your namespace
    > 1. Check it was deployed with command `kubectl get ApplicationRestoreRequest -n <your namespace>`
    > 1. Your deletes asset should be back now
    </details><br>

1. Create a manifest to to a regular snapshot (each 10mn, retain 24 snaps), with `SchedulePolicy`, `ProtectionPlan` and `AppProtectionPlan` CR

    <details>
    <summary>Answer</summary>
    
    > 1. Create this manifest
    >
    >    ```yaml
    >    apiVersion: dataservices.nutanix.com/v1alpha1
    >    kind: SchedulePolicy
    >    metadata:
    >      name: schedulepolicy-each-10mn
    >    spec:
    >      interval:
    >        minutes: 10
    >    ---
    >    apiVersion: dataservices.nutanix.com/v1alpha1
    >    kind: ProtectionPlan
    >    metadata:
    >      name: my-app-pplan
    >    spec:
    >      snapshotPolicies:
    >        - retentionPolicy:
    >            retain: 24
    >          schedulePolicyName: schedulepolicy-each-10mn
    >      suspend: false
    >    ---
    >    apiVersion: dataservices.nutanix.com/v1alpha1
    >    kind: AppProtectionPlan
    >    metadata:
    >      name: my-app-apppplan
    >    spec:
    >      suspend: false
    >      applicationNames:
    >        - my-app
    >      protectionPlanName: my-app-pplan
    >    ```
    >
    > 1. Apply it in your namespace
    > 1. Check it was deployed with command `kubectl get AppProtectionPlan -n <your namespace>`
    > 1. The `STATE`must be `Active` if everything is ok
    </details><br>

1. Use [this script](PrepareReplication.sh) to create pair-replication 
    * Usage `PrepareReplication.sh <kubeconfig of source cluster> <kubesoncifg of target cluster>`

1. Check if replication target is defined and ready
    <details>
    <summary>Answer</summary>
    
    > 1. Launch `kubectl get ReplicationTarget -n <your namespace>`
    > 1. Check if `STATE` is `Ready`
    </details><br>

1. Replicate your snapshot with dedicated custom resource
    <details>
    <summary>Answer</summary>
    
    > 1. Create this manifest
    >    ```yaml
    >    apiVersion: dataservices.nutanix.com/v1alpha1
    >    kind: ApplicationSnapshotReplication
    >    metadata:
    >      name: replicate-my-app-snap
    >    spec:
    >      applicationSnapshotName: my-app-snap
    >      replicationTargetName: target-k8s-cluster 
    >    ```
    > 1. Launch `kubectl get ApplicationSnapshotReplication -n <your namespace>` to check if replication is running
    > 1. Look at `PROGRESS` value... And wait for value 100 and `STATE` to value `true`
    </details><br>

1. Restore your app on remote cluster
    <details>
    <summary>Answer</summary>

    > 1. On remote cluster, launch `kubectl get ApplicationSnapshot -n <your namespace>` to check if snapshot has been replicated and is ready for the restore
    > 1. Crate manifest as for local restore, and apply it
    > 1. Confirm all application elements are now present in your namespace
    > 1. Connect on your pod and lokk files in `/var/lib/mysql`
    > 1. Your file with his content should be there

    </details><br>

# Takeover

NDK provides a simple and efficient way to protect k8s workloads, from k8s assets to PV. Everything is managed by custom resource your dev team can use easily.