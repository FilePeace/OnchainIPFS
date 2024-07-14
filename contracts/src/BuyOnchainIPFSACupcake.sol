// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

/**
 * @title Memos
 * @dev Memo struct
 */
struct Memo {
    uint256 numCupcakes;
    string message;
    uint256 time;
    address userAddress;
}

/**
 * @title BuyMeACupcake
 * @dev BuyMeACupcake contract to accept donations and for our users to leave a memo for Onchain IPFS
 */
contract BuyOnchainIPFSACupcake {
    address public owner;
    address payable public receiver;
    uint256 public price;
    Memo[] public memos;
    bool public ownershipTransferred;

    error InsufficientFunds();
    error InvalidArguments(string message);
    error OnlyOwner();
    error OwnershipAlreadyTransferred();
    error WithdrawalFailed();

    event BuyMeACupcakeEvent(address indexed buyer, uint256 price);
    event NewMemo(address indexed userAddress, uint256 time, uint256 numCupcakes, string message);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event ReceiverChanged(address indexed previousReceiver, address indexed newReceiver);

    constructor() {
        owner = msg.sender;
        receiver = payable(msg.sender);
        price = 0.00004 ether;
        ownershipTransferred = false;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert OnlyOwner();
        }
        _;
    }

    /**
     * WRITE FUNCTIONS *************
     */

    /**
     * @dev Function to buy a coffee
     * @param numCupcakes Number of coffees to buy
     * @param message The message of the user
     */
    function buyCupcake(uint256 numCupcakes, string calldata message) public payable {
        if (msg.value < price * numCupcakes) {
            revert InsufficientFunds();
        }

        if (bytes(message).length == 0 || bytes(message).length > 1024) {
            revert InvalidArguments("Invalid message length");
        }

        memos.push(Memo(numCupcakes, message, block.timestamp, msg.sender));

        emit BuyMeACupcakeEvent(msg.sender, msg.value);
        emit NewMemo(msg.sender, block.timestamp, numCupcakes, message);
    }

    /**
     * @dev Function to remove a memo
     * @param index The index of the memo
     */
    function removeMemo(uint256 index) public {
        if (index >= memos.length) {
            revert InvalidArguments("Invalid index");
        }

        Memo memory memo = memos[index];

        if (memo.userAddress != msg.sender && msg.sender != owner) {
            revert InvalidArguments("Operation not allowed");
        }

        memos[index] = memos[memos.length - 1];
        memos.pop();
    }

    /**
     * @dev Function to modify a memo
     * @param index The index of the memo
     * @param message The new message for the memo
     */
    function modifyMemoMessage(uint256 index, string memory message) public {
        if (index >= memos.length) {
            revert InvalidArguments("Invalid index");
        }

        Memo storage memo = memos[index];

        if (memo.userAddress != msg.sender && msg.sender != owner) {
            revert InvalidArguments("Operation not allowed");
        }

        if (bytes(message).length == 0 || bytes(message).length > 1024) {
            revert InvalidArguments("Invalid message length");
        }

        memo.message = message;
    }

    /**
     * @dev Function to withdraw the balance
     */
    function withdrawTips() public onlyOwner {
        uint256 amount = address(this).balance;
        if (amount == 0) {
            revert InsufficientFunds();
        }

        (bool success,) = receiver.call{value: amount}("");
        if (!success) {
            revert WithdrawalFailed();
        }
    }

    /**
     * @dev Function to set the price of a coffee
     * @param _price New price for a coffee
     */
    function setPriceForCupcake(uint256 _price) public onlyOwner {
        price = _price;
    }

    /**
     * @dev Function to set the receiver of donations
     * @param _receiver New receiver address
     */
    function setReceiver(address payable _receiver) public onlyOwner {
        require(_receiver != address(0), "Invalid receiver address");
        address previousReceiver = receiver;
        receiver = _receiver;
        emit ReceiverChanged(previousReceiver, _receiver);
    }

    /**
     * @dev Function to transfer ownership of the contract
     * @param newOwner Address of the new owner
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid new owner address");
        if (ownershipTransferred) {
            revert OwnershipAlreadyTransferred();
        }
        address previousOwner = owner;
        owner = newOwner;
        ownershipTransferred = true;
        emit OwnershipTransferred(previousOwner, newOwner);
    }

    /**
     * READ FUNCTIONS *************
     */

    /**
     * @dev Function to get the memos
     * @param index Starting index for the slice
     * @param size Number of memos to return
     */
    function getMemos(uint256 index, uint256 size) public view returns (Memo[] memory) {
        if (memos.length == 0) {
            return new Memo[](0);
        }

        if (index >= memos.length) {
            revert InvalidArguments("Invalid index");
        }

        if (size > 25) {
            revert InvalidArguments("Size must be <= 25");
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
