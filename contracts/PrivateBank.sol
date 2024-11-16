// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

contract PrivateBank{

    // Tracking logs
    event Deposit(
        address indexed user,
        uint256 amount,
        uint256 timestamp
    );
    
    event Withdraw(
        address indexed user,
        uint256 amount,
        uint256 timestamp
    );

    event Transfer( 
        address indexed from,
        address indexed to,
        uint256 amount,
        uint256 timestamp
    );

    struct Account{
        address walletUser;
        uint256 balance;
        uint256 pin;
        bool isApproved;
        uint256 createdAt;
    }

    // State variables
    address immutable owner;
    uint256 immutable contract_fee;

    mapping(address=>Account)  user;

    constructor(uint256 _ownerPin){
        owner = msg.sender;
        contract_fee = 1000;
        user[msg.sender].walletUser = msg.sender;
        user[msg.sender].isApproved = true;
        user[msg.sender].pin = _ownerPin;
        user[msg.sender].createdAt = block.timestamp;
    }

    modifier OnlyOwner(){
        require(msg.sender == owner,"you are not the owner");
        _;
    }

    modifier OnlyAutorizedUser(){
        require(user[msg.sender].isApproved,"you are not our customer");
        _;
    }

    modifier OnlyTruePin(uint256 _pin){
        require(user[msg.sender].pin == _pin,"pin is wrong");
        _;
    }
    
    modifier SufficientBalance(uint256 _amount){
        require(_amount < user[msg.sender].balance,"insufficient balance");
        _;
    }

    function addCustomer(address _newCustomer, uint256 _pin)
    external 
    OnlyOwner
    {
        user[_newCustomer].walletUser = _newCustomer;
        user[_newCustomer].pin = _pin;
        user[_newCustomer].isApproved = true;
    }

    function  approveNewCustomer(address _newCustomer) 
    external 
    OnlyOwner{
        user[_newCustomer].isApproved = true;
    }
    
    function requestBeCustomer(uint256 _myPin) external{
        user[msg.sender].walletUser = msg.sender;
        user[msg.sender].pin = _myPin;
        user[msg.sender].isApproved = false;
        user[msg.sender].createdAt = block.timestamp;
    }

    function deposit()external payable OnlyAutorizedUser{
        user[msg.sender].balance += msg.value;
        emit Deposit(msg.sender, msg.value, block.timestamp);
    }

    function withdraw(uint256 _amount, uint256 _pin) external 
    OnlyAutorizedUser 
    SufficientBalance(_amount)
    OnlyTruePin(_pin)
    {
        uint256 _amountAfterfee = _amount - contract_fee;

        user[msg.sender].balance -= _amountAfterfee;
        
        user[owner].balance += contract_fee;
        
        (bool successUser,) = msg.sender.call{value: _amountAfterfee}("");
        require(successUser,"transfer failed");


        emit Withdraw(msg.sender,_amount,block.timestamp);
    }
    
    function transfer(address payable _to,uint256 _amount, uint256 _pin) external 
    OnlyAutorizedUser 
    SufficientBalance(_amount)
    OnlyTruePin(_pin)
    {
        uint256 _amountAfterfee = _amount - contract_fee;
    
        user[msg.sender].balance -= _amount;

        user[owner].balance += contract_fee;
        
        _to.transfer(_amountAfterfee);

        emit Transfer(msg.sender,_to,_amountAfterfee,block.timestamp);
    }

    function getMyBalance() public view returns(uint256){
        return user[msg.sender].balance;
    }
}