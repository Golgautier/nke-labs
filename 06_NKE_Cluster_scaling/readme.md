_Difficulty: 1/5_

# Summary:

This exercise will teach you how scale a NKE cluster with an additional node

# Prerequisites

- A Nutanix cluster with a kubernetes cluster deployed with NKE
- `kubectl` command must be installed on your laptop.

# Presentation / Context

Nutanix NKE allows to add and remove worker in an existing cluster.

It allows to simply adapt the Kubernetes worker needed to host the application workload. Similary, new node pool can be added with different capabilities such as GPU, memory or CPU.

# Exercise

## Add a worker to your existing node pool.

1. Go on NKE page in Prism
   <details>
   <summary>Answer</summary>

   > 1. Connect on Prism with you account
   > 1. In the main menu, select `Kubernetes Management` > <br>![Image 1](images/1.png?raw=true)

1. Add a new worker on your cluster, by scaling the existing node pool with 1 node
   <details>
   <summary>Answer</summary>

   > 1. Click on your cluster
   > 1. Click on Node Pools / Worker<br>![Image 2](images/2.png?raw=true)
   > 1. Select the node pool / Action / Resize <br>![Image 3](images/3.png?raw=true)
   > 1. Specify the total number of nodes you want in your node pool / Click resize <br>![Image 4](images/4.png?raw=true)

1. Check if the node is added to the pool, and move to a ready status
   <details>
   <summary>Answer</summary>

   > 1. Use kubectl command tool to get the node list. We'll use the -w option to watch it continuously and see the transition<br>
     `kubectl get nodes -w`

## Remove a worker from an existing node pool.

1. Remove a worker on your cluster, by scaling the existing node pool with 1 node
   <details>
   <summary>Answer</summary>

   > 1. Click on your cluster
   > 1. Click on Node Polls / Worker<br>![Image 2](images/2.png?raw=true)
   > 1. Select the node pool / Action / Resize <br>![Image 3](images/3.png?raw=true) <br>
     An other option would be to click on the delete button in front of a worker, which will downsize the pool size of 1 by removing it.
   > 1. Specify the total number of nodes you want in your node pool / Click resize <br>![Image 4](images/4.png?raw=true)

1. Check if the node is removed from the pool.
   <details>
   <summary>Answer</summary>

   > 1. Use kubectl command tool to get the node list. We'll use the -w option to watch it continously and see the transition<br>
     `kubectl get nodes -w`

# Takeover

Nutanix NKE allows you to quickly add and remove worker for an existing NKE Cluster, which will be ready in a couple of seconds.
