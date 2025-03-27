// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.29;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Voting
 */
contract Voting is Ownable {
    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint256 votedProposalId;
    }

    struct Proposal {
        string description;
        uint256 voteCount;
    }

    enum WorkflowStatus {
        RegisteringVoters,
        ProposalsRegistrationStarted,
        ProposalsRegistrationEnded,
        VotingSessionStarted,
        VotingSessionEnded,
        VotesTallied
    }

    event VoterRegistered(address voterAddress);
    event VoterUnregistered(address voterAddress);
    event WorkflowStatusChange(
        WorkflowStatus previousStatus,
        WorkflowStatus newStatus
    );
    event ProposalRegistered(uint256 proposalId);
    event Voted(address voter, uint256 proposalId);

    mapping(address => Voter) private voters;
    Proposal[] private proposals;
    WorkflowStatus private workflowStatus;
    uint256 private winningProposalId;

    constructor() Ownable(msg.sender) {
        workflowStatus = WorkflowStatus.RegisteringVoters;
    }

    function registerVoters(address[] calldata _addresses) public onlyOwner {
        require(
            workflowStatus == WorkflowStatus.RegisteringVoters,
            "Voters registration is not open."
        );

        for (uint256 i = 0; i < _addresses.length; i++) {
            address voterAddress = _addresses[i];
            voters[voterAddress] = Voter(true, false, 0);

            emit VoterRegistered(voterAddress);
        }
    }

    function unregisterVoter(address _voterAddress) public onlyOwner {
        require(
            workflowStatus == WorkflowStatus.RegisteringVoters,
            "Voters registration is not open."
        );
        require(voters[_voterAddress].isRegistered, "Voter is not registered.");

        delete voters[_voterAddress];

        emit VoterUnregistered(_voterAddress);
    }

    function getWorkflowStatus() public view returns (WorkflowStatus) {
        require(voters[msg.sender].isRegistered, "Voter is not registered.");

        return workflowStatus;
    }

    function nextWorkflowStatus() public onlyOwner {
        WorkflowStatus previousStatus = workflowStatus;
        workflowStatus = WorkflowStatus(uint256(workflowStatus) + 1);

        if (workflowStatus == WorkflowStatus.VotesTallied) {
            winningProposalId = 0;
            for (uint256 i = 1; i < proposals.length; i++) {
                if (
                    proposals[i].voteCount >
                    proposals[winningProposalId].voteCount
                ) {
                    winningProposalId = i;
                }
            }
        }

        emit WorkflowStatusChange(previousStatus, workflowStatus);
    }

    function registerProposal(string calldata description) public {
        require(
            workflowStatus == WorkflowStatus.ProposalsRegistrationStarted,
            "Proposals registration is not open."
        );
        require(voters[msg.sender].isRegistered, "Voter is not registered.");

        proposals.push(Proposal(description, 0));

        emit ProposalRegistered(proposals.length - 1);
    }

    function getProposals() public view returns (string[] memory) {
        require(voters[msg.sender].isRegistered, "Voter is not registered.");

        string[] memory newProposals = new string[](proposals.length);

        for (uint256 i = 0; i < newProposals.length; i++) {
            newProposals[i] = proposals[i].description;
        }

        return newProposals;
    }

    function vote(uint256 votedProposalId) public returns (string memory) {
        require(
            workflowStatus == WorkflowStatus.VotingSessionStarted,
            "Proposals registration is not open."
        );
        require(voters[msg.sender].isRegistered, "Voter is not registered.");
        require(votedProposalId < proposals.length, "Invalid proposal ID.");

        if (voters[msg.sender].hasVoted) {
            proposals[voters[msg.sender].votedProposalId].voteCount--;
        }

        voters[msg.sender].hasVoted = true;
        voters[msg.sender].votedProposalId = votedProposalId;
        proposals[votedProposalId].voteCount++;

        emit Voted(msg.sender, votedProposalId);

        return proposals[votedProposalId].description;
    }

    function getWinner() public view returns (string memory winningProposal) {
        require(
            workflowStatus == WorkflowStatus.VotesTallied,
            "Vote is not completed."
        );
        require(voters[msg.sender].isRegistered, "Voter is not registered.");

        return proposals[winningProposalId].description;
    }
}
