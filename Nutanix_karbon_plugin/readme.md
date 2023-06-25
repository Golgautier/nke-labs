*Difficulty: 1/5*

# Summary:

This exercise will teach you how to use the kubectl karbon plugin to easily get NKE Cluster kubeconfig file.


# Prerequisites
* A Nutanix cluster with Prism Central with NKE activated
* A NKE cluster deployed
* A prism account with rights on NKE
* kubectl installed on your laptop
* Recommended : have `brew` installed on your laptop


# Presentation / Context

A great plugin exists for kubectl to directly connect on NKE on your Prism Central, and get information (and kubeconfig file) from your kubernetes cluster. It avoids to connect on Prism Central, just to get the kubeconfig file.


# Exercise

1. Install the karbon plugin from https://github.com/nutanix/kubectl-karbon
    <details>
    <summary>Answer</summary>
    
    >1. Look at the installation options on the github repo, and choose the prefered one
    >1. Install the plugin. For example `brew install nutanix/tap/kubectl-karbon`
    
    </details><br>
1. With this plugin, get kubeconfig file from your NKE cluster
    <details>
    <summary>Answer</summary>
    
    >1. Execute command `kubectl kargon login --server <Prism Central IP or FQDN> --username <your user>`
    >    
    >    Note: you can also use 
    >    
    >    * `--insecure` if your PC does not have valid certificate
    >    * `--force` if you already have an old kubeconfig file
    >    * `--kubie` to use kubeconfig file with [kubie](https://github.com/sbstp/kubie) 
    >
    >1. Enter your password when prompted
    >1. Select your cluster name with arrows up and down
    >
    >    Note: you can also enter some characters to filter cluster list
    >
    >1. Validate with 'Enter' key
    >1. Your kubeconfig file is now downloaded and applied (for this session shell only)

    </details><br>
1. Check connection with your kubernetes cluster
    <details>
    <summary>Answer</summary>
    
    >1. Launch any kubectl command. For example : `kubectl cluster-info`
    >1. If you get an answer, your are good !

    </details><br>

# Takeover

* Rather using NKE GUI to get kubeconfig file for your NKE cluster, you can use a kubectl plugin to get easily kubeconfig file.
