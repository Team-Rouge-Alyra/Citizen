// SPDX-License-Identifier: MIT              
pragma solidity ^0.6.0; 
pragma experimental ABIEncoderV2;

contract Citizen{
    struct Citoyen{
        
        uint256 wallet; // argent possédé
        
        bool sage;
        uint256 depot_sage;
        uint8 elu; //sage pdt 8 semaines /////////////////////
        
        bool travailleur;
        bool chomeur;
        uint256 cotisation_chomeur;
        bool malade;
        uint256 cotisation_maladie;
        bool retraite;
        uint256 cotisation_retraite;
        uint8 age; // a remplir lors register pour prevoir la retraite
        bool banni; //banni 10 ans? //////////////////////
    }
    
    struct Entreprises{
        uint256 id; // siret
        uint256 argent;
        bool statut; //satut valide?
    }
    
    mapping (address => Citizen ) public administration;
    mapping (address => Entreprises ) public travail;
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
    