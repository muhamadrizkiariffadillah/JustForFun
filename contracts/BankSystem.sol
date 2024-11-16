//https://sepolia.explorer.zksync.io/address/0x0c3ebaa12A4E50444043260789e114b61B940b0D (contract Address)
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

contract BankSystem{
    address immutable owner; // 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
    uint immutable minimumDeposit; 
    constructor(){
        owner=msg.sender;
        minimumDeposit=1e18;
    }
    modifier onlyOwner(){
        require(msg.sender==owner,"You Are Not Authorized to Execute This Transaction ");
        _;
    }

    modifier authorizedCustomer{
        require(ApprovedcustomerList[msg.sender],"You are not a customer of the Bank");
        _;
    }

   
    mapping(address=>bool) ApprovedcustomerList;
    // 2fa
    mapping(address=>uint) ApprovedcustomerPin;
    mapping (address=>uint ) depositAmount;
    mapping(address=>bool) AccountCreationRequest;



    function addingcustomer(address _customer_addr,uint _pin) 
    public 
    onlyOwner
    {
        ApprovedcustomerList[_customer_addr]=true;
        ApprovedcustomerPin[_customer_addr]=_pin;
    }
    function depositEther() public payable authorizedCustomer  {
        require(msg.value>minimumDeposit,"The Minimum Deposit Amount Should be 1ETH");
            depositAmount[msg.sender]+=msg.value;
    }

     function withdrawEther(uint _amount,uint _pin) public  authorizedCustomer {
        require(_amount<depositAmount[msg.sender],"There is Insufficient Balance to Withdraw the Amount");
        //to mitigate reentracny Attack
        require(ApprovedcustomerPin[msg.sender]==_pin,"You Entered The wrong Pin Number");
        (bool success, ) = msg.sender.call{value: _amount}("");
        require(success, "Transfer failed");
        depositAmount[msg.sender]-=_amount;
    }

    function getBalance() public view returns(uint){
        return depositAmount[msg.sender];
    }
    
    function requestAccountcreation() public{
        require(!AccountCreationRequest[msg.sender],"You Have Already Requested for Account creation");
        require(!ApprovedcustomerList[msg.sender],"You Are Already a Customer of the Bank");
        AccountCreationRequest[msg.sender]=true;
    }

    function OwnerApprovingrequest(address _address,uint _pin,bool _response) public onlyOwner{
         require(AccountCreationRequest[_address],"No Request Found For this address");
         if(_response){
            ApprovedcustomerList[_address]=true;
            ApprovedcustomerPin[_address]=_pin;
         }
         delete AccountCreationRequest[_address];
    }

    function changePin(uint _oldPin,uint _newPin) public authorizedCustomer{
        require(ApprovedcustomerPin[msg.sender]==_oldPin,"You Entered the Wrong Pin");
        ApprovedcustomerPin[msg.sender]=_newPin;
    }

}