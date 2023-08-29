//SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import {ERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "./interfaces/IERC725Y.sol";

import "./errors.sol";

// constants
import {_INTERFACEID_ERC725Y} from "./constants.sol";

contract ERC725 is ERC165, IERC725Y {
    address public contractOwner;

    constructor() {
        contractOwner = msg.sender;
    }

    mapping(bytes32 => bytes) internal _store;

    function setData(
        bytes32[] memory dataKeys,
        bytes[] memory dataValues
    ) public {
        require(msg.sender == contractOwner, "Not permitted");
        require(
            dataKeys.length == dataValues.length,
            "Keys length not equal to values length"
        );
        for (uint256 i = 0; i < dataKeys.length; i++) {
            _setData(dataKeys[i], dataValues[i]);
        }
    }

     function setData(bytes32 dataKey, bytes memory dataValue) public virtual override {
        _setData(dataKey, dataValue);
    }

    function setDataSingle(bytes32 dataKey, bytes memory dataValue) public {
        // require(msg.sender == contractOwner, "Not permitted");
        _setData(dataKey, dataValue);
    }

    function _setData(bytes32 dataKey, bytes memory dataValue) internal {
        _store[dataKey] = dataValue;
    }

    function getDataBulk(
        bytes32[] memory dataKeys
    ) public view returns (bytes[] memory dataValues) {
        dataValues = new bytes[](dataKeys.length);
        for (uint256 i = 0; i < dataKeys.length; i++) {
            dataValues[i] = _getData(dataKeys[i]);
        }
        return dataValues;
    }

    function getData(
        bytes32 dataKey
    ) public view returns (bytes memory dataValue) {
        dataValue = _getData(dataKey);
        return dataValue;
    }

    function getData(
        bytes32[] memory dataKeys
    ) public view virtual override returns (bytes[] memory dataValues) {
        dataValues = new bytes[](dataKeys.length);

        for (
            uint256 i = 0;
            i < dataKeys.length;
            i = _uncheckedIncrementERC725Y(i)
        ) {
            dataValues[i] = _getData(dataKeys[i]);
        }

        return dataValues;
    }

    function _getData(
        bytes32 dataKey
    ) internal view returns (bytes memory dataValue) {
        return _store[dataKey];
    }

    function returnContractOwner() public view returns (address) {
        return contractOwner;
    }

    /**
     * @dev Will return unchecked incremented uint256
     *      can be used to save gas when iterating over loops
     */
    function _uncheckedIncrementERC725Y(
        uint256 i
    ) internal pure returns (uint256) {
        unchecked {
            return i + 1;
        }
    }

    /**
     * @inheritdoc ERC165
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(IERC165, ERC165) returns (bool) {
        return
            interfaceId == _INTERFACEID_ERC725Y ||
            super.supportsInterface(interfaceId);
    }
}
