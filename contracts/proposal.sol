// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract proposalContract{
    
    address owner;
    uint256 counter;

    constructor (){
        owner = msg.sender;
    }

    modifier onlyOwner(){
        require(msg.sender == owner);
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

    function approve(uint proposal_number) external {
        Proposal storage selected_proposal = proposal_history[proposal_number]; 
        require(selected_proposal.is_active,"This proposal is no longer active.");
        require(!selected_proposal.hasVoted[msg.sender],"Voter has already voted.");
        selected_proposal.approve += 1;
        selected_proposal.hasVoted[msg.sender] = true;

        if (selected_proposal.approve + selected_proposal.reject == selected_proposal.total_vote_to_end){
            selected_proposal.is_active = false;
        }
    }

    function reject(uint proposal_number) external {
        Proposal storage selected_proposal = proposal_history[proposal_number];
        require(selected_proposal.is_active,"This proposal is no longer active.");
        require(!selected_proposal.hasVoted[msg.sender],"Voter has already voted.");
        selected_proposal.reject +=1;
        selected_proposal.hasVoted[msg.sender] = true;
        
        if(selected_proposal.approve + selected_proposal.reject == selected_proposal.total_vote_to_end) {
            selected_proposal.is_active = false;
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