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
    mapping(uint256 => Proposal) private proposals;
    WorkflowStatus private workflowStatus;
    uint256 private winningProposalId;

    constructor() Ownable(msg.sender) {}

    function addVoters(address[] calldata _address) public onlyOwner {
        require(
            workflowStatus == WorkflowStatus.RegisteringVoters,
            "Voters registration is not open."
        );

        for (uint256 i = 0; i < _address.length; i++) {
            address voterAddress = _address[i];

            voters[voterAddress].isRegistered = true;
            voters[voterAddress].hasVoted = false;
            voters[voterAddress].votedProposalId = 0;

            emit VoterRegistered(voterAddress);
        }
    }

    function removeVoter(address _voterAddress) public onlyOwner {
        require(
            workflowStatus == WorkflowStatus.RegisteringVoters,
            "Voters registration is not open."
        );
        require(voters[_voterAddress].isRegistered, "Voter is not registered.");

        voters[_voterAddress].isRegistered = false;

        emit VoterUnregistered(_voterAddress);
    }
}
