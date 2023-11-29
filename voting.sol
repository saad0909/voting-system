//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "hardhat/console.sol";

contract voting_system{
    event output_msg(string msg);
    address private admin;
    string public outputt;
    enum vs{not_started, started, ended}
    vs voting;
    struct users{
        string username;
        bool registered;
        bool voted;
    }
    struct party_cand{
        bool party_registered;
        string name;
        uint total_votes;
    }
    mapping(address => users) voters;
    mapping(address => users) candidates;
    mapping(string => party_cand) parties;
    string[] voters_name;
    string[] candidates_name;
    string[] parties_key;
    string winner_key;
    constructor(){
        admin = msg.sender;
        winner_key="PMLN";
        parties["PTI"] = party_cand(true, "no one", 0);
        parties["PMLN"] = party_cand(true, "no one", 0); 
        parties["PPP"] = party_cand(true, "no one", 0);
        parties_key.push("PTI");
        parties_key.push("PMLN");
        parties_key.push("PPP");
        voting = vs.not_started;
    }

    function start_voting() public if_admin() before_start() all_cand() {
        voting = vs.started;
        outputt = "voting has started";
        emit output_msg("voting has started");
        }

    function end_voting() public if_admin() before_end() {
        voting = vs.ended;
        emit output_msg("voting has ended");
        outputt = "voting has ended";
    }

    function add_party(string memory p) public if_admin() if_party(p) {
        parties[p] = party_cand(true, "no one", 0);
        parties_key.push(p);
        emit output_msg("Party was added successfully");
        outputt = "party was added successfully";
    } 

    function register_as_voter(string calldata name) public voter_repeat() {
        voters[msg.sender] = users(name, true, false);
        voters_name.push(name);
        emit output_msg("voter registered");
        console.log("registered");
        outputt = "voter registerd";
    }

    function register_as_candidate(string calldata name, string calldata _party) public cand_repeat(_party) {
        candidates[msg.sender] = users(name, true, false);
        candidates_name.push(name);
        parties[_party].name = name;
        emit output_msg("candidate registered");
        console.log("registered");
        outputt = "candidate registered";
    }

    function display_candidates() public view {
        console.log("Party   ", "Candidate");
        for(uint i = 0; i < parties_key.length; i++){
            console.log(parties_key[i], "    ", parties[parties_key[i]].name);
        }
    }

    function vote_cast(string memory p) public allowvote(p) voting_started() {
        parties[p].total_votes++;
        voters[msg.sender].voted = true;
        console.log("voted successfully");
        emit output_msg("voted successfully");
        outputt = "voted successfully";
    }

    function view_winner() public view voting_ended() {
        console.log("Winner party: ", winner_key);
        console.log("Candidate name: ", parties[winner_key].name);
        console.log("Candidate total votes: ", parties[winner_key].total_votes);
    }

    function view_results() public view voting_ended() {
        for(uint i = 0; i < parties_key.length; i++){
        console.log("Party name: ", parties_key[i]);
        console.log("Candidate name: ", parties[parties_key[i]].name);
        console.log("Candidate total votes: ", parties[parties_key[i]].total_votes);
        }
    }

    modifier voting_ended() {
        if(voting == vs.ended ) _;
        else console.log("you cannot view results as voting has not ended yet");
    }

    modifier allowvote( string memory p){
        if(parties[p].party_registered && voters[msg.sender].registered && !voters[msg.sender].voted) {
            _;
            if( parties[p].total_votes > parties[winner_key].total_votes ) winner_key = p;
        }
        else console.log("you cannot vote");       
    }

    modifier voter_repeat(){
        if(!voters[msg.sender].registered){
            _;
        }
        else{
            console.log("failed to register");
        }
    }

    modifier cand_repeat(string calldata _party){ 
        if(keccak256(bytes(parties[_party].name)) == keccak256(bytes("no one")) && !candidates[msg.sender].registered) _;
        else console.log("failed to register");
    }

    modifier if_admin(){ 
        if (msg.sender == admin) _;
        else console.log("you cannot start voting");
        }

    modifier before_start() {
        if (voting == vs.not_started) _;
    }

    modifier before_end() {
        if (voting == vs.started) _;
    }

    modifier voting_started(){
        if (voting == vs.started) _;
        else console.log("voting has not started yet");
    }

    modifier if_party(string memory p) {
        if (!parties[p].party_registered) _;
        else console.log("party already registered");
    }

    modifier all_cand() {
        for(uint i = 0; i < parties_key.length; i++){
            if(keccak256(bytes(parties[parties_key[i]].name)) == keccak256(bytes("no one"))){
                 console.log("not all parties have candidates");
            }
        }
        _;
    }
}