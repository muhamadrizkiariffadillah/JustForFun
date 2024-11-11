// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.9;

contract BlockMessanger{

    uint public changeCounter;

    address public owner;

    string public message;

    constructor(){
        owner = msg.sender;
    }
    // 0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266

    function updateMessage(string memory _newMesssage)public {
        if(msg.sender == owner){
            message = _newMesssage;
            changeCounter++;
        }
    }

}