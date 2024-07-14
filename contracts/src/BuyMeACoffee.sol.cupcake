// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

/**
 * @title Memos
 * @dev Memo struct
 */
struct Memo {
    uint256 numCupcakes;
    string userName;
    string twitterHandle;
    string message;
    uint256 time;
    address userAddress;
}

/**
 * @title BuyMeACupcake
 * @dev BuyMeACupcake contract to accept donations and for our users to leave memos
 */
contract BuyMeACupcake {
    address public owner;
    address public receiver;
    bool public ownershipTransferred;

    Memo[] private memos;

    /**
     * ERRORS *************************
     */
    error OnlyOwner();
    error InvalidArguments(string errorMessage);
    error InsufficientFunds();

    /**
     * EVENTS *************************
     */
    event NewMemo(
        uint256 numCupcakes,
        string userName,
        string twitterHandle,
        string message,
        uint256 time,
        address indexed userAddress
    );

    event Withdrawn(address to, uint256 amount);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event ReceiverSet(address indexed newReceiver);

    /**
     * @dev Constructor sets the owner and receiver to the deployer's address
     */
    constructor() {
        owner = msg.sender;
        receiver = msg.sender;
    }

    /**
     * @dev Modifier to check if the caller is the owner
     */
    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert OnlyOwner();
        }
        _;
    }

    /**
     * @dev Function to transfer ownership, can only be done once
     * @param newOwner The address of the new owner
     */
    function transferOwnership(address newOwner) public onlyOwner {
        if (ownershipTransferred) {
            revert InvalidArguments("Ownership can only be transferred once");
        }
        if (newOwner == address(0)) {
            revert InvalidArguments("Invalid new owner address");
        }
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        ownershipTransferred = true;
    }

    /**
     * @dev Function to set the donation receiver
     * @param newReceiver The address of the new receiver
     */
    function setReceiver(address newReceiver) public onlyOwner {
        if (newReceiver == address(0)) {
            revert InvalidArguments("Invalid receiver address");
        }
        receiver = newReceiver;
        emit ReceiverSet(newReceiver);
    }

    /**
     * @dev Function to buy a cupcake
     * @param userName The name of the user
     * @param twitterHandle The twitter handle of the user
     * @param message The message of the user
     */
    function buyCupcake(string memory userName, string memory twitterHandle, string memory message) public payable {
        if (msg.value == 0) {
            revert InvalidArguments("Cannot buy a cupcake with 0 value");
        }

        Memo memory newMemo = Memo({
            numCupcakes: 1,
            userName: userName,
            twitterHandle: twitterHandle,
            message: message,
            time: block.timestamp,
            userAddress: msg.sender
        });

        memos.push(newMemo);
        emit NewMemo(1, userName, twitterHandle, message, block.timestamp, msg.sender);
    }

    /**
     * @dev Function to withdraw the balance to the receiver address
     */
    function withdrawTips() public onlyOwner {
        uint256 balance = address(this).balance;
        if (balance == 0) {
            revert InsufficientFunds();
        }

        (bool sent, ) = receiver.call{value: balance}("");
        require(sent, "Failed to send Ether");
        emit Withdrawn(receiver, balance);
    }

    /**
     * @dev Function to get the memos
     */
    function getMemos(uint256 index, uint256 size) public view returns (Memo[] memory) {
        if (memos.length == 0) {
            return memos;
        }

        if (index >= memos.length) {
            revert InvalidArguments("Invalid index");
        }

        if (size > 25) {
            revert InvalidArguments("size must be <= 25");
        }

        uint256 effectiveSize = size;
        if (index + size > memos.length) {
            effectiveSize = memos.length - index;
        }

        Memo[] memory slice = new Memo[](effectiveSize);
        for (uint256 i = 0; i < effectiveSize; i++) {
            slice[i] = memos[index + i];
        }

        return slice;
    }

    /**
     * @dev Receive function to accept ether
     */
    receive() external payable {}
}

