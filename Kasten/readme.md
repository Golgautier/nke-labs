_Difficulty: 2/5_

# Summary:

This exercise will teach you how to use backup solution, like Kasten, to backup and restore application running on NKE Backup. Backup data will be stored on Nutanix Object.

# Prerequisites

- A Nutanix cluster with a kubernetes cluster deployed with NKE
- A Prism account authorized to deploy NKE clusters
- Nutanix Object cluster up and running

# Exercise

In order to deploy the Kasten backup solution, we'll mainly used the official [Kasten documentation](https://docs.kasten.io/latest/install/other/other.html) to deploy it.

1. First, deploy a basic application, which will user nginx image, and have a PVC stored on the default storageclass. It has to be deployed in the new namespace name demo-backup-kaster
   <details>
   <summary>Answer</summary>

   > 1. Create a manifest to deploy :
   >    ```yaml
   >    apiVersion: v1
   >    kind: Namespace
   >    metadata:
   >      name: demo-backup-kasten
   >    ---
   >    apiVersion: v1
   >    kind: PersistentVolumeClaim
   >    metadata:
   >      name: pvc-demo-backup-kasten
   >      namespace: demo-backup-kasten
   >    spec:
   >      accessModes:
   >        - ReadWriteOnce
   >      resources:
   >        requests:
   >          storage: 10Gi
   >    ---
   >    apiVersion: v1
   >    kind: Pod
   >    metadata:
   >      name: demo-backup-kasten
   >      namespace: demo-backup-kasten
   >    spec:
   >      containers:
   >        - name: demo-backup-kasten
   >          image: gautierleblanc/nke-labs:latest
   >          volumeMounts:
   >            - mountPath: /data
   >              name: pv-demo-backup-kasten
   >      volumes:
   >        - name: pv-demo-backup-kasten
   >          persistentVolumeClaim:
   >            claimName: pvc-demo-backup-kasten
   >    ```

2. Apply the manifest, and check if the new PVC is bound in the correct namespace
   <details>
   <summary>Answer</summary>
    
   > 1. Launch command `kubectl apply -f <your manifest file>`
   > 1. Then launch command `kubectl get pvc -n demo-backup-kasten`<br>You shloud have this output :
   >    ```
   >    NAME                     STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS           AGE
   >    pvc-demo-backup-kasten   Bound    pvc-4fd94c9b-110c-4619-8f73-997ef1957da6   10Gi       RWO            default-storageclass   12s
   >    ```

3. Now it's time to deploy Kasten. Based on the official Kasten documentation, ensure the Kasten prerequisite are met.
   <details>
   <summary>Answer</summary>

   > 1. Add helm kasten repo
   >    `helm repo add kasten https://charts.kasten.io/`
   > 2. Create a dedicated kasten-io namespace
   >    `kubectl create namespace kasten-io`

4. By default, not VolumeSnapshotClass are created with NKE. Setup a VolumeSnapshotClass which will be used by Kasten. The annotions `k10.kasten.io/is-snapshot-class: "true"` need to be set on the storageclass.
   <details>
   <summary>Answer</summary>

   > 1. Retrieve the name of the ntnx-secret which has been dynamicaly created by NKE Installer `k get secret -n kube-system`. Copy the name of the secret starting with `ntnx-secret-``
   > 2. Create a manifest to define the VolumeSnapshotClass. Ensure to write the correct value for the `csi.storage.k8s.io/snapshotter-secret-name` parameter, by pasting the secret name you just copied.
   >    ```yaml
   >    apiVersion: snapshot.storage.k8s.io/v1
   >    kind: VolumeSnapshotClass
   >    metadata:
   >      name: acs-abs-snapshot-class
   >      annotations:
   >        k10.kasten.io/is-snapshot-class: "true"
   >    driver: csi.nutanix.com
   >    parameters:
   >      storageType: NutanixVolumes
   >      csi.storage.k8s.io/snapshotter-secret-name: ntnx-secret-<auto generated UUID>
   >      csi.storage.k8s.io/snapshotter-secret-namespace: kube-system
   >    deletionPolicy: Delete
   >    ```

5. Apply the manifest, and check if the new VolumeSnapshotClass is created
   <details>
   <summary>Answer</summary>
    
   > 1. Launch command `kubectl apply -f <your manifest file>`
   > 1. Then launch command `kubectl get volumesnapshotclass`<br>You shloud have this output :
   >    ```
   >    NAME                     DRIVER            DELETIONPOLICY   AGE
   >    acs-abs-snapshot-class   csi.nutanix.com   Delete           66s
   >    ```

6. Deploy kasten with helm
   <details>
   <summary>Answer</summary>

   > 1. Use helm install command to deploy kasten. It can take a couple of seconds to have an output saying kasten as been deployed.
   >    `helm install k10 kasten/k10 --namespace=kasten-io`
   > 2. Once kasten deploy, you should use kubectl port-foward command to get access to Kasten Dashboard `kubectl --namespace kasten-io port-forward service/gateway 8080:8000`
   > 3. From you laptop, you should be able to access Kasten dashboard from a Web Browser at this address http://127.0.0.1:8080/k10/#/
   > 4. Kasten is now deployed, and ready to be configured. Keep this window Open.

7. Create Object Bucket and access Key to store Kasten backup.
   <details>
   <summary>Answer</summary>

   > 1. In another tab, go under the Prism Central interface, in the main menu, select `Objects`
   > 2. After clicking on `Access Keys` left menu item, click on `+ Add People`
   > 3. Select `Add people not in a directory service`, enter an e-mail address and name / Next / Click on Generate Key (save this information somewhere, as we'll need it in a couple of steps)<br>![Image 1](images/1.png?raw=true)
   > 4. Click on `Object Stores` menu on left, click the Nutanix Object store where you want to store the Kasten backup. Go on the `Buckets` Tab
   > 5. Click on `Create Bucket` button. It will open a popup. Name your bucket `k10-backup` / Click Create
   > 6. You'll see you newly created bucket <br>![Image 2](images/2.png?raw=true)
   > 7. Click on the bucket. On the `User Access` tab, click `Edit User access`. Search for user `kasten@ntnxlab.local` et set `Full Access` permissions. Click save. <br>![Image 3](images/3.png?raw=true)
   > 8. You're now ready to use Nutanix Object to store Kasten backup

8. Configure Kasten to backup data to Nutanix Object
   <details>
   <summary>Answer</summary>

   > 1. Go back to the Kasten Dashboard. Under Profiles / Location menu, click on `New Profile`. Under Profile Name, write `nutanix-object`, and select `S3 Compatible`.
   > 2. Paste S3 Access Key and S3 Secret which was generated by Nutanix Object. For Endpoint, enter Nutanix Object FQDN or IP Address, and check `Skip certificate chain and hostname verification` if needed. Provide bucket name `k10-backup`.
   > 3. Once clicked on save, you should see status `Valid`. <br>![Image 4](images/4.png?raw=true)

9. Configure Kasten Policy to backup `demo-backup-kasten` to Nutanix Object destination
   <details>
   <summary>Answer</summary>

   > 1. Go back to the Kasten Dashboard. Under Policies / Policies, click on `Create New Policy`. Under Name, write `silver-sla`
   > 2. Select an hourly Backup Frequency. Keep the snapshot retention by default. Enable Backups via Snapshot Exports, and set Export Frequency as `Every snapshot`. Select the Export Location Profile as `nutanix-object`, by using the same retention schedule.
   > 3. Select the Application `By Name`and select `demo-backup-kasten` in the list.<br>![Image 5](images/5.png?raw=true)
   > 4. Select `nutanix-object` for Location Profile for Kanister Actions / Click `Create Policy`
   > 5. Once the Policy created, click on `Run once` on the right side / `Yes continue`. You should yee on the Dashboard the policy running. <br>![Image 6](images/6.png?raw=true)
   > 6. In another tab, go under the Prism Central interface, in the main menu, select `Objects`
   > 7. Click on `Object Stores` menu on left, click the Nutanix Object store where you store the Kasten backup. Go on the `Buckets` Tab
   > 8. On the backup named `k10-backup` you should see a number of objects greather than 0. <br>![Image 7](images/7.png?raw=true)
   > 9. If you click on the bucket name `k10-kasten` and go on Performance / Select `Show metrics in the last 1 hour`, you should see some activity on the graph.<br>![Image 8](images/8.png?raw=true)
   > 10. Your application data are now backuped on the Nutanix Object with Kasten integration.

# Takeover

Nutanix Object can be used by to securly store Kubernetes data manage with backup solution such as Kasten, Trilio, etc...
