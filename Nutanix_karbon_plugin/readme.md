_Difficulty: 1/5_

# Summary:

This exercise will teach you how to use the kubectl karbon plugin to easily get NKE Cluster kubeconfig file without having to get it from the Prism Central GUI.

# Prerequisites

- A Nutanix cluster with Prism Central with NKE activated
- A NKE cluster deployed
- A prism account with rights on NKE
- kubectl installed on your laptop
- Recommended : have `brew` installed on your laptop

# Presentation / Context

A great plugin exists for kubectl to directly get the kubeconfig file from Prism Central to connect to your NKE cluster, without having to use the Prism Central web interface.

# Exercise

1. Install the karbon plugin from https://github.com/nutanix/kubectl-karbon
   <details>
   <summary>Answer</summary>

   > 1. Look at the installation options on the github repo, and choose the prefered one
   > 1. Install the plugin. For example `brew install nutanix/tap/kubectl-karbon`

   </details><br>

1. With this plugin, get kubeconfig file from your NKE cluster
   <details>
   <summary>Answer</summary>

   > 1. Execute command `kubectl karbon login --server <Prism Central IP or FQDN> --user <your user>`
   >
   >    Note: you can also use
   >
   >    - `--insecure` if your PC does not have valid certificate
   >    - `--force` if you already have an old kubeconfig file
   >    - `--kubie` to use kubeconfig file with [kubie](https://github.com/sbstp/kubie)
   >
   > 1. Enter your password when prompted
   > 1. Select your cluster name with arrows up and down
   >
   >    Note: you can also enter some characters to filter cluster list
   >
   > 1. Validate with 'Enter' key
   > 1. Your kubeconfig file is now downloaded and applied (for this session shell only)

   </details><br>

1. Check connection with your kubernetes cluster
   <details>
   <summary>Answer</summary>

   > 1. Launch any kubectl command. For example : `kubectl cluster-info`
   > 1. If you get an answer, your are good !

   </details><br>

# Takeover

- Rather than using NKE GUI to get kubeconfig file for your NKE cluster, you can use a kubectl plugin to easily get kubeconfig file.
