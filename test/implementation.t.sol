// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "forge-std/Test.sol";
import "../src/implementation.sol";
import "../src/registry.sol";
import "../src/accountAbstraction.sol";

contract ImpTheGoat_Test is Test {
    ImpTheGoat implementation;
    ERC6551Registry registry;
    SoulAccount soulAccount;

    function setUp() public {
        registry = new ERC6551Registry();
        soulAccount = new SoulAccount();

        implementation = new ImpTheGoat(
            "",
            "",
            address(registry),
            address(soulAccount)
        );

        vm.label(address(this), "user");
        vm.label(address(implementation), "ImpTheGoat");

        // emit log_named_address("user", address(this));
        // emit log_named_address("ImpTheGoat", address(implementation));
        // emit log_named_address("registry", address(registry));
        // emit log_named_address("soulAccount", address(soulAccount));
    }

    function test__initialization() public {
        assertEq(
            implementation.owner(),
            address(this),
            "Owner should be the deployer"
        );
        // Add more initialization tests
    }

    function test__mint() public {
        emit log_named_address("user", address(this));
        emit log_named_address("ImpTheGoat", address(implementation));
        emit log_named_address("registry", address(registry));
        emit log_named_address("soulAccount", address(soulAccount));
        implementation.safeMint();
        (address nftAddress, uint256 nftTokenId) = implementation.ownerOf(1);
        assertEq(nftAddress, address(this), "NFT address mismatch");
        assertEq(nftTokenId, 1, "NFT Token ID mismatch");
    }

    // function test__accountCreation() public {
    //     implementation.safeMint();
    //     address account = implementation.showTokenAccount(1);
    //     assertTrue(account != address(0), "Account should be created");
    // }

    function test__erc725DataStorage() public {
        implementation.safeMint();
        bytes32 key = keccak256(abi.encode(address(this)));
        (address tokenAccount) = implementation.showTokenAccount(1);
        emit log_named_address("tokenAccount", tokenAccount);
        bytes memory value = implementation.getData(tokenAccount, key);
        emit log_named_bytes("value", value);
        assertEq(value.length, 24 + 20 + 20 + 32, "Invalid packed data length");
        (address soul,
        address newAccount,
        uint256 tokenId) = abi.decode(value, (address, address, uint256));
        // // Inline assembly for efficient decoding
        // assembly {
        //     // Load the 20 bytes starting from position 32 into 'soul'
        //     soul := mload(add(value, 0x20))
            
        //     // Load the 20 bytes starting from position 52 into 'newAccount'
        //     newAccount := mload(add(value, 0x34))
            
        //     // Load the 32 bytes starting from position 72 into 'tokenId'
        //     tokenId := mload(add(value, 0x48))
        // }
        // // Add assertions to check if the value is as expected

        emit log_named_address("soul", soul);
        emit log_named_address("newAccount", newAccount);
        emit log_named_uint("tokenId", tokenId);

        assertEq(soul, address(this), "Soul address mismatch");
        assertEq(newAccount, tokenAccount, "New account address mismatch");
        assertEq(tokenId, 1, "Token ID mismatch");
    }

    // function test__ownershipAndTransferRestrictions() public {
    //     implementation.safeMint();
    //     // Add logic to test if the token is non-transferable
    // }

    // function test__metadata() public {
    //     assertEq(
    //         implementation.collectionUri(),
    //         "collectionInfo",
    //         "Collection URI mismatch"
    //     );
    //     // Add more metadata tests
    // }
}
