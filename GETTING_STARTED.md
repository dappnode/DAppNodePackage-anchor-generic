## Welcome to the Anchor DAppNode Package

Anchor is an open source implementation of the Secret Shared Validator (SSV) protocol, written in Rust and maintained by [Sigma Prime](https://sigmaprime.io/).

> Note: Anchor requires connections to a beacon node and an execution client. You can select the beacon node and execution client form the `STAKERS` option on the left of the DAppNode UI. 

To get started, go to the CONFIG tab, select `New Operator` or `Import Operator`. 

If you do not have an existing public-private key pair or have not registered an operator on the SSV network website previously, that means you are a new operator. 

For new operators, refer to the [SSV documentation](https://docs.ssv.network/operators/operator-management/registration/) on how to register a new operator. Anchor will auto generate the public-private key pairs when starting fresh. You can view the public key by entering the following command in our DAppNode server:

For mainnet:
`docker exec DAppNodePackage-operator.anchor.dnp.dappnode.eth cat /root/.anchor/public_key.txt`

For Hoodi testnet:
`docker exec DAppNodePackage-operator.anchor-hoodi.dnp.dappnode.eth cat /root/.anchor/public_key.txt`

Use this public key to register a new operator in the SSV network with the link above. We also strongly advise that you backup a copy of the private key file. The private key is named:

`encrypted_private_key.json` in the same directory as the public key.

If you have a registered operator, you should already have the private key with you. In this case, choose "import operator" in the CONFIG tab and upload the private key. The name of the private key file should be `encrypted_private_key.json". Note that the upload option will only appear once for a fresh install and it can't be modified afterwards without deleting the whole Anchor database.


