pragma solidity ^0.8.0;

contract PassportService {

    struct Passport {
        uint256 id;
        string name;
        string nationality;
        uint256 issueDate;
        uint256 expiryDate;
        bool isActive;
    }

    mapping(address => Passport) public passports;
    address public authority;
    uint public passportFee = 0 ether;  // Set to 0.0001 ether

    event PassportIssued(address indexed citizen, uint256 passportId);
    event PassportRenewed(address indexed citizen, uint256 newExpiryDate);
    event PassportRevoked(address indexed citizen);

    modifier onlyAuthority() {
        require(msg.sender == authority, "Not authorized");
        _;
    }

    constructor() {
        authority = msg.sender;
    }

    function issuePassport(
        address citizen, 
        uint256 passportId, 
        string memory name, 
        string memory nationality
    ) public payable onlyAuthority {
        require(msg.value >= passportFee, "Insufficient payment"); // Check the payment
        require(passports[citizen].id == 0, "Passport already issued");
        
        uint256 issueDate = block.timestamp;
        uint256 expiryDate = block.timestamp + 10 * 365 days; // 10 years expiry
        
        passports[citizen] = Passport({
            id: passportId,
            name: name,
            nationality: nationality,
            issueDate: issueDate,
            expiryDate: expiryDate,
            isActive: true
        });
        
        emit PassportIssued(citizen, passportId);
    }

    function renewPassport(address citizen) public payable onlyAuthority {
        require(msg.value >= passportFee, "Insufficient payment"); // Check the payment
        require(passports[citizen].isActive, "Passport is not active");

        passports[citizen].expiryDate = block.timestamp + 10 * 365 days; // Extend expiry by 10 years
        passports[citizen].isActive = true;  // Ensure the passport is active after renewal

        emit PassportRenewed(citizen, passports[citizen].expiryDate);
    }

    function revokePassport(address citizen) public onlyAuthority {
        require(passports[citizen].isActive, "Passport is already revoked");
        passports[citizen].isActive = false; // Deactivate the passport
        emit PassportRevoked(citizen); // Emit event for revocation
    }

    function getPassportDetails(address citizen) public view returns (Passport memory) {
        return passports[citizen]; // Return the details of the passport
    }
}
