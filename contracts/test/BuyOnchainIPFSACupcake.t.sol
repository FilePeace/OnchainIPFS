// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Test, console2} from "forge-std/Test.sol";
import {BuyOnchainIPFSACupcake, Memo} from "../src/BuyOnchainIPFSACupcake.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract BuyOnchainIPFSACupcakeTest is Test {
    BuyOnchainIPFSACupcake public buyOnchainIpfsACupcake;
    uint256 numCupcakes = 1;
    string message = "message";

    function setUp() public {
        buyOnchainIpfsACupcake = new BuyOnchainIPFSACupcake();
    }

    function testGetMemos() public {
        buyOnchainIpfsACupcake.buyCupcake{value: 0.0001 ether}(numCupcakes, message);
        assertEq(buyOnchainIpfsACupcake.getMemos(0, 10).length, 1);
        Memo memory memo = buyOnchainIpfsACupcake.getMemos(0, 10)[0];
        assertEq(memo.message, message);
    }

    function testRemoveMemo() public {
        buyOnchainIpfsACupcake.buyCupcake{value: 0.0001 ether}(numCupcakes, message);
        assertEq(buyOnchainIpfsACupcake.getMemos(0, 10).length, 1);
        buyOnchainIpfsACupcake.buyCupcake{value: 0.0001 ether}(numCupcakes, "testMessage");
        buyOnchainIpfsACupcake.removeMemo(0);
        assertEq(buyOnchainIpfsACupcake.getMemos(0, 10)[0].message, "testMessage");
    }

    function testModifyMemoMessage() public {
        buyOnchainIpfsACupcake.buyCupcake{value: 0.0001 ether}(numCupcakes, message);
        assertEq(buyOnchainIpfsACupcake.getMemos(0, 10).length, 1);
        buyOnchainIpfsACupcake.modifyMemoMessage(0, "new message");
        Memo memory memo = buyOnchainIpfsACupcake.getMemos(0, 10)[0];
        assertEq(memo.message, "new message");
    }

    function testWithdrawTips() public {
        buyOnchainIpfsACupcake.buyCupcake{value: 0.0001 ether}(numCupcakes, message);
        buyOnchainIpfsACupcake.withdrawTips();
        assertEq(address(buyOnchainIpfsACupcake).balance, 0);
    }

    function testPaging() public {
        uint256 amtToAdd = 100;
        for (uint256 i = 0; i < amtToAdd; i++) {
            buyOnchainIpfsACupcake.buyCupcake{value: 0.0001 ether}(1, Strings.toString(i));
        }
        for (uint256 i = 0; i < amtToAdd; i++) {
            Memo[] memory memos = buyOnchainIpfsACupcake.getMemos(i, 1);
            assertEq(memos.length, 1);
        }
    }

    function generateLongString(uint256 len) public returns (string memory) {
        string memory baseString = "a";
        string memory longString = "";
        for (uint256 i = 0; i < len; i++) {
            longString = string(abi.encodePacked(longString, baseString));
        }
        return longString;
    }

    function testMaxMemoMessageSize() public {
        vm.expectRevert();
        buyOnchainIpfsACupcake.buyCupcake{value: 0.0001 ether}(numCupcakes, generateLongString(1026));
    }

    function testMaxMemoAllSizesAtMaximumShouldAccept() public {
        buyOnchainIpfsACupcake.buyCupcake{value: 0.0001 ether}(numCupcakes, generateLongString(1024));
    }

    function testEmptyMemoNoError() public {
        Memo[] memory memos = buyOnchainIpfsACupcake.getMemos(15, 0);
        assertEq(memos.length, 0);
    }

    function testInvalidIndexErrors() public {
        buyOnchainIpfsACupcake.buyCupcake{value: 0.0001 ether}(numCupcakes, message);

        vm.expectRevert();
        Memo[] memory memos = buyOnchainIpfsACupcake.getMemos(15, 10);
    }

    function testSetPriceForCupcake() public {
        buyOnchainIpfsACupcake.setPriceForCupcake(0.0002 ether);
        buyOnchainIpfsACupcake.buyCupcake{value: 0.0002 ether}(numCupcakes, message);
        assertEq(buyOnchainIpfsACupcake.getMemos(0, 10).length, 1);
    }

    /**
     * @dev Recieve function to accept ether
     */
    receive() external payable {}
}
