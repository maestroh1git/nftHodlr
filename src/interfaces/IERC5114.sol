// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


interface IERC5114 {
    // fired anytime a new instance of this badge is minted
    // this event **MUST NOT** be fired twice for the same `badgeId`
    event Mint(
        uint256 indexed badgeId,
        address indexed nftAddress,
        uint256 indexed nftTokenId
    );

    // returns the NFT that this badge is bound to.
    // this function **MUST** throw if the badge hasn't been minted yet
    // this function **MUST** always return the same result every time it is called after it has been minted
    // this function **MUST** return the same value as found in the original `Mint` event for the badge
    function ownerOf(
        uint256 badgeId
    ) external view returns (address nftAddress, uint256 nftTokenId);

    // returns a URI with details about this badge collection
    // the metadata returned by this is merged with the metadata return by `badgeUri(uint256)`
    // the collectionUri **MUST** be immutable (e.g., ipfs:// and not http://)
    // the collectionUri **MUST** be content addressable (e.g., ipfs:// and not http://)
    // data from `badgeUri` takes precedence over data returned by this method
    // any external links referenced by the content at `collectionUri` also **MUST** follow all of the above rules
    function collectionUri()
        external
        pure
        returns (string memory collectionUri);

    // returns a censorship resistant URI with details about this badge instance
    // the collectionUri **MUST** be immutable (e.g., ipfs:// and not http://)
    // the collectionUri **MUST** be content addressable (e.g., ipfs:// and not http://)
    // data from this takes precedence over data returned by `collectionUri`
    // any external links referenced by the content at `badgeUri` also **MUST** follow all of the above rules
    function tokenUri(
        uint256 tokenId
    ) external view returns (string memory tokenUri);

    // returns a string that indicates the format of the `badgeUri` and `collectionUri` results (e.g., 'EIP-ABCD' or 'soulbound-schema-version-4')
    function metadataFormat() external pure returns (string memory format);
}