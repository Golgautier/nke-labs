*Difficulty: 2/5*

# Summary:

This exercise will teach you how to create a new admin account on a k8s cluster. It will provide to you a kubeconfig file valid more than 24h.

Just be careful about security leak it represents.

# Prerequisites
* A NKE cluster ready to use with kubeconfig to connect on as admin.
* An admin account on Prism Central

# Presentation / Context

There are multiple methods to do this task :
* Create a service account and a rolebinding 
    - Can be discussed. Service account are not related to users in a perfect world.
* Create a new user with a signed certificate
    - A bit complex and can be a mess to configure, regarding certificate generation.
* Use an external identity provider (dexidp from Dex, infra from infrahq, etc.)
    - Interesting an clean way. A bit heavy just for a simple admin access, but can be the good option for multiple accounts to connect on you k8s cluster
* Use user provided by PRISM, and apply a role to this user
    - As Prism act as IDP for NKE cluster, we just have to create role binding and that's it.

We will only use the last option in this exercise...

If you strugglle during this lab, you will find all needed documentation here : [Kubernetes RBAC](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)

# Exercise
    
1. Create local account on nutanix Cluster (could be an AD user if an AD is connected to Prism Central)
    <details>
    <summary>Answer</summary>
    
    >1. Connect on PC with admin user
    >1. In the main menu, select `Admin Center`
    >1. In the left menu, select `IAM`
    >1. Click on tab `Settings > Local User Management`
    >1. Click on button `New User`
    >1. Fill form :
    >       * Username : `<initials>_user`
    >       * Complete first name, last name & email
    >       * Password : `nx2Tech123!`
    >1. Save the user
    >1. He should appear as simple viewer in the list
    </details><br>

1. In another browser (or a private session in your browser), connect on PC with your new user
1. Go on NKE Interface
1. Select your NKE cluster, download kubeconfig on your laptop
1. Open the kubeconfig file, get the user token and decode it on https://jwt.io/
    * What is your user ? What is his role ? 
        
        <details>
        <summary>Answer</summary>
        
        >You should see multiple information. Your user should be obviously `username:<initials>_user`
        </details><br>

1. Try to use this kubeconfig to list pods.

    <details>
    <summary>Answer</summary>
    
    > * Launch command `kubectl get pods --kubeconfig <path to your kubeconfig file> -A`
    > * You should see that your user does not have rights currently

    </details><br>

1. Look [here](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#user-facing-roles) to get role dedicated to be admin **at cluster level**

    <details>
    <summary>Answer</summary>
    
    > * expected role is `cluster-admin`
    </details><br>

1. Create a manifest to bind this user and cluster admin role
    * You can take a look at this [page](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#rolebinding-and-clusterrolebinding) to get some help

        <details>
        <summary>Answer</summary>

        >```yaml
        > apiVersion: rbac.authorization.k8s.io/v1
        > kind: ClusterRoleBinding
        > metadata:
        >   name: gl-user-admin
        > subjects:
        > - kind: User
        >   name: <initials>_user
        >   apiGroup: rbac.authorization.k8s.io
        > roleRef:
        >   kind: ClusterRole
        >   name: cluster-admin
        >   apiGroup: rbac.authorization.k8s.io
        >```

        </details><br>

1. Apply it

    <details>
    <summary>Answer</summary>
    
    > * Launch command `kubectl apply -f <your manifest>`
    </details><br>

1. Get kubeconfig file with kubctl karbon plugin and your local account, and list all pods

    <details>
    <summary>Answer</summary>
    
    > 1. Launch command `kubectl karbon login --server <PC address> --user <your new user> --insecure --force`
    > 1. Select your cluster and validate
    > 1. Launch command `kubectl get pods --kubeconfig <path to your kubeconfig file> -A`
    >    * You should see all cluster pods

    </details><br>


# Takeover

If you want to create a new admin user, with no kubeconfig expiration time, it is possible with several method. The simplest and clean way to proceed is using Prism IDP and just assign cluster role `cluster-admin` to this local (or AD) user.