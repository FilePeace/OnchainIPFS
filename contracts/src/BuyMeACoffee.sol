// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

/**
 * @title Memos
 * @dev Memo struct
 */
struct Memo {
    uint256 numCoffees;
    string userName;
    string twitterHandle;
    string message;
    uint256 time;
    address userAddress;
}

/**
 * @title BuyMeACoffee
 * @dev BuyMeACoffee contract to accept donations and for our users to leave a memo for us
 */
contract BuyMeACoffee {
    address public owner;
    address payable public receiver;
    uint256 public price;
    Memo[] public memos;
    bool public ownershipTransferred;
    bool private _locked; // Reentrancy guard

    error InsufficientFunds();
    error InvalidArguments(string message);
    error OnlyOwner();
    error OnlyReceiver();
    error OwnershipAlreadyTransferred();
    error ReentrancyGuard();

    event BuyMeACoffeeEvent(address indexed buyer, uint256 price);
    event NewMemo(
        address indexed userAddress,
        uint256 time,
        uint256 numCoffees,
        string userName,
        string twitterHandle,
        string message
    );
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event ReceiverUpdated(address indexed previousReceiver, address indexed newReceiver);
    event PriceUpdated(uint256 oldPrice, uint256 newPrice);
    event MemoRemoved(uint256 indexed index);
    event MemoModified(uint256 indexed index, string newMessage);

    constructor() {
        owner = msg.sender;
        receiver = payable(msg.sender);
        price = 0.0001 ether;
        ownershipTransferred = false;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert OnlyOwner();
        }
        _;
    }

    modifier onlyReceiver() {
        if (msg.sender != receiver) {
            revert OnlyReceiver();
        }
        _;
    }

    modifier nonReentrant() {
        if (_locked) {
            revert ReentrancyGuard();
        }
        _locked = true;
        _;
        _locked = false;
    }

    /**
     * WRITE FUNCTIONS *************
     */

    /**
     * @dev Function to buy a coffee
     * @param  numCoffees The number of coffees to buy
     * @param  userName The name of the user
     * @param  twitterHandle The Twitter handle of the user
     * @param  message The message of the user
     */
    function buyCoffee(
        uint256 numCoffees,
        string calldata userName,
        string calldata twitterHandle,
        string calldata message
    ) public payable {
        if (numCoffees == 0) {
            revert InvalidArguments("Number of coffees must be greater than zero");
        }
        uint256 totalPrice = price * numCoffees;
        if (msg.value < totalPrice) {
            revert InsufficientFunds();
        }

        if (bytes(userName).length == 0 && bytes(message).length == 0) {
            revert InvalidArguments("Invalid userName or message");
        }

        if (bytes(userName).length > 75 || bytes(twitterHandle).length > 75 || bytes(message).length > 1024) {
            revert InvalidArguments("Input parameter exceeds max length");
        }

        memos.push(Memo(numCoffees, userName, twitterHandle, message, block.timestamp, msg.sender));

        emit BuyMeACoffeeEvent(msg.sender, msg.value);
        emit NewMemo(msg.sender, block.timestamp, numCoffees, userName, twitterHandle, message);
    }

    /**
     * @dev Function to remove a memo
     * @param  index The index of the memo
     */
    function removeMemo(uint256 index) public {
        if (index >= memos.length) {
            revert InvalidArguments("Invalid index");
        }

        Memo memory memo = memos[index];

        if (memo.userAddress != msg.sender && msg.sender != owner) {
            revert InvalidArguments("Operation not allowed");
        }
        Memo memory indexMemo = memos[index];
        memos[index] = memos[memos.length - 1];
        memos[memos.length - 1] = indexMemo;
        memos.pop();

        emit MemoRemoved(index);
    }

    /**
     * @dev Function to modify a memo
     * @param  index The index of the memo
     * @param  message The new message of the memo
     */
    function modifyMemoMessage(uint256 index, string memory message) public {
        if (index >= memos.length) {
            revert InvalidArguments("Invalid index");
        }

        Memo storage memo = memos[index];

        if (memo.userAddress != msg.sender && msg.sender != owner) {
            revert InvalidArguments("Operation not allowed");
        }

        if (bytes(message).length > 1024) {
            revert InvalidArguments("Message exceeds max length");
        }

        memo.message = message;

        emit MemoModified(index, message);
    }

    /**
     * @dev Function to withdraw the balance
     */
    function withdrawTips() public onlyReceiver nonReentrant {
        uint256 amount = address(this).balance;
        if (amount == 0) {
            revert InsufficientFunds();
        }

        (bool sent,) = receiver.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }

    /**
     * @dev Function to set the receiver of donations
     * @param newReceiver The address of the new receiver
     */
    function setReceiver(address payable newReceiver) public onlyOwner {
        require(newReceiver != address(0), "Invalid receiver address");
        address oldReceiver = receiver;
        receiver = newReceiver;
        emit ReceiverUpdated(oldReceiver, newReceiver);
    }

    /**
     * @dev Function to transfer ownership of the contract
     * @param newOwner The address of the new owner
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid owner address");
        if (ownershipTransferred) {
            revert OwnershipAlreadyTransferred();
        }
        address oldOwner = owner;
        owner = newOwner;
        ownershipTransferred = true;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    /**
     * @dev Function to set the price of a coffee
     * @param newPrice The new price of a coffee
     */
    function setPrice(uint256 newPrice) public onlyOwner {
        require(newPrice > 0, "Price must be greater than zero");
        uint256 oldPrice = price;
        price = newPrice;
        emit PriceUpdated(oldPrice, newPrice);
    }

    /**
     * READ FUNCTIONS *************
     */

    /**
     * @dev Function to get the memos
     */
    function getMemos(uint256 index, uint256 size) public view returns (Memo[] memory) {
        if (memos.length == 0) {
            return new Memo[](0);
        }

        if (index >= memos.length) {
            revert InvalidArguments("Invalid index");
        }

        if (size > 25) {
            revert InvalidArguments("size must be <= 25");
        }

        uint256 effectiveSize = size;
        if (index + size > memos.length) {
            // Adjust the size if it exceeds the array's bounds
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
