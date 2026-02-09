# Cross-Chain Bridge Core

This repository contains the smart contract architecture for a secure, decentralized bridge. It enables the movement of assets between two EVM-compatible networks using a trusted validator set to verify state transitions.

## Architecture
* **BridgeBase**: The primary contract handling `lock()` and `release()` logic.
* **WrappedToken**: An ERC-20 contract deployed on the destination chain that represents the locked asset.
* **Validator Logic**: EIP-712 signature verification to ensure that only authorized relayers can trigger minting on the destination chain.

## Workflow
1. **Source Chain**: User calls `lock()`. Assets are held in the contract. An event is emitted.
2. **Off-Chain**: Relayers pick up the event and gather validator signatures.
3. **Destination Chain**: User (or relayer) calls `mint()` with signatures. Wrapped tokens are issued 1:1.

## Security
* **Replay Protection**: Uses unique transaction nonces and chain IDs.
* **Threshold Signatures**: Requires a majority of validators to approve any minting.
* **Supply Caps**: Hard limits on how much can be bridged in a single window.
