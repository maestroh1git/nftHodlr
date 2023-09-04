// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/interfaces/IERC1271.sol";
import "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import "./registry.sol";
import "./implementation.sol";
import "./interfaces/IERC6551Account.sol";
import "./libs/ERC6551AccountLib.sol";
import "./libs/Bytecode.sol";

  contract SoulAccount is IERC165, IERC1271, IERC6551Account {
    uint256 public nonce;

    error NotOwnerOrNFTContract();

    receive() external payable {}

    fallback() external payable {}

    function executeCall(
        address to,
        uint256 value,
        bytes calldata data
    ) external payable returns (bytes memory result) {

        (, address tokenContract) = this.ownerOrNFTContract();

        require(msg.sender == owner() || msg.sender == tokenContract, "Not token owner");

        ++nonce;

        emit TransactionExecuted(to, value, data);

        bool success;
        (success, result) = to.call{value: value}(data);

        if (!success) {
            assembly {
                revert(add(result, 32), mload(result))
            }
        }
    }

    function token()
        external
        view
        returns (
            uint256,
            address,
            uint256
        )
    {
        uint256 length = address(this).code.length;
        return
        abi.decode(
                Bytecode.codeAt(address(this), length - 0x60, length),
                (uint256, address, uint256)
            );
    }

    function owner() public view returns (address) {
        (uint256 chainId, address tokenContract, uint256 tokenId) = this.token();
        require(chainId == block.chainid, "Wrong chainID");
        (address soul, ) = IERC5114(tokenContract).ownerOf(tokenId);
        return soul;
    }

     function ownerOrNFTContract() external view returns (address, address){
        (uint256 chainId, address tokenContract, uint256 tokenId) = this.token();
        require(chainId == block.chainid, "Wrong chainID");
        (address soul, ) = IERC5114(tokenContract).ownerOf(tokenId);
        return (soul, tokenContract);
     }
    
    function supportsInterface(bytes4 interfaceId) public pure returns (bool) {
        return (interfaceId == type(IERC165).interfaceId ||
            interfaceId == type(IERC6551Account).interfaceId);
    }

    function isValidSignature(bytes32 hash, bytes memory signature)
        external
        view
        returns (bytes4 magicValue)
    {
        bool isValid = SignatureChecker.isValidSignatureNow(owner(), hash, signature);

        if (isValid) {
            return IERC1271.isValidSignature.selector;
        }

        return "";
    }
}
