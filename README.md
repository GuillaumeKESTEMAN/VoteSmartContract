# Smart Contract de Vote

Ce smart contract Solidity permet de gérer un processus de vote décentralisé via la blockchain.

## Installation

Pour installer le projet il va falloir exécuter la commande `npm install`.

## Déploiement

Tout d'abord il va falloir compiler le smart contract avec la commande `npx hardhat compile`.

Ensuite pour le déployer on va commencer par ouvrir un node en local via la commande `npx hardhat node`.

Puis nous allons pouvoir déployer notre smart contract "Voting" via la commande `npx hardhat ignition deploy ./ignition/modules/Voting.js --network localhost`

## Workflow

Le propriétaire du contrat s'occupe de gérer l'avancement du status du workflow, voici les status dans l'ordre :

- enregistrement des votants
- commencement de l'enregistrement des propositions
- fin de l'enregistrement des propositions
- commencement de la session de vote
- fin de de la session de vote
- comptabilisation des votes

Pour que le propriétaire puisse faire avancer le status du workflow il doit lancer la méthode `nextWorkflowStatus()`

A tout moment, les votants enregistrés peuvent être informés du status actuel du workflow via la méthode `getWorkflowStatus()`.

### Enregistrement des votants

Pour enregistrer des votants le propriétaire doit faire appelle à la méthode `registerVoters(addresses)` avec comme paramètre un tableau d'adresse sous ce format : `[address_1,address_2,address_3]`.

Il est aussi possible pour le propriétaire d'enlever un votant de la liste via le méthode `unregisterVoter(address)`.

### Enregistrement des propositions

Les différents votants enregistrés peuvent soumettre des propositions pour le votes qui se déroulera juste après.

Pour cela ils doivent appeler la méthode `registerProposal(description)`.

Les votants enregistrés peuvent récupérer les propositions enregistrés via la méthode `getProposals()`.

### Enregistrement des votes

Les différents votants enregistrés peuvent soumettre leurs votes via la méthode `vote(proposalId)`.

### Récupération de la proposition gagnante

Les différents votants enregistrés peuvent récupérer la proposition gagnante à la fin du vote via la méthode `getWinner()`.

## Remarques

- Seul le propriétaire peut enregistrer les électeurs et gérer le workflow.
- Les électeurs ne peuvent voter que pour une seule proposition, mais peuvent changer leur vote.
- Les résultats ne sont disponibles qu'une fois le vote terminé.
