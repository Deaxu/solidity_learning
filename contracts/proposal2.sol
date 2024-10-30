// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract proposalContract{
    
    address owner;
    uint256 counter;

    constructor (){
        owner = msg.sender;
        voted_addresses.push(msg.sender);
    }

    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }

    modifier active() {
        require(proposal_history[counter].is_active == true, "The proposal is not active");
        _;
    }

    modifier newVoter(address _address) {
        require(!isVoted(_address), "Address has already voted");
        _;
    }

    struct Proposal{
        string title;
        string description;
        uint256 approve;
        uint256 reject;
        uint256 pass;
        uint total_vote_to_end;
        bool current_state;
        bool is_active;
        mapping(address => bool) hasVoted;
    }
    
    mapping (uint256 => Proposal) proposal_history;
    address[]  private voted_addresses;

    function isVoted(address _address) public view returns (bool) {
        for (uint i = 0; i < voted_addresses.length; i++) {
            if (voted_addresses[i] == _address) {
                return true;
            }
        }
        return false;
    }

    function vote(uint8 choice) external active newVoter(msg.sender){
        Proposal storage proposal = proposal_history[counter];
        uint256 total_vote = proposal.approve + proposal.reject + proposal.pass;

        voted_addresses.push(msg.sender);

        if (choice == 1) {
            proposal.approve += 1;
            proposal.current_state = calculateCurrentState();
        } else if (choice == 2) {
            proposal.reject += 1;
            proposal.current_state = calculateCurrentState();
        } else if (choice == 0) {
            proposal.pass += 1;
            proposal.current_state = calculateCurrentState();
        }

        if ((proposal.total_vote_to_end - total_vote == 1) && (choice == 1 || choice == 2 || choice == 0)) {
            proposal.is_active = false;
            voted_addresses = [owner];
        }
    }

    function calculateCurrentState() private view returns(bool) {
        Proposal storage proposal = proposal_history[counter];

        uint256 approve = proposal.approve;
        uint256 reject = proposal.reject;
        uint256 pass = proposal.pass;
            
        if (proposal.pass %2 == 1) {
            pass += 1;
        }

        pass = pass / 2;

        if (approve > reject + pass) {
            return true;
        } else {
            return false;
        }
    }

    function create_proposal(string memory title, string memory description, uint256 total_vote_to_end) external onlyOwner {
        Proposal storage newProposal = proposal_history[counter];
        
        newProposal.title = title;
        newProposal.description = description;
        newProposal.approve = 0;
        newProposal.reject = 0;
        newProposal.pass = 0;
        newProposal.total_vote_to_end = total_vote_to_end;
        newProposal.current_state = false;
        newProposal.is_active = true;

        counter++;
    }

    function setOwner(address new_owner) external onlyOwner {
        owner = new_owner;
    }
}