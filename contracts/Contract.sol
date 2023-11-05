// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Complaint {
    address public officer;
    address public owner;
    uint256 public nextId;
    uint256[] public pendingApprovals;
    uint256[] public pendingResolutions;
    uint256[] public resolvedCaes;
    constructor(address _officer) {
        owner = msg.sender;
        officer=_officer;
        nextId = 1;
    }
    
    struct complaint {
        uint256 id;
        address complaintRegisteredBy;
        string title;
        string description;
        string approvalRemark;
        string resolutionRemark;
        bool isApproved;
        bool isResolved;
        bool exist;
    }

    modifier onlyOfficer() {
        require(msg.sender==officer,"You are not officer");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender==owner,"You are not owner");
        _;
    }

    event complaintFiled(uint256 id,address complaintRegisteredBy,string title);

    mapping (uint256 => complaint) public Complaints;

    function fileComplaint(string memory _title, string memory _description) public {
        complaint storage newComplaint = Complaints[nextId];
        newComplaint.id = nextId;
        newComplaint.complaintRegisteredBy = msg.sender;
        newComplaint.title= _title;
        newComplaint.description = _description;
        newComplaint.approvalRemark="Pending approval";
        newComplaint.resolutionRemark ="Pending resolution";
        newComplaint.isApproved= false;
        newComplaint.isResolved=false;
        newComplaint.exist = true;
        emit complaintFiled(nextId,msg.sender,_title);
        nextId++;
    }

    function approveComplaint(uint256 _id,string memory _approvalRemark) public onlyOfficer{
        require(Complaints[_id].exist == true,"This complaint id does not exists");
        require(Complaints[_id].isApproved == false,"Complaint is already approved");
        Complaints[_id].isApproved = true;
        Complaints[_id].approvalRemark = _approvalRemark; 
    }

    function declineComplaint(uint256 _id,string memory _approvalRemark) public onlyOfficer{
        require(Complaints[_id].exist == true,"This complaint id does not exists");
        require(Complaints[_id].isApproved == false,"Complaint is already approved");
        Complaints[_id].isApproved = false;
        Complaints[_id].approvalRemark = string.concat( "Complaint rejected because:",_approvalRemark); 
    }

    function resolveComplaint(uint256 _id,string memory _resolutionRemark) public onlyOfficer{
        require(Complaints[_id].exist == true,"This complaint id does not exists");
        require(Complaints[_id].isApproved == true,"Complaint is not approved");
        require(Complaints[_id].isResolved == false,"Complaint is already resolved");
        Complaints[_id].isResolved = true;
        Complaints[_id].resolutionRemark = _resolutionRemark; 
    }

    function calcPendingApprovals() public {
        delete pendingApprovals;
        for (uint256 i = 1;i < nextId;i++) {
            if (Complaints[i].isApproved == false && Complaints[i].exist == true) {
                pendingApprovals.push(Complaints[i].id);
            }
        }
    }

    function calcpendingResolutions() public {
        delete pendingResolutions;
        for (uint256 i = 1;i < nextId;i++) {
            if (Complaints[i].isResolved == false && Complaints[i].isApproved == true && Complaints[i].exist == true) {
                pendingResolutions.push(Complaints[i].id);
            }
        }
    }

    function calcResolvedIds() public {
        delete resolvedCaes;
        for (uint256 i = 1;i < nextId;i++) {
            if (Complaints[i].isResolved == true && Complaints[i].isApproved == true && Complaints[i].exist == true) {
                resolvedCaes.push(Complaints[i].id);
            }
        }
    }

    function setOfficerAddress(address _officer) public onlyOwner {
        owner= _officer;
    }
}