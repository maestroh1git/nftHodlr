# Project: Soulbound NFT Account Manager

## Description

The Soulbound NFT Account Manager is an innovative Ethereum-based project that explores the realms of Non-Fungible Tokens (NFTs), Account Abstraction, and Key-Value Storage in an integrated architecture. Utilizing ERC standards such as ERC721, ERC725, ERC6551, and ERC5114, the project aims to build a platform where NFTs can essentially "own" accounts and storage, thereby giving them a "soul."

### Features

1. **Soulbound NFTs (ERC721 + ERC5114)**: Tokens minted on this platform are ERC721 compatible but have a unique feature—they are soulbound, i.e., non-transferable once minted to an address, adhering to the ERC5114 standard.

2. **Key-Value Storage (ERC725)**: Each NFT can have its storage layer, facilitating diversified use-cases, including profile data, asset lists, or any custom data.

3. **Account Abstraction (ERC6551)**: An extension allowing each NFT to "own" an account, i.e., a separate smart contract that can execute arbitrary transactions on behalf of the NFT. The account abstraction mechanism is realized via a registry.

4. **Events and Metadata**: Custom events and metadata methods are implemented to comply with standards and offer easier front-end integration.

### Code Overview

#### Contracts

- `ImpTheGoat`: The core contract, handling the NFT minting and connecting each NFT to an "account" and storage.
- `IERC5114`: Interface for the soulbound property of NFTs.
- `SoulAccount`: The contract that serves as an account abstraction for each NFT. It implements interfaces like IERC165, IERC1271, and IERC6551Account.

#### Key Functions

- `safeMint()`: Mint a new soulbound NFT and create an associated account.
- `tokenAccountCreation()`: Creates a smart contract "account" associated with the newly minted NFT.
- `showTokenAccount()`: Shows the account associated with a particular NFT.
- `executeCall()`: Execute arbitrary transactions from the NFT's account.

#### Events

- `TokenAccountCreatedForSoul`: Emitted when an NFT is minted and its associated "account" is created.

### Technologies

- **Smart Contract Language**: Solidity ^0.8.9
- **Standards**: ERC721, ERC725, ERC6551, ERC5114
- **Libraries**: OpenZeppelin for standard compliant and secure code
- **Network**: Ethereum

## Getting Started

(TBD: Steps for setup and running your project)

## Future Enhancements

- Implement a DAO governance model to manage system upgrades.
- Enable integration with DeFi protocols, allowing NFTs to yield farm or provide liquidity.

## License

MIT

---

This project represents a significant leap towards empowering NFTs with more functionalities and capabilities, turning them into first-class citizens in the smart contract world.