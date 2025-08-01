// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract UdayCoin is ERC20 {
    address public owner;

    constructor(uint256 initialSupply) ERC20("UdayCoin", "UDY") {
        owner = msg.sender;
        _mint(msg.sender, initialSupply);
    }

    function mint(address to, uint256 amount) public {
        require(msg.sender == owner, "Only owner can mint");
        _mint(to, amount);
    }
    
}
