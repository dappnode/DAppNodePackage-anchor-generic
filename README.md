# Anchor DAppNode Package

Anchor is an open source implementation of the Secret Shared Validator (SSV) protocol, written in Rust and maintained by [Sigma Prime](https://sigmaprime.io). This DAppNode package provides a user friendly UX to run Anchor as a SSV client on your DAppNode. For more information about Anchor, refer to the official [documentation](https://anchor.sigmaprime.io/introduction).

To get started, once you have selected `Anchor` or `Anchor Hoodi` DAppNode package, it will prompt you to select the `Setup Mode`, either `New Operator` or `Import Operator`. 

## New Operator
If you do not have an existing public-private key pair or have not registered an operator on the SSV network website previously, that means you are a new operator. If this is the case, select `New Operator` and enter a password in the space provided. Anchor will generate a new public-private key pair, and then start to run Anchor. 

Anchor will start to run, however, since the public key has not been registered on the SSV network, the node will not be performing any duties. You are required to register the public key as a new operator on the SSV network. Refer to the [SSV documentation](https://docs.ssv.network/operators/operator-management/registration/) on how to register a new operator. Once the on-chain transaction to register the new operator is confirmed, Anchor will be able to retrieve the operator info, and the node will be ready to perform validator duties.

> Note: You are required to remember the password. In the future, if you want to move the operator private key, the password will be used to decrypt the private key so that you remain having access to the operator that you have registered on the SSV network.

## Import Operator
If you have a registered operator, you should already have a private key with you. In this case, choose `Import Operator`. Upload the encrypted private key file, the file name must be `encrypted_private_key.json`. Then, enter the password to decrypt the private key in the space provided. 

Anchor will start to run and after a short time, you should see that Anchor will display the operator id on the log. Note that the upload option will only appear once on a fresh install and it can't be modified afterwards without deleting the whole Anchor package. 

### Backup your key
There is a `BACKUP` tab in the Anchor package. It enables you to download the Anchor data which includes the public-private key pair. We strongly recommend you to make a backup copy of the key pair. Once you go to the `BACKUP` tab, click on `Download backup`. This will download a compressed file. After extracting the file, under the folder `keys` lies the private key, named `encrpted_private_key.json` and the password text file. You can then backup the private key file with your preferred backup option.