_Difficulty: 2/5_

# Summary:

We often have this question : "Does Nutanix Flow support Kubernetes". Our answer is no, and it is not expected.

But it does not mean we are not able to restrict network exchanges between pods, as it is a feature available in most of the CNI.

# Prerequisites

- A NKE cluster ready to use, with Calico as CNI (Flannel won't work)
- An admin account for this cluster (with kubeconfig file)

# Exercise

1. Create 2 namespaces `namespace-1` and `namespace-2`

   <details>
   <summary>Answer</summary>

   > - `kubectl create namespace namespace-1`
   > - `kubectl create namespace namespace-2`

   </detail><br>

1. Deploy a pod and a service into each namespace :

   - Image : `gautierleblanc/nke-labs:latest`
   - A label : `app: my-app`

   <details>
   <summary>Answer</summary>

   > - Create this manifest file :
   >   ```yaml
   >   apiVersion: v1
   >   kind: Pod
   >   metadata:
   >   name: my-pod
   >   labels:
   >       app: my-app
   >   spec:
   >   containers:
   >   - name: my-cont
   >       image: gautierleblanc/nke-labs:latest
   >       imagePullPolicy: Always
   >   ---
   >   apiVersion: v1
   >   kind: Service
   >   metadata:
   >   name: my-svc
   >   spec:
   >   selector:
   >       app: my-app
   >   ports:
   >       - protocol: TCP
   >       port: 80
   >       targetPort: 80
   >   ```
   > - Apply it in the both namespaces with command `kubectl apply -f <manifest file> -n <your namespace>`

   </detail><br>

1. In a new terminal, connect on pod from namespace_1

   <details>
   <summary>Answer</summary>

   > - `kubectl exec <your pod name> -it -n <your namespace> -- bash`

   </detail><br>

1. Execute command `curl <service name>.namespace-2` and `curl www.google.com`
   <details>
   <summary>Answer</summary>

   > - You should have an answer, with html code... Content does not matter.

   </detail><br>

1. Create a manifest defining a NetworkPolicy, with these rules :

   - Block any request from outside to the pods of the namespace
   - Allow only output communication with port 80 on pods with labels `app: my-app`
   - Allow DNS request on kubernetes cluster

   <details>
   <summary>Answer</summary>

   > ```yaml
   > apiVersion: networking.k8s.io/v1
   > kind: NetworkPolicy
   > metadata:
   > name: my-networkpolicy
   > spec:
   > podSelector: {}
   > policyTypes:
   >    - Ingress
   >    - Egress
   > ingress: []
   > egress:
   >    - to:
   >        - namespaceSelector: {}
   >        podSelector:
   >            matchExpressions:
   >            - key: app
   >                operator: In
   >                values:
   >                - my-app
   >    ports:
   >        - port: 80
   >    - to:
   >        - namespaceSelector: {}
   >        podSelector:
   >            matchLabels:
   >            k8s-app: kube-dns
   >    ports:
   >        - port: 53
   >        protocol: UDP
   > ```

   </detail><br>

1. Apply it
   <details>
   <summary>Answer</summary>

   > - Launch command `kubectl apply -f <your manifest> -n <your 1st namespace>`

   </detail><br>

1. Relaunch your 2 `curl` commands in your pod from your 1st namespace.
1. What happened
   <details>
   <summary>Answer</summary>

   > The network policy has blocked all output connections except those to pods with label `my-app`.

   </detail><br>

# Takeover

Calico can provide NetworkPolicies, allowing to create filter between pods and other elements of the cluster or outside the cluster.
You can use [cilium editor](https://editor.cilium.io) to graphicaly design network policies and get corresponding code.
