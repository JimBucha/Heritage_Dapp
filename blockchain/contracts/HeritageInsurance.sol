// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeritageInsurance {
    // Structs
    struct Policy {
        uint256 policyId;
        address policyholder;
        string policyType;
        uint256 premium; // in wei
        uint256 startDate;
        uint256 endDate;
        string ipfsHash;
        bool isActive;
    }

    struct Claim {
        uint256 claimId;
        uint256 policyId;
        address claimant;
        string ipfsEvidence;
        uint256 claimAmount; // in wei
        bool isApproved;
    }

    // State Variables
    address public admin;
    address public claimsManager;
    uint256 public policyCount;
    uint256 public claimCount;
    mapping(uint256 => Policy) public policies;
    mapping(uint256 => Claim) public claims;
    mapping(uint256 => uint256) public policyPremiums; // Tracks total premiums paid per policy (NEW)

    // Events
    event PolicyCreated(uint256 policyId, address indexed policyholder, string policyType);
    event ClaimSubmitted(uint256 claimId, uint256 indexed policyId);
    event ClaimApproved(uint256 claimId, uint256 payoutAmount);
    event PremiumPaid(uint256 indexed policyId, uint256 amount); // Updated event

    // Modifiers
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin");
        _;
    }

    modifier onlyClaimsManager() {
        require(msg.sender == claimsManager, "Only claims manager");
        _;
    }

    // Constructor
    constructor() {
        admin = msg.sender;
        claimsManager = msg.sender; // Default: admin is also claims manager
    }

    // --------------------------
    // Existing Functions (Your Code)
    // --------------------------
    function createPolicy(
        address _policyholder,
        string memory _policyType,
        uint256 _premium,
        uint256 _duration,
        string memory _ipfsHash
    ) external onlyAdmin {
        policyCount++;
        policies[policyCount] = Policy(
            policyCount,
            _policyholder,
            _policyType,
            _premium,
            block.timestamp,
            block.timestamp + _duration,
            _ipfsHash,
            true
        );
        emit PolicyCreated(policyCount, _policyholder, _policyType);
    }

    function submitClaim(uint256 _policyId, string memory _ipfsEvidence, uint256 _claimAmount) external {
        Policy storage policy = policies[_policyId];
        require(policy.isActive, "Policy inactive");
        claimCount++;
        claims[claimCount] = Claim(
            claimCount,
            _policyId,
            msg.sender,
            _ipfsEvidence,
            _claimAmount,
            false
        );
        emit ClaimSubmitted(claimCount, _policyId);
    }

    // --------------------------
    // Updated/New Functions
    // --------------------------
    // Pay premium in ETH (updated to track total premiums)
    function payPremium(uint256 _policyId) external payable {
        Policy storage policy = policies[_policyId];
        require(policy.policyholder == msg.sender, "Not policyholder");
        require(msg.value == policy.premium, "Incorrect premium amount");
        policyPremiums[_policyId] += msg.value; // Track cumulative premiums (NEW)
        emit PremiumPaid(_policyId, msg.value);
    }

    // Approve claim (new function)
    function approveClaim(uint256 _claimId) external onlyClaimsManager {
        Claim storage claim = claims[_claimId];
        require(!claim.isApproved, "Claim already approved");
        claim.isApproved = true;
        payable(claim.claimant).transfer(claim.claimAmount);
        emit ClaimApproved(_claimId, claim.claimAmount);
    }

    // Withdraw ETH (existing function)
    function withdrawFunds() external onlyAdmin {
        payable(admin).transfer(address(this).balance);
    }

    // --------------------------
    // Helper Functions (Optional)
    // --------------------------
    function setClaimsManager(address _newManager) external onlyAdmin {
        claimsManager = _newManager;
    }
}