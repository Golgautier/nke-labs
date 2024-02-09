_Difficulty: 2/5_

# Summary:

This exercise will teach you how to use an accound to download containers images from your registry.

In this exercise, we will to it for dockerhub.

# Prerequisites

- A Kubernetes cluster
- A docker account

# Exercise

1. Verify your account with docker cli
   <details>
   <summary>Answer</summary>

   > 1. Launch command `docker login`
   > 1. Answer to uername and password requests
   > 1. You should be successfuly logged in.

   > </details><br>

1. Create a secret with type `docker-registry` with CLI (look at kubernetes documentation)

   <details>
   <summary>Answer</summary>

   > 1. Launch command `kubectl create secret docker-registry <name of your secret> --docker-username=<your-name> --docker-password=<your-pword> -n <your namespace>`

   > </details><br>

1. Inspect yaml code from your secret with `kubectl get` command
   <details>
   <summary>Answer</summary>

   > 1. Launch command `kubectl get secret <your secret> -n <your namespace> --output=yaml`

   </details><br>

1. Create a simple manifest to create :

   - A pod with image `gautierleblanc/nke-labs:latest`
   - Using you secret for the download from dockerhub registry

   <details>
   <summary>Answer</summary>

   > 1. Create this manifest
   >    ```yaml
   >    apiVersion: v1
   >    kind: Pod
   >    metadata:
   >      name: my-test
   >    spec:
   >      containers:
   >        - name: private-reg-container
   >          image: gautierleblanc/nke-labs:latest
   >          imagePullPolicy: Always
   >      imagePullSecrets:
   >        - name: <your secret>
   >    ```
   > 1. Apply it with command `kubectl apply -f <your manifest> -n <your namespace>`
   > 1. Your pod will use your secret to download the image from the registry

   </details><br>

# Takeover

`ImagePullSecret` is a great way to use authentication on registries. It can be very usefull for test, when you use public registries limiting number of anonymous download per IP.
