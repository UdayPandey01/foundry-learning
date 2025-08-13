// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe public fundMe;

    address USER = makeAddr("user"); 
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() public {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumUsd() public view {
        assertEq(fundMe.MINIMUM_USD(), 5 * 10 ** 18);
    }

    function testOwnerIsMsgSender() public view {
        console.log("Owner address:", msg.sender);
        console.log("FundMe owner address:", fundMe.i_owner());
        assertEq(fundMe.i_owner(), msg.sender);
    }

    function testPriceFeedversionIsAccurate() public view {
        if (block.chainid == 11155111) {
            uint256 version = fundMe.getVersion();
            assertEq(version, 4);
        } else if (block.chainid == 1) {
            uint256 version = fundMe.getVersion();
            assertEq(version, 6);
        }
    }

    function testFundFailWithoutEnoughETH() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundUpdateFundedDataStruture() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        uint256 fundedAmount = fundMe.getAddressToAmountFunded(USER);
        assertEq(fundedAmount, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunder() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded{
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded {
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        assertEq(address(fundMe).balance, 0);
        assertEq(fundMe.getOwner().balance, startingOwnerBalance + startingFundMeBalance);
    }

    function testWithdrawFromMultipleFunders() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for(uint160 i = startingFunderIndex; i < numberOfFunders; i++){
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.getOwner().balance;

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        assertEq(address(fundMe).balance, 0);
        assertEq(fundMe.getOwner().balance, startingOwnerBalance + startingFundMeBalance);
    }
}