# Agent Trainer Deployer

Bash scripts for deploying [agent trainer](https://github.com/lopespm/agent-trainer) to a remote machine. More details about the training process [in this blogpost](http://lopespm.github.io/machine_learning/2016/10/06/deep-reinforcement-learning-racing-game.html)

Two flavors of deployments are available:
 - AWS EC2 instances, be it GPU enabled or not
 - Generic Linux remote machine, be it GPU enabled or not (only tested on CentOS7 as of now)

## Setup

Before proceeding, make sure the root folder's scripts are executable after cloning this repository to your local machine. Example of how to make the script executable: `$ chmod u+x aws_ec2_train_new.sh`

###AWS EC2

The scripts are built to support EBS external volumes by default, in order to persist the training results after the instance is terminated, and to have a finer control over the disk's performance. GPU enabled [g2.2xlarge](https://aws.amazon.com/ec2/instance-types/) [spot instances](https://aws.amazon.com/ec2/spot/) are used by default for training instances.

**Pre-requisites for runnning the AWS EC2 deployment scripts:**

 - AWS CLI: [install guide](http://docs.aws.amazon.com/cli/latest/userguide/installing.html)
 - jq JSON Processor: More info [here](https://stedolan.github.io/jq/download/)

**Global AWS EC2 setup:**

1. Select the region where you would like to deploy. For example, set `region = ap-northeast-1` on your `./aws/config` if you select the Tokyo region<sup>1</sup>
2. On `aws_ec2/launch_instance.sh`, set `SUBNET_ID` to the subnet ID you want to use. To find out which subnets are available on a given region, you can run [`$ aws ec2 describe-subnets`](http://docs.aws.amazon.com/cli/latest/reference/ec2/describe-subnets.html). For example, `ap-northeast-1a` corresponds to the `subnet-f4269e9c`value
3. On `aws_ec2/launch_instance.sh`, set `IMAGE_ID` to the base AMI ID used on all instances. The scripts were tested using a HVM SSD EBS-Backed 64-bit (ami-374db956 on the Tokyo region). To consult which base AMIs are available for a given region, consult this [link](https://aws.amazon.com/amazon-linux-ami/)
4. On `aws_ec2/launch_instance.sh`, set `SECURITY_GROUP` to the [security group](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-network-security.html) ID you want to use. Make sure the security group [accepts SSH inbound connections](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/authorizing-access-to-an-instance.html)
5. On `aws_ec2/launch_instance.sh`, set `KEY_PAIR_NAME` to the key pair name used to access the instance
6. On `common/constants.sh`, set `SSH_KEY_PATH` to the path where the SSH authentication key (the same used to create the AWS key pair referenced on step 5.) is stored on your local machine. For example: `SSH_KEY_PATH=/Users/my-username/.ssh/my-ssh-key`


## Usage: Start new Training Session

###AWS EC2

1. On `aws_ec2_train_new.sh`, set `YOUR_OUTRUN_ROMS_PATH` to the local folder where you have your [Out Run game roms](https://github.com/lopespm/agent-trainer/blob/master/roms/roms.txt)
2. [Create a new EBS volume on the AWS console](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-creating-volume.html) on the same subnet as the one chosen above. For example create a 200 GB General Purpose SSD (GP2, 600 IOPS)<sup>2</sup>
3. On `common/constants.sh` set `EXTERNAL_VOLUME_AWS_VOLUME_ID` to the newly created [volume id](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-describing-volumes.html)
4. Format the newly created volume by running:

    ```bash
    $ ./aws_ec2_format_external_volume.sh
    ```
5. Check the [spot instance bid prices](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-spot-instances-history.html) and change the `aws_ec2/launch_instance.sh` maximum bid parameter on `aws_ec2_train_new.sh` if needed<sup>3</sup>
6. Run:

    ```bash
    $ ./aws_ec2_train_new.sh
    ```

*Note: by default the g2.2xlarge instance is used, and `USE_GPU` parameter is set to `true` on `common/constants.sh`, in order to take full advantage of instance's provided GPU*


###Generic Linux (CentOS7) Machine

If you already have a remote machine available, make sure it is accessable through SSH and follow these configuration steps:

1. On `common/constants.sh`, set `HOST_USERNAME` to the remote username which will execute the remote actions
2. Make sure remote user's remote SSH login authenticantion can be made via SSH key, not through password
3. On `common/constants.sh`, set `SSH_KEY_PATH` to the path where the SSH authentication key is stored on your local machine. For example: `SSH_KEY_PATH=/Users/my-username/.ssh/my-ssh-key`
4. On `common/constants.sh`, set `USE_GPU` to true or false, according if want to enable/disable GPU support on your build (the remote machine will need to have a CUDA enabled NVidia card with [NVidia Compute Capability >= 3.0](https://www.tensorflow.org/versions/r0.10/get_started/os_setup.html) for GPU enabled training sessions)
5. Find the remote machine's IP address and set the `ip_address` variable on `generic_train_new.sh`
6. On `generic_train_new.sh`, set `YOUR_OUTRUN_ROMS_PATH` to the local folder where you have your [Out Run game roms](https://github.com/lopespm/agent-trainer/blob/master/roms/roms.txt)
7. Run:

    ```bash
    $ ./generic_train_new.sh
    ```

---

**Customize the deployed code**

The code deployed on the guide above is the one used originally for the [agent trainer](https://github.com/lopespm/agent-trainer), [docker image](https://github.com/lopespm/agent-trainer-deployer) and [cannonball Out Run emulator](https://github.com/lopespm/cannonball). If you want to change it, you can simply fork the repositories, change them to your liking and then change the script `common/fetch_source_repositories.sh` to point to your custom repositories.

**Customize the deployed code: using private repositories**

If you want to use your private GitHub repositories:

1. On `support/github_ssh_key_constants.sh`, set `GITHUB_SSH_KEY_NAME` to the key´s file name and `LOCAL_FOLDER_SSH_KEY` to the local folder where it´s placed. For example, if the SSH key is placed on `/Users/your-user-name/.ssh/your-github-ssh-key-name`, then `LOCAL_FOLDER_SSH_KEY="/Users/your-user-name/.ssh"` and `GITHUB_SSH_KEY_NAME="your-github-ssh-key-name"`
2. Make sure the repositories changed in `common/fetch_source_repositories.sh` are cloned via SSH. This is, they should have this structure: *git clone* **git@github.com:username/***custom-agent-trainer.git ${HOST_PATH_AGENT_TRAINER}*
3. Replace the repositories fetch line in `<generic/aws_ec2>_train_new.sh`:

    ```bash
    # NEW
    (...)
    . ./support/github_ssh_key_copy.sh
    cat common/constants.sh support/github_ssh_key_constants.sh support/github_ssh_key_add.sh common/fetch_source_repositories.sh | ssh -i ${SSH_KEY_PATH} ${HOST_USERNAME}@${ip_address}
    (...)

    # OLD
    (...)
    cat common/constants.sh common/fetch_source_repositories.sh | ssh -i ${SSH_KEY_PATH} ${HOST_USERNAME}@${ip_address}
    (...)
    ```

##Usage: Resume training, retrieve results and debug

###Resume training

You can resume the training session if for some reason the training is halted<sup>4</sup>. Setup:

1. Set `SESSION_ID` on `<generic/aws_ec2>_train_resume.sh` to the session ID you want to resume

**AWS EC2**

A spot instance will be created by default. Check the `aws_ec2/launch_instance.sh` maximum bid parameter used on `aws_ec2_train_resume.sh`

```bash
$ ./aws_ec2_train_resume.sh
```

**Generic Linux (CentOS7) Machine**

Set `ip_address` on `<generic/aws_ec2>_train_resume.sh` to the remote machine's IP

```bash
$ ./generic_train_resume.sh
```

###Retrieve results

Retrieve the session's training results to your local machine. Setup:

1. Set `SESSION_ID` on `<generic/aws_ec2>_retrieve_results.sh` to the session ID you want to resume
2. Set `RETRIEVED_TRAINING_RESULTS_PATH` on `<generic/aws_ec2>_retrieve_results.sh` to the local path where the results will be downloaded

**AWS EC2**

You have two alternatives available in the `aws_ec2_retrieve_results.sh` script via the `CREATE_NEW_INSTANCE` variable:

 - If set to `false`, the results will be retrieved directly from the training instance. Set the `ip_address` to the training instance's public IP address
 - If set to `true`, a new on-demand instance will be created and will mount the external volume. An EBS volume can only be mounted by one instance at a time, so if the training instance is still running when you perform this kind of retrieve, the new script will wait until the external volume is made available

```bash
$ ./aws_ec2_retrieve_results.sh
```

**Generic Linux (CentOS7) Machine**

Set `ip_address` on `<generic/aws_ec2>_retrieve_results.sh` to the remote machine's IP

```bash
$ ./generic_retrieve_results.sh
```

###Debug for AWS EC2

Launches the shell on a new on-demand instance attached to the external EBS volume

```bash
$ ./aws_ec2_debug_ssh.sh
```

<br/>
---

<sup>1</sup> The Tokyo region was chosen to perform the trainings described [in this blogpost](http://lopespm.github.io/machine_learning/2016/10/06/deep-reinforcement-learning-racing-game.html) due to the low consistent g2.2xlarge [spot instance bid prices](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-spot-instances-history.html)

<sup>2</sup> Using the default agent-traing configuration, each training run can reach up to 25GB worth of replay memories, which need to be accessed randomly during the training process. Since these cannot fit into the g2.2xlarge instance's 16GB of RAM, about 600 IOPS are required to keep the training performance acceptable. GP2 volumes provide more IOPS as you increase their size, hence the allocation of a 200 GB General Purpose SSD (GP2, 600 IOPS), which turns out to be more cost effective than a smaller 30GB, 600 IOPS Provisioned SSD (IO1).

<sup>3</sup> In order to aquire a spot instance and keep it, you need to [place a bid that is not lower than the current one placed on the instance](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/how-spot-instances-work.html)

<sup>4</sup> For example, a AWS EC2 the spot instance can be terminated if someone overbids you.
