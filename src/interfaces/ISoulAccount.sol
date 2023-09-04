// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.0;

// interfaces
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/interfaces/IERC1271.sol";
import "./IERC6551Account.sol";


interface ISoulAccount is IERC165, IERC1271, IERC6551Account {

    // Public and External function signatures
    function executeCall(
        address to,
        uint256 value,
        bytes calldata data
    ) external payable returns (bytes memory result);

    function token() external view returns (uint256, address, uint256);

    function owner() external view returns (address);

    function ownerOrNFTContract() external view returns (address, address);

    function isValidSignature(
        bytes32 hash,
        bytes memory signature
    ) external view returns (bytes4 magicValue);

    function supportsInterface(bytes4 interfaceId) external pure returns (bool);

    // State variable getter if needed
    function nonce() external view returns (uint256);
}
