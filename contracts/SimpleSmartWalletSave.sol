// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

error _NotAuthorizedUser();
error _InsufficientBalance();

contract SimpleWalletSave{
    // State Variable
    address public owner;

    // Map to save authorized users;
    mapping(address=>bool) public authorizedUsers;
    mapping(address=>uint256) public balanceOfUsers;

    // Events write logs.
    event Deposit(address indexed sender, uint256 amount);
    event WithDrawal(address indexed receiver, uint256 amount);
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event AuthorizedUserAdded(address indexed user);

    constructor(){
        owner = msg.sender;
    }

    modifier OnlyAuthorizedUser(){
        if(!authorizedUsers[msg.sender]) revert _NotAuthorizedUser();
        _;
    }

    modifier OnlyBalanceEnough(uint256 _amount){
        if (balanceOfUsers[msg.sender] < _amount) revert _InsufficientBalance();
        _;
    }

    function deposit() public payable {
        authorizedUsers[msg.sender] = true;
        balanceOfUsers[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
        emit AuthorizedUserAdded(msg.sender);
    }

    function withdraw(uint256 _amount) public OnlyAuthorizedUser OnlyBalanceEnough(_amount){
        balanceOfUsers[msg.sender] -= _amount;
        payable(msg.sender).transfer(_amount);
        emit WithDrawal(msg.sender, _amount);
    }

    
    function transferTo(address payable _to,uint256 _amount) public OnlyAuthorizedUser OnlyBalanceEnough(_amount){
        balanceOfUsers[msg.sender] -= _amount;
        _to.transfer(_amount);
        emit Transfer(msg.sender, _to, _amount);
    }
}