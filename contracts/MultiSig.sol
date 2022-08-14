// //SPDX-License-Identifier: BUSL-1.1
// pragma solidity >=0.7.0 <0.9.0;


// contract MultiSigWallet{
//     address private owner;
//     mapping (address => uint8) private managers;
    
//     modifier isOwner{
//         require(owner == msg.sender);
//         _;
//     }
    
//     modifier isManager{
//         require(
//             msg.sender == owner || managers[msg.sender] == 1);
//         _;
//     }
    
//     uint constant MIN_SIGNATURES = 3;
//     uint private transactionIdx;
    
//     struct Transaction {
//         address from;
//         address to;
//         uint amount;
//         uint8 signatureCount;
//         mapping (address => uint8) signatures;
//     }
    
//     mapping (uint => Transaction) private transactions;
//     uint[] private pendingTransactions;
    
//     constructor() public{
//         owner = msg.sender;
//     }
    
//     event DepositFunds(address from, uint amount);
//     event TransferFunds(address to, uint amount);
//     event TransactionCreated(
//         address from,
//         address to,
//         uint amount,
//         uint transactionId
//         );
    
//     function addManager(address manager) public isOwner{
//         managers[manager] = 1;
//     }
    
//     function removeManager(address manager) public isOwner{
//         managers[manager] = 0;
//     }
    
//     function withdraw(uint amount) isManager public{
//         transferTo(msg.sender, amount);
//     }
//     function transferTo(address to,  uint amount) isManager public{
//         require(address(this).balance >= amount);
//         uint transactionId = transactionIdx++;
        
//         Transaction memory transaction;
//         transaction.from = msg.sender;
//         transaction.to = to;
//         transaction.amount = amount;
//         transaction.signatureCount = 0;
//         transactions[transactionId] = transaction;
//         pendingTransactions.push(transactionId);
//         emit TransactionCreated(msg.sender, to, amount, transactionId);
//     }
    
//     function getPendingTransactions() public isManager view returns(uint256[] memory){
//         return pendingTransactions;
//     }
    
//     function signTransaction(uint transactionId) public isManager{
//         Transaction storage transaction = transactions[transactionId];
//         require(0x0 != transaction.from);
//         require(msg.sender != transaction.from);
//         require(transaction.signatures[msg.sender]!=1);
//         transaction.signatures[msg.sender] = 1;
//         transaction.signatureCount++;
        
//         if(transaction.signatureCount >= MIN_SIGNATURES){
//             require(address(this).balance >= transaction.amount);
//             transaction.to.transfer(transaction.amount);
//             emit TransferFunds(transaction.to, transaction.amount);
//             deleteTransactions(transactionId);
//         }
//     }
    
//     function deleteTransactions(uint transacionId) public isManager{
//         uint8 replace = 0;
//         for(uint i = 0; i< pendingTransactions.length; i++){
//             if(1==replace){
//                 pendingTransactions[i-1] = pendingTransactions[i];
//             }else if(transacionId == pendingTransactions[i]){
//                 replace = 1;
//             }
//         } 
//         delete pendingTransactions[pendingTransactions.length - 1];
//         pendingTransactions.length--;
//         delete transactions[transacionId];
//     }
    
//     function walletBalance() public isManager view returns(uint){
//         return address(this).balance;
//     }

//     fallback() external payable {}
//     receive() external payable {}
// }

