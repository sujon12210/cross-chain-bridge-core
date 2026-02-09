// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BridgeBase is Ownable {
    using ECDSA for bytes32;

    IERC20 public token;
    address public validator;
    mapping(bytes32 => bool) public processedMessages;

    event Locked(address indexed user, uint256 amount, uint256 nonce);
    event Released(address indexed user, uint256 amount, uint256 nonce);

    constructor(address _token, address _validator) Ownable(msg.sender) {
        token = IERC20(_token);
        validator = _validator;
    }

    function lock(uint256 amount, uint256 nonce) external {
        require(token.transferFrom(msg.sender, address(this), amount), "Transfer failed");
        emit Locked(msg.sender, amount, nonce);
    }

    function release(
        address user, 
        uint256 amount, 
        uint256 nonce, 
        bytes calldata signature
    ) external {
        bytes32 messageHash = keccak256(abi.encodePacked(user, amount, nonce));
        bytes32 ethSignedMessageHash = messageHash.toEthSignedMessageHash();

        require(!processedMessages[messageHash], "Already processed");
        require(ethSignedMessageHash.recover(signature) == validator, "Invalid signature");

        processedMessages[messageHash] = true;
        require(token.transfer(user, amount), "Transfer failed");

        emit Released(user, amount, nonce);
    }
}
