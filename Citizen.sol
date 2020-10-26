// SPDX-License-Identifier: MIT              
pragma solidity ^0.6.0; 
pragma experimental ABIEncoderV2;

contract Citizen{
    struct Citoyen{
        bool citoyen; // a reflechir
        uint256 id;
        uint256 wallet; // argent possédé
        bool travailleur;
        bool chomeur;
        uint256 cotisation_chomeur;
        bool malade;
        uint256 cotisation_maladie;
        bool retraite;
        uint256 cotisation_retraite;
        uint8 age; // a remplir lors register pour prevoir la retraite
        bool banni; //banni 10 ans?
        //bool mort; //pas sur utile et trop de lignes pour que ça passe avec

    }
    struct Sage{
        bool sage;
        uint256 depot_sage;
        uint8 elu; //sage pdt 8 semaines =  block.timestamp + 8 weeks
    }
    
    struct Entreprises{
        uint256 id; // siret
        uint256 argent;
        bool statut; //statut valide?
    }
    
    uint256 public _id;
    uint256 public budget;
    string public help_gestion_status = "change le status 0=travailleur, 1=chomeur, 2=malade, 3=mort";
    enum statut { travailleur, chomeur, malade, mort }
    
    mapping (address => Citoyen ) public administration;
    mapping (address => Sage ) public admin;
    mapping (address => Entreprises ) public travail;
    
    
    function register(address _addr) public {
        require (administration[_addr].citoyen==false, "vous êtes déjà citoyen");
        administration[_addr].citoyen=true;
        administration[_addr].id=_id+1;
        administration[_addr].wallet=100;
        _id+=1;
    }
    
    
    function gestion_statut(statut _ide, address _addr) public {
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
    
}
    