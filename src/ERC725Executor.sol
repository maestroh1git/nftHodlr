pragma solidity >=0.7.0 <0.9.0;

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/access/Ownable.sol";

contract ERC725Executor is Ownable {
    uint256 public red;
    event Executed(
        uint256 operationType,
        address target,
        uint256 valueToSend,
        bytes dataToSend
    );
    error LowLevelCallFailed(address target, bytes dataToSend);

    function execute(
        uint256 operationType,
        address target,
        uint256 valueToSend,
        bytes memory dataToSend
    ) public payable onlyOwner {
        _execute(operationType, target, valueToSend, dataToSend);
    }

    function executeBatch(
        uint256[] memory operationType,
        address[] memory target,
        uint256[] memory valueToSend,
        bytes[] memory dataToSend
    ) public payable onlyOwner {
        require(
            operationType.length == target.length &&
                target.length == valueToSend.length &&
                valueToSend.length == dataToSend.length &&
                operationType.length != 0
        );
        for (uint256 i = 0; i < operationType.length; i++) {
            _execute(
                operationType[i],
                target[i],
                valueToSend[i],
                dataToSend[i]
            );
        }
    }

    function _execute(
        uint256 operationType,
        address target,
        uint256 valueToSend,
        bytes memory dataToSend
    ) internal {
        if (operationType == 0) {
            (bool success, bytes memory returnData) = target.call{
                value: valueToSend
            }(dataToSend);
            if (success) {
                emit Executed(operationType, target, valueToSend, dataToSend);
            } else {
                revert LowLevelCallFailed(target, dataToSend);
            }
        } else if (operationType == 1) {
            (bool success, bytes memory returnData) = target.staticcall(
                dataToSend
            );
            if (success) {
                emit Executed(operationType, target, valueToSend, dataToSend);
            } else {
                revert LowLevelCallFailed(target, dataToSend);
            }
        } else if (operationType == 2) {
            (bool success, bytes memory returnData) = target.delegatecall(
                dataToSend
            );
            if (success) {
                emit Executed(operationType, target, valueToSend, dataToSend);
            } else {
                revert LowLevelCallFailed(target, dataToSend);
            }
        } else if (operationType == 3) {
            address contractAddress;
            assembly {
                contractAddress := create(
                    valueToSend,
                    add(dataToSend, 0x20),
                    mload(dataToSend)
                )
            }
            require(contractAddress != address(0));
        } else if (operationType == 4) {
            address contract2Address;
            bytes32 salt;
            assembly {
                contract2Address := create2(
                    valueToSend,
                    add(dataToSend, 0x20),
                    mload(dataToSend),
                    salt
                )
            }
            require(contract2Address != address(0));
        } else {
            revert("Op greater than 4");
        }
    }
}