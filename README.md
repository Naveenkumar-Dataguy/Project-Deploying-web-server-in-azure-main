# Azure Infrastructure Operations Project: Deploying a scalable IaaS web server in Azure

## Introduction

### In this project we are deploying a scalable web server with load balancer.

The project will consist of the following main steps :-

1. Creating a tagging-policy
2. Creating a Packer image
3. Creating a Terraform templet
4. Deployinf the infrastructure 
5. Creating a Readme file

## Getting Started 

1. You need understanding of Terraform commands
2. You need Understanding of Packer commands
3. You need Understanding of Azure CLI 

## Dependencies

1. Create an Azure Account
2. Install the Azure command line interface
3. Install Packer
4. Install Terraform

## Instructions 

### Creating a tagging-policy

We will 1st create a policy that will allow creation of only those resources which has tags.

To create this policy we will use CLI command 

```bash
AZ Policy 
```
We will create our policy in "json" file . For this project i have created policy name "tagging-policy"
Now , To deploy this policy in azure we use below codes.

```python
az policy definition create --name "tagging-policy" --display-name "Allow tagged resource creation " --description "this policy allow the creation of only tagged resources" --rules tagging-policy.json --mode Indexed
az policy assignment create --name "tagging-policy creation " --policy "tagging-policy"
```
Once the policy is deployed we can check the policy using below code

```bash
AZ policy assignment list
```

In below image we can see the policy that i have deployed

![tagging policy details](https://user-images.githubusercontent.com/104189782/188860168-adcfa52d-517d-4e30-9755-db96dea09738.png)

### Creating Packer image 

For this project we will create a ubuntu server 18.04-LTS VM image for deployment 

We will follow below setps to create packer image 

#### Providing authorization 

Packer need authorization to create resource in azure . Instead of providing credential directly we will use service princple for authorization

We can collect client id , subscription id , tenant id and client secreat from azure then use below commnds to export this SP and save to root file.

```bash
export ARM_SUBSCRIPTION_ID="XXXXXXX"
export ARM_TENANT_ID="XXXXXXX"
export ARM_CLIENT_ID="XXXXXX"
export ARM_CLIENT_SECRET="XXXXXX"
```
Use below command to save to root file 

```bash
. ~/.bashrc
```
Check if its Saved 

```bash
printenv | grep ^ARM*
```

#### Creating "json" image file 

We will write code for creating image in "json" format . Server.json is my image file name. 

It contain 3 main part 

Variables  --- Where we declare variables and authorization codes 

![variables ](https://user-images.githubusercontent.com/104189782/188865621-dc0fc6a7-7ceb-45e3-9577-7f4f26283fab.png)

Builders --- Where we write configurations for the VM

![builders](https://user-images.githubusercontent.com/104189782/188865575-d2ea3637-df03-4412-a764-3a03169c2117.png)

provisioners -- Where we write codes about what to do after image is deployed

![provisioners](https://user-images.githubusercontent.com/104189782/188865650-8896f05d-c646-4f44-bb2f-52d8d97386dc.png)


#### Deploying server.json  file 

Below commands are use to deploy the server.json file to create a image resource.

```bash
packer validate server.json
packer build server.json
```

Once the image is deployed you can see it in the resource section.

![resource deleted](https://user-images.githubusercontent.com/104189782/188866792-de95fb81-1a64-4b28-a0c7-a8ca1740ae79.png)

### Creating terraform templetes 

We will follow below steps to create packer templetes 

#### Providing authorization 

Terraform need authorization to create resource in azure . Instead of providing credential directly we will use service princple for authorization

We can collect client id , subscription id , tenant id and client secreat from azure then use below commnds to export this SP and save to root file.

```bash
export ARM_SUBSCRIPTION_ID="XXXXXXX"
export ARM_TENANT_ID="XXXXXXX"
export ARM_CLIENT_ID="XXXXXX"
export ARM_CLIENT_SECRET="XXXXXX"
```
Use below command to save to root file 

```bash
. ~/.bashrc
```
Check if its Saved 

```bash
printenv | grep ^ARM*
```

#### Creating templets file main.tf and vars.tf 

main.tf file conatain all the codes for creating templetes 

![main tf](https://user-images.githubusercontent.com/104189782/188868587-efc69978-caf9-4444-b496-bde257fe9810.png)

vars.tf file contain the details and default values of variables use in the main.tf file 

It contains 3 optional blocks 

1 Descriptions -- Here we describe about the variable 

2 Type -- Variable type like string numeric 

3 Default -- the Default value variable should use 

![vars tf](https://user-images.githubusercontent.com/104189782/188868619-b508c199-1568-4c7c-92a3-6ee6e2526f12.png)

#### Deploying Infrastructure 

We can use below commands to deploy the terraform templetes 

Initialize terraform

```bash
terraform init
```

Validate terraform files 

```bash
terraform validate
```

Creating a plan and saving it to a file 

```bash
terraform plan -out solution.plan
```
Applying the plan and creating infrastructure

```bash
terraform apply "solution.plan"
```

#### Created infrastrucutre 

![VM deployed](https://user-images.githubusercontent.com/104189782/188870926-0659865d-a1bd-44ff-829d-61ba4f36b5c0.png)



#### Deleting Infrastructure 

to delete all the mananged infrastrucutre 

```bash
terraform destroy
```


































