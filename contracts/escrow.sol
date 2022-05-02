// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Escrow {
    enum Status {
        Created,
        OnBoarded,
        Funded,
        Approved,
        Completed
    }
    struct partyContract {
        address creditor;
        address debtor;
        uint256 amount;
        string description;
        Status status;
        uint256 initiator;
    }
    partyContract[] public contracts;
    mapping(uint256 => uint256) public allFunds;

    function intiateParty(
        address _creditor,
        address _debtor,
        string calldata _description,
        uint256 _amount,
        uint256 _initiator
    ) external {
        partyContract memory initiate = partyContract(
            _creditor,
            _debtor,
            _amount,
            _description,
            Status.Created,
            _initiator
        );
        contracts.push(initiate);
    }

    // both party to be onboarded before funding
    function onBoard(uint256 _id) public {
        partyContract storage data = contracts[_id];
        if (data.initiator == 0) {
            require(
                msg.sender == data.creditor,
                "only creditor can call this function!"
            );
            data.status = Status.OnBoarded;
        } else {
            require(
                msg.sender == data.debtor,
                "only debtor can call this function!"
            );
            data.status = Status.OnBoarded;
        }
    }

    function fundContract(uint256 _id)
        public
        payable
        onlyDebtor(_id)
        checkContract(_id)
    {
        partyContract storage data = contracts[_id];
        require(
            data.status == Status.OnBoarded,
            "parties are not onboarded yet!"
        );
        require(
            msg.value == data.amount,
            "the amount should be equal to the aggred terms"
        );
        allFunds[_id] = msg.value;
        data.status = Status.Funded;
    }

    // approve by debtor so that creditor can withdraw
    function ApproveContract(uint256 _id) public onlyDebtor(_id) {
        partyContract storage data = contracts[_id];
        data.status = Status.Approved;
    }

    function withdraw(uint256 _id) public payable onlyCreditor(_id) {
        partyContract storage data = contracts[_id];
        require(
            data.status == Status.Approved,
            "transaction is not approved by debtor"
        );
        address creditor = contracts[_id].creditor;
        payable(creditor).transfer(data.amount);
        data.status = Status.Completed;
    }

    modifier onlyCreditor(uint256 id) {
        address creditor = contracts[id].creditor;
        require(
            msg.sender == creditor,
            "only creditor can call this function!"
        );
        _;
    }
    modifier onlyDebtor(uint256 id) {
        address debtor = contracts[id].debtor;
        require(msg.sender == debtor, "only debtor can call this function!");
        _;
    }
    modifier checkContract(uint256 id) {
        uint256 length = contracts.length;
        require(length != 0 && length > id, "contract is not present!");
        _;
    }
}
