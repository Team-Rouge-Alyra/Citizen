// SPDX-License-Identifier: MIT              
pragma solidity ^0.6.0; 
pragma experimental ABIEncoderV2;

contract Citizen{
    
//structure des citoyens        
    struct Citoyen{
        bool citoyen; // a reflechir
        uint256 id; // a remplacer par name?
        uint256 wallet; // argent possédé
        bool travailleur;
        bool chomeur;
        uint256 cotisation_chomeur;
        bool malade;
        uint256 cotisation_maladie;
        bool retraite;
        uint256 cotisation_retraite;
        uint256 age; // a remplir lors register pour prevoir la retraite
        bool banni; //banni 10 ans?
        //bool mort; //pas sur utile et trop de lignes pour que ça passe avec

    }
    
// strucuture des sages - trop de lignes si intégré a Citoyen
    struct Sage{
        bool isSage;
        uint256 depot_sage; // 100 Citizen
        uint256 delayRegistration; //sage pdt 8 semaines =  block.timestamp + 8 weeks
    }

//structure des entreprises    
    struct Entreprises{
        uint256 id; // siret
        uint256 argent;
        bool statut; //statut valide?
    }


// id pour ne pas avoir deux citoyens avec id identiques    
    uint256 private _id;
// compteur pour identifier vote
    uint256 private compteur;
//budget, incrémenté par impots, amendes, décès; décrémenté par nouveaux citoyens et entreprises   
    uint256 public budget;
    string public help_gestion_status = "change le statut 0=travailleur, 1=chomeur, 2=malade, 3=mort";
    enum statut { travailleur, chomeur, malade, mort }
    
    mapping (address => Citoyen ) public administration;
    mapping (address => Sage ) public admin;
    mapping (address => Entreprises ) public travail;
    
    //a débattre en team, solution pour 1er citoyen / 1er sage. 5200 weeks car si plus de sage on est mals - pour l'instant nécessaire pour faire mes tests.
    constructor(uint8 _age) public {
        admin[msg.sender].isSage = true;
        admin[msg.sender].depot_sage = 100;
        admin[msg.sender].delayRegistration = block.timestamp + 5200 weeks;
        administration[msg.sender].citoyen = true;
        administration[msg.sender].id = 0;
        administration[msg.sender].age=_age;
    }

    modifier onlySage (){
            require (admin[msg.sender].isSage == true, "only Sage can do this");
            require(admin[msg.sender].delayRegistration > block.timestamp, "vous n'êtes plus sage");
            _;
    }
     
     modifier onlyCitoyen (){
            require (administration[msg.sender].citoyen == true, "fonction réservée aux citoyens");
            _;
    }   
    
// enregistrement de nouveau citoyen, vérif pas déjà citoyen, attribue citoyenneté, id, 100 citizen (retirés au budget), incrémente id général     
    function register(address _addr, uint256 _age) public onlySage{
        require (administration[_addr].citoyen==false, "cette personne est déjà citoyen");
        
        administration[_addr].citoyen=true;
        administration[_addr].age =(_age*52);
        administration[_addr].wallet+=100;
        budget-=100;
        administration[_addr].id=_id+1;
        _id+=1;
        
    }
    
//gestion de statut par sage  0 travailleur, 1 chomeur, 2 malade, 3 mort   
    function gestion_statut(statut _ide, address _addr) public onlySage {
        if (_ide==statut.travailleur){
            administration[_addr].travailleur?administration[_addr].travailleur=false:administration[_addr].travailleur=true;
        }
        else if (_ide==statut.chomeur){
            administration[_addr].chomeur?administration[_addr].chomeur=false:administration[_addr].chomeur=true;
        }
        else if (_ide==statut.malade){
            administration[_addr].malade?administration[_addr].malade=false:administration[_addr].malade=true;
        }
        else if (_ide==statut.mort){
            budget+=administration[_addr].wallet;
            administration[_addr].wallet=0;
            budget+=administration[_addr].cotisation_chomeur;
            administration[_addr].cotisation_chomeur=0;
            budget+=administration[_addr].cotisation_maladie;
            administration[_addr].cotisation_maladie=0;
            budget+=administration[_addr].cotisation_retraite;
            administration[_addr].cotisation_retraite=0;
        }
    }
    
// 
// ajout du  code ci dessous + constructeur l 53 + modifier l69
//
    struct Candidat{
        uint256 id;
        address candidat;//
        uint256 temps_vote;
        uint256 voteOui;
        uint256 voteNon;
        mapping (address => bool) didVote;
    }
    
    mapping (uint256 => Candidat) public a_voter;
    
    enum choix {Oui, Non}

    // 2 minutes au lieu de 1 weeks pour les tests - comprend pas pourquoi les return ne fonctionnent pas 
    function se_presenter_sage()public onlyCitoyen returns (string memory, uint256, string memory){
        require (administration[msg.sender].wallet>=100, "vous ne possédez pas la somme a mettre en dépot pour vous présenter");
        require (admin[msg.sender].isSage==false);
        compteur +=1;
        a_voter[compteur].id=compteur;
        a_voter[compteur].candidat = msg.sender;
        a_voter[compteur].temps_vote = block.timestamp + 2 minutes;
        return ("le vote", a_voter[compteur].id, "est en cours");
    }
    

    function vote(uint _nbvote, choix bulletin) public onlyCitoyen {
    //    require ((block.timestamp)<(a_voter[_nbvote].temps_vote), "ce vote est terminé");
        require (a_voter[_nbvote].didVote[msg.sender]==false, "vous avez déjà voté");
        if (bulletin == choix.Oui){
            a_voter[_nbvote].voteOui+=1;
            a_voter[_nbvote].didVote[msg.sender]=true;
        }
        else if (bulletin == choix.Non){
            a_voter[_nbvote].voteNon+=1;
            a_voter[_nbvote].didVote[msg.sender]=true;
        }
        else {revert("choix pour le vote incompris");
            
        }
    }
    
    //comprend pas pourquoi les return ne fonctionnent pas 
    function result(uint _nbvote) public view returns(string memory, uint256, uint256){
    //    require ((block.timestamp)>(a_voter[_nbvote].temps_vote), "ce vote est en cours");
        if(a_voter[_nbvote].voteOui>a_voter[_nbvote].voteNon){

            return ("le candidat a été élu", a_voter[_nbvote].voteOui, a_voter[_nbvote].voteNon);
        }
        else {
            return ("le candidat n'a pas été élu", a_voter[_nbvote].voteOui, a_voter[_nbvote].voteNon);
        }
    }
 
    function gestionSage(uint _nbvote) public onlySage{
        admin[(a_voter[_nbvote].candidat)].isSage=true;
        admin[(a_voter[_nbvote].candidat)].depot_sage+=100;
        administration[(a_voter[_nbvote].candidat)].wallet-=100;
        admin[(a_voter[_nbvote].candidat)].delayRegistration=block.timestamp + 8 weeks;
    }
    
    
}
    