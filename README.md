# Anchor DAppNode Package

Anchor is an open source implementation of the Secret Shared Validator (SSV) protocol, written in Rust and maintained by [Sigma Prime](https://sigmaprime.io). This DAppNode package provides a user friendly UX to run Anchor as a distributed validator client on your DAppNode. For more information about Anchor, refer to the official [documentation](https://anchor.sigmaprime.io/introduction).

To get started, once you have selected `Anchor' or `Anchor Hoodi` DAppNode package, it will prompt you to select the `Setup Mode`, either `New Operator` or `Import Operator`. 

If you do not have an existing public-private key pair or have not registered an operator on the SSV network website previously, that means you are a new operator. 

For new operators, refer to the [SSV documentation](https://docs.ssv.network/operators/operator-management/registration/) on how to register a new operator. Anchor will auto generate the public-private key pairs when starting fresh. You can view the public key by entering the following command in our DAppNode server:

For mainnet:
`docker exec DAppNodePackage-operator.anchor.dnp.dappnode.eth cat /root/.anchor/public_key.txt`

For Hoodi testnet:
`docker exec DAppNodePackage-operator.anchor-hoodi.dnp.dappnode.eth cat /root/.anchor/public_key.txt`

Use this public key to register a new operator in the SSV network with the link above. We also strongly advise that you backup a copy of the private key file. The private key is named:

`encrypted_private_key.json` in the same directory as the public key.

If you have a registered operator, you should already have the private key with you. In this case, choose `Import Operator`. Upload the encrypted private key file, the file name must be `encrypted_private_key.json`. Then, upload the password file, the file name must be `password.txt`. Note that the upload option will only appear once for a fresh install and it can't be modified afterwards without deleting the whole Anchor database.

