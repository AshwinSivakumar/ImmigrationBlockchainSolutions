pragma solidity ^0.8.0;

contract VisaService {
    
    struct Visa {
        uint256 id;
        string visaType;
        string country;
        uint256 issueDate;
        uint256 expiryDate;
        bool isValid;
    }

    mapping(address => Visa[]) public visas;
    address public embassyAuthority; // Authority that approves visa applications
    uint256 public visaFee = 0.0 ether;

    event VisaIssued(address indexed applicant, uint256 visaId, string visaType, string country);
    event VisaRevoked(address indexed applicant, uint256 visaId);

    modifier onlyEmbassy() {
        require(msg.sender == embassyAuthority, "Not authorized");
        _;
    }

    constructor() {
        embassyAuthority = msg.sender; // Set embassy authority
    }
    
    function applyForVisa(
        address applicant, 
        uint256 visaId, 
        string memory visaType, 
        string memory country
    ) public payable onlyEmbassy {
        require(msg.value >= visaFee, "Insufficient payment");

        uint256 issueDate = block.timestamp;
        uint256 expiryDate = block.timestamp + 1 * 365 days; // 1 year visa

        Visa memory newVisa = Visa({
            id: visaId,
            visaType: visaType,
            country: country,
            issueDate: issueDate,
            expiryDate: expiryDate,
            isValid: true
        });

        visas[applicant].push(newVisa);
        emit VisaIssued(applicant, visaId, visaType, country);
    }

    function revokeVisa(address applicant, uint256 visaId) public onlyEmbassy {
        Visa[] storage userVisas = visas[applicant];
        for (uint256 i = 0; i < userVisas.length; i++) {
            if (userVisas[i].id == visaId && userVisas[i].isValid) {
                userVisas[i].isValid = false;
                emit VisaRevoked(applicant, visaId);
                break;
            }
        }
    }

    function getVisas(address applicant) public view returns (Visa[] memory) {
        return visas[applicant];
    }

    // Function to sync all visas with the passport expiry date
    function syncVisas(address applicant, uint256 newExpiryDate) public {
        Visa[] storage userVisas = visas[applicant];
        for (uint256 i = 0; i < userVisas.length; i++) {
            if (userVisas[i].isValid) {
                userVisas[i].expiryDate = newExpiryDate; // Update visa expiry to match passport expiry
            }
        }
    }
}


