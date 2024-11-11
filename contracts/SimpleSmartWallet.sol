// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

// Custom error to reduce gas.
error _NotOwnerSimpleWalet();
error _NotAutorizedSimpleWalet();
error _InsufficientBalanceSimpleWalet();
error _DepositShouldMoreThanZero();

contract SimpleWalet{
    // State variable
    address public owner;
    mapping(address => bool) public authorizedUsers;
    mapping(address => uint256) public balanceOfAccounts;
    
    // Event writes logs about the transaction
    event Deposit(address indexed sender,uint256 amount);
    event WithDrawal(address indexed receiver,uint256 amount);
    event Transfer(address indexed from,address indexed to,uint256 amount);
    event AuthorizedUsersAdded(address indexed user);
    event AuthorizedUserRemove(address indexed user);

    modifier onlyOwner(){
        if(msg.sender != owner) revert _NotOwnerSimpleWalet();
        _;
    }

    modifier OnlyAuthorizedUser(){
        if(!authorizedUsers[msg.sender]) revert _NotAutorizedSimpleWalet();
        _;
    }

    constructor(){
        owner = msg.sender;
    }

    function addAuthorizedUser(address _user)public onlyOwner{
        authorizedUsers[_user] = true;
        emit AuthorizedUsersAdded(_user);
    }

    function deposit()public payable {
        authorizedUsers[msg.sender] = true;
        balanceOfAccounts[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 _amount)public OnlyAuthorizedUser{
        uint256 balance = address(this).balance;
        if (balance < _amount) revert _InsufficientBalanceSimpleWalet();
        payable(msg.sender).transfer(_amount);
        emit WithDrawal(msg.sender, _amount);
    }

    function transferTo(address payable _to,uint256 _amount) public OnlyAuthorizedUser{
        uint256 balance = address(this).balance;
        if (balance < _amount) revert _InsufficientBalanceSimpleWalet();
        _to.transfer(_amount);
        emit Transfer(msg.sender, _to, _amount);
    }

    function getBalanceOfContract() public view returns(uint256){
        return address(this).balance;
    }
    
    function getBalanceOfMyWallet(address _myWallet)public view returns(uint256){
        return balanceOfAccounts[_myWallet];
    }
}