# CoreMint
A platform for minting NFTs on the Stacks blockchain built with Clarity smart contracts.

## Features
- Mint unique NFTs with metadata
- Transfer NFTs between addresses
- Query NFT ownership and metadata
- Configurable minting fees
- Support for multiple NFT collections

## Getting Started
1. Clone the repository
2. Install dependencies with `clarinet install`
3. Run tests with `clarinet test`
4. Deploy contracts using Clarinet console

## Contract Interface
### Mint NFT
```clarity
(mint-nft (metadata-uri (string-utf8 256)) (recipient principal))
```

### Transfer NFT
```clarity
(transfer-nft (token-id uint) (sender principal) (recipient principal))
```
