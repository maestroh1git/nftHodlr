//Mint contract ERC721, inherits ERC725, ERC6551, ERC5114
//ERC721 - NFT
//ERC725 - Key- Value storage
//ERC6551 - Account abstraction, NFT owns accounts
//ERC5114 - NFT is soul bound

//steps
//1+- NFT mints- we need nft contract address
//2+- NFT inherits soulbound ERC5114, so we cant transfer it out
//3+- ERC-6551 Registry and Account allows NFT to own smartcontract account
//4+- NFT is bound to account in registry, so NFT can own stuff
//Testing.......
// #TODO deploy registry, deploy account, use deployment addresses to deploy implementation
//5?- 725, hold storage of NFTs and perhaps owners or assets owned by NFT

//Track soul tokens- in 725

//user mints token, tokenId => ERC725
//owner => tokenId

// owner => tokenId => ERC725 soulToTokenToStorage

// soulToTokenToStorage[owner][tokenId]

//implement ERC725x as executor and ERC725y as storage
//x - is the data storage
// key is user address
// value is nft account address

//y - is the executor
// it allows, a user to call a function as a signer of another account?
// i want my nft to transfer tokens to someone else
// i call the executor it gets my nft accountAddress from ERC725x, and signature with EIP712
// and executes the transaction

//in essesnce
/**
    The NFT is a soulbound token, it is minted to a user
    the user can then transfer tokens or other assets to the account that is abstracted to the NFT
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./registry.sol";
import "./ERC725Storage.sol";
import "./interfaces/ISoulAccount.sol";
import "./interfaces/IERC5114.sol";

contract ImpTheGoat is Ownable, IERC5114 {
    using Counters for Counters.Counter;
    using Strings for uint256;
    ERC725Storage _tokenStorage;

    // Mapping from `Soul address, Soul tokenId` to token balance
    // mapping(address => mapping(uint256 => uint256)) internal _soulData;

    // Mapping from ` tokenId` to `Soul address`
    mapping(uint256 => address) public tokenToAddresses;

    // Mapping from `soul` to ` tokenId`
    mapping(address => uint256) public soulToTokens;

    // mapping(uint256 => address) public soulTokenToOwner;

    mapping(bytes32 => bytes) private _store;

    mapping(address => ERC725Storage) public tokenData;

    //this event is for querying, to get who owns what nft and what account is connected to it,
    //eventhough ERC6551 has its own event fot this purpose
    event TokenAccountCreatedForSoul(
        address indexed soul,
        address indexed account,
        uint256 indexed tokenId
    );

    event TransactionExecuted(
        address indexed to,
        uint indexed value,
        bytes indexed data
    );

    error TransferFromOrToSoulAccount();

    string public collectionInfo;
    string public tokenInfo;

    Counters.Counter private _tokenIdCounter;
    //An account Abstraction Registry
    IERC6551Registry public erc6551Registry;
    //An Account Abstraction Implementation - It is the smart contract wallet bound to the NFT
    address public erc6551AccountImplementation;

    constructor(
        string memory _collectionURI,
        string memory _tokenURI,
        //we pass in the address of the registry and the account implementation in the constructor
        address _erc6551Registry,
        address _erc6551AccountImplementation
    ) {
        collectionInfo = _collectionURI;
        tokenInfo = _tokenURI;

        //Initialize the registry and the account implementation address
        erc6551Registry = IERC6551Registry(_erc6551Registry);
        erc6551AccountImplementation = _erc6551AccountImplementation;
    }

    function safeMint() public onlyOwner {
        _tokenIdCounter.increment();
        uint256 tokenId = _tokenIdCounter.current();
        _mint(tokenId);

        require(
            _tokenAccountCreation(tokenId, msg.sender),
            "Failed To Create Account For Token"
        );
    }

    // Returns Soul address and Soul token id
    //should take in the badge(we dont need it, since we are using the nft as the badge)
    function _getSoul(
        uint256 _tokenId
    ) internal view virtual returns (address, uint256) {
        address soulAddress = tokenToAddresses[_tokenId];
        require(
            soulAddress != address(0),
            "ERC5114SoulBadge: Soul token owner not found"
        );

        return (soulAddress, _tokenId);
    }

    //uses the ERC6551 to create an account bound to the token
    function _tokenAccountCreation(
        uint256 _tokenId,
        address _soul
    ) internal returns (bool) {
        address newAccount = erc6551Registry.createAccount(
            erc6551AccountImplementation,
            block.chainid,
            address(this),
            _tokenId,
            0,
            ""
        );
        //emit the address that owns the token, the address of the token account and the tokenID in an event
        emit TokenAccountCreatedForSoul(_soul, newAccount, _tokenId);

        //add the token account to the tokenData storage mapping (725)
        require(
            createInstanceForAddress(newAccount),
            "Unable to create tokenAccount Storage Instance"
        );

        // ERC725 newStorage = ERC725(newAccount);
        ERC725Storage newStorage = tokenData[newAccount];
        newStorage.setDataSingle(
            keccak256(abi.encode(msg.sender)),
            abi.encode(_soul, newAccount, _tokenId)
        );

        return true;
    }

    //This returns the account assigned to the token
    function showTokenAccount(uint256 _tokenId) public view returns (address) {
        return
            erc6551Registry.account(
                erc6551AccountImplementation,
                block.chainid,
                address(this),
                _tokenId,
                0
            );
    }

    function ownerOf(
        uint256 tokenId
    ) external view virtual returns (address, uint256) {
        return _getSoul(tokenId);
    }

    function _mint(uint256 tokenId) internal virtual {
        // require(soulContract != address(0), "ERC: mint to the zero address");
        //check if token exists ie already minted

        /* use this for tracker -unchecked*/
        // Overflows are incredibly unrealistic.
        // unchecked {
        soulToTokens[msg.sender] = tokenId;
        tokenToAddresses[tokenId] = msg.sender;
        // _soulData[soulContract][soulTokenId] += 1;
        // }

        emit Mint(tokenId, address(this), tokenId);
    }

    function collectionUri()
        external
        pure
        virtual
        override
        returns (string memory)
    {
        return "collectionInfo";
    }

    function metadataFormat() external pure returns (string memory) {
        // ERC721 Metadata JSON Schema
        return
            '{"title": "Asset Metadata","type": "object","properties": {'
            '"name": {"type": "string","description": "Identifies the asset to which this NFT represents"},'
            '"description": {"type": "string","description": "Describes the asset to which this NFT represents"},'
            '"image": {"type": "string","description": "A URI pointing to a resource with mime type image/* representing the asset to which this NFT represents. Consider making any images at a width between 320 and 1080 pixels and aspect ratio between 1.91:1 and 4:5 inclusive."}}}';
    }

    function tokenUri(
        uint256 tokenId
    ) external view virtual override returns (string memory) {
        return
            bytes(tokenInfo).length > 0
                ? string(
                    abi.encodePacked(tokenInfo, tokenId.toString(), ".json")
                )
                : "";
    }

    function createInstanceForAddress(
        address tokenAccount
    ) public returns (bool) {
        address cont = address(tokenData[tokenAccount]);
        require(cont == address(0), "Instance already created");
        ERC725Storage tkn = new ERC725Storage();
        tokenData[tokenAccount] = tkn;
        return true;
    }

    function setDataSingle(
        address tokenAccount,
        bytes32 _key,
        bytes memory _value
    ) public {
        ERC725Storage shard = tokenData[tokenAccount];
        shard.setDataSingle(_key, _value);
    }

    function setDataBulk(
        address tokenAccount,
        bytes32[] memory _key,
        bytes[] memory _value
    ) public {
        ERC725Storage shard = tokenData[tokenAccount];
        shard.setData(_key, _value);
    }

    function getData(
        address _addr,
        bytes32 _dataKey
    ) public view returns (bytes memory) {
        ERC725Storage shard = tokenData[_addr];
        return shard.getData(_dataKey);
    }

    function getDataBulk(
        address _addr,
        bytes32[] memory _datakey
    ) public view returns (bytes[] memory) {
        ERC725Storage shard = tokenData[_addr];
        return shard.getDataBulk(_datakey);
    }

    function transferFromOrToSoulAccount(
        uint256 tokenId,
        address to,
        uint256 value,
        bytes memory data
    ) public payable returns (bytes memory result) {
        require(
            msg.sender == tokenToAddresses[tokenId],
            "You do not own this Soul Token"
        );

        address tokenAccount = showTokenAccount(tokenId);

        if (msg.value != 0 && value != 0) {
            revert TransferFromOrToSoulAccount();
        }

        emit TransactionExecuted(to, msg.value, data);

        if (msg.value != 0) {
            result = ISoulAccount(payable(tokenAccount)).executeCall(
                to,
                msg.value,
                data
            );

            if (result.length < 0) {
                assembly {
                    revert(add(result, 32), mload(result))
                }
            }
        } else if (value != 0) {
            result = ISoulAccount(payable(tokenAccount)).executeCall(
                to,
                value,
                data
            );

            if (result.length < 0) {
                assembly {
                    revert(add(result, 32), mload(result))
                }
            }
        }
    }
}
