// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Project {
    struct Contract {
        address payable client;
        address payable freelancer;
        uint256 amount;
        string description;
        bool isCompleted;
        bool isPaid;
        uint256 deadline;
    }

    mapping(uint256 => Contract) public contracts;
    uint256 public contractCount;

    event ContractCreated(
        uint256 indexed contractId,
        address indexed client,
        address indexed freelancer,
        uint256 amount,
        uint256 deadline
    );

    event ContractCompleted(uint256 indexed contractId);
    event PaymentReleased(uint256 indexed contractId, uint256 amount);

    modifier onlyClient(uint256 _contractId) {
        require(
            msg.sender == contracts[_contractId].client,
            "Only client can call this"
        );
        _;
    }

    modifier onlyFreelancer(uint256 _contractId) {
        require(
            msg.sender == contracts[_contractId].freelancer,
            "Only freelancer can call this"
        );
        _;
    }

    // Core Function 1: Create a new freelance contract with escrow
    function createContract(
        address payable _freelancer,
        string memory _description,
        uint256 _deadline
    ) public payable returns (uint256) {
        require(msg.value > 0, "Contract amount must be greater than 0");
        require(_freelancer != address(0), "Invalid freelancer address");
        require(_deadline > block.timestamp, "Deadline must be in the future");

        contractCount++;
        contracts[contractCount] = Contract({
            client: payable(msg.sender),
            freelancer: _freelancer,
            amount: msg.value,
            description: _description,
            isCompleted: false,
            isPaid: false,
            deadline: _deadline
        });

        emit ContractCreated(
            contractCount,
            msg.sender,
            _freelancer,
            msg.value,
            _deadline
        );

        return contractCount;
    }

    // Core Function 2: Freelancer marks work as completed
    function submitWork(uint256 _contractId)
        public
        onlyFreelancer(_contractId)
    {
        Contract storage c = contracts[_contractId];
        require(!c.isCompleted, "Work already submitted");
        require(!c.isPaid, "Contract already paid");

        c.isCompleted = true;
        emit ContractCompleted(_contractId);
    }

    // Core Function 3: Client approves and releases payment
    function releasePayment(uint256 _contractId) public onlyClient(_contractId) {
        Contract storage c = contracts[_contractId];
        require(c.isCompleted, "Work not completed yet");
        require(!c.isPaid, "Payment already released");

        c.isPaid = true;
        c.freelancer.transfer(c.amount);

        emit PaymentReleased(_contractId, c.amount);
    }

    // Helper function to get contract details
    function getContract(uint256 _contractId)
        public
        view
        returns (
            address client,
            address freelancer,
            uint256 amount,
            string memory description,
            bool isCompleted,
            bool isPaid,
            uint256 deadline
        )
    {
        Contract memory c = contracts[_contractId];
        return (
            c.client,
            c.freelancer,
            c.amount,
            c.description,
            c.isCompleted,
            c.isPaid,
            c.deadline
        );
    }
}
