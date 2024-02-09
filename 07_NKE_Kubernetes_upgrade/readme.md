_Difficulty: 1/5_

# Summary:

This exercise will teach you how to upgrade an existing NKE cluster to a newest Kubernetes version

# Prerequisites

- A Nutanix cluster with a kubernetes cluster deployed with NKE, with an older Kubernetes version
- `kubectl` command must be installed on your laptop.

# Presentation / Context

Nutanix NKE allows to automate OS and Kubernetes upgrade in One-Click.

It allows to quickly and safely upgrade an existing cluster in a couple of minutes, automatically.

# Exercise

## Upgrade NKE to a newer version

1. Go on NKE page in Prism
   <details>
   <summary>Answer</summary>

   > 1. Connect on Prism with you account
   > 1. In the main menu, select `Kubernetes Management` > <br>![Image 1](images/1.png?raw=true)

1. Click on your existing cluster, and upgrade it
   <details>
   <summary>Answer</summary>

   > 1. Click on your cluster
   > 1. Click on More button / Upgrade Kubernetes![Image 2](images/2.png?raw=true)
   > 1. Select a Kubernetes Version, and click Upgrade<br>![Image 3](images/2.png?raw=true)
   > 1. The cluster will start its upgrade process. You can click on the button <br>![Image 4](images/3.png?raw=true)

1. Check the node upgrade process with kubectl
   <details>
   <summary>Answer</summary>

   > 1. Use kubectl command tool continuously show the node status<br>
     `kubectl get nodes -w`

# Takeover

Nutanix NKE allows you to easily and quickly upgrade your kubernetes cluster 