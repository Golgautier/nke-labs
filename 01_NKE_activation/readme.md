_Difficulty: 1/5_

# Summary:

This exercise will teach you how to deploy activate Nutanix Kubernetes Engine on a Nutanix Cluster.

# Prerequisites

- A Nutanix cluster
- A Prism Central (>PC.2023.1.0.1), connected to his hosting cluster
- Admin credentials for this Prism Central

Note that this exercise can be done only once per Prism Central.

# Exercise

1. Enable Marketplace
   <details>
   <summary>Answer</summary>

   > 1. Connect on PC with admin user
   > 1. In the main menu, select `Apps and Marketplace` > <br>![Image 1](images/1.png?raw=true)
   > 1. Click on `Enable Marketplace` link
   >    <br>![Image 2](images/2.png?raw=true)
   > 1. Click on `Enable Marketplace` blue button
   >    <br>![Image 3](images/3.png?raw=true)
   > 1. Wait for few minutes (approx 8/10 mn)
   > 1. After Markeplace activation, the `get` button on the Marketplace tiles should not be greyed out anymore.
   > <br>![Image 4](images/4.png?raw=true)
   > </details><br>

1. Deploy NKE
   <details>
   <summary>Answer</summary>

   > 1. Click on `Get` button on the `Kubernetes Management` tile
   > 1. Click now on `Deploy` blue button
   > 1. Click on `View admin center`
   > 1. Click on `audit` tab
   >    <br>![Image 5](images/5.png?raw=true)
   > 1. You can expand `Create` object and inspect deployment workflow.
   > 1. When all tasks are finshed (and green), you app will get `running` state
   >    <br>![Image 6](images/6.png?raw=true)

   </details><br>

1. It is now recommended to update NKE to the latest version. Do it.
   <details>
   <summary>Answer</summary>

   > 1. In the main menu, select `Admin Center` > <br>![Image 7](images/7.png?raw=true)
   > 1. In the left menu, select "LCM"
   >    <br>![Image 8](images/8.png?raw=true)
   > 1. Select `Inventory` tab
   > 1. Now click on `Perform inventory` blue button
   > 1. Wait for end of inventory (Can take a while)
   > 1. Click on `return to inventory`
   > 1. Click on `Updates` tab
   > 1. You should see a line `Nutanix Kubernetes Engine` in the list
   >    <br>![Image 9](images/9.png?raw=true)
   > 1. Check the box, and click on `View Upgrade Plan` blue button
   > 1. On the next page, click on `Apply 1 Update` blue button
   > 1. Wait for end of the update
   >    - NKE GUI is unavailable during the upgrade, but NKE clusters already deployed are still available.

   </details>

# Takeover

As all Nutanix services, NKE is very simple to activate : 1 click on a button, that's it.
