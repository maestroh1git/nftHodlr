// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.0;

interface IERC6551Account {

    event TransactionExecuted(address indexed to, uint256 value, bytes data);


    receive() external payable;

    function executeCall(
        address to,
        uint256 value,
        bytes calldata data
    ) external payable returns (bytes memory);

    function token()
        external
        view
        returns (
            uint256 chainId,
            address tokenContract,
            uint256 tokenId
        );

    function owner() external view returns (address);

    function nonce() external view returns (uint256);
}