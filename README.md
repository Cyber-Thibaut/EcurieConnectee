# EcurieConnectée 🐎

**EcurieConnectée** est une Interface Homme-Machine (IHM) complète conçue pour la gestion d'une "Écurie Active". Développée en C++ et Qt/QML, cette application s'exécute sur une Raspberry Pi équipée d'un écran tactile. Elle agit comme un hub central pour surveiller et contrôler divers aspects du soin des chevaux : de la distribution de nourriture au contrôle d'accès, en passant par la gestion des stocks.

Le système interagit avec des lecteurs RFID basés sur LoRaWAN via The Things Network (TTN) et des périphériques MQTT locaux (comme une ESP32-CAM) pour fournir des données en temps réel et un retour visuel instantané.

## ✨ Fonctionnalités

- **Tableau de Bord :** Un écran d'accueil centralisé pour la navigation rapide, l'état du système et les contrôles d'alimentation (redémarrage/arrêt). Inclut un terminal de débogage en temps réel pour surveiller le trafic MQTT et LoRaWAN.
- **Gestion des Chevaux :** Une interface CRUD (Créer, Lire, Mettre à jour, Supprimer) complète pour gérer les profils des chevaux. L'ajout d'un nouvel animal peut se faire en scannant directement son badge RFID.
- **Suivi de l'Alimentation :** Surveille l'accès à la nourriture pour chaque cheval. Lorsqu'un cheval consomme sa ration, son accès est temporairement révoqué jusqu'au prochain cycle ou jusqu'à une réinitialisation manuelle.
- **Contrôle d'Accès :** Un panneau de configuration (actuellement simulé) permettant de gérer les autorisations d'accès aux différentes zones (pâturages, distributeurs) de manière individuelle.
- **Gestion des Stocks :** Surveille l'inventaire des consommables (foin, granulés, paille). Intègre un affichage graphique des niveaux de stock et une interface pour enregistrer les nouvelles livraisons.
- **Intégration MQTT & LoRaWAN :**
  - Connexion sécurisée à The Things Network (TTN) pour recevoir les données des scans RFID depuis les stations distantes.
  - Hébergement d'un broker MQTT local pour communiquer avec une ESP32-CAM, permettant de déclencher des prises de vue.
- **Prise de Photo Automatisée :** Capture automatiquement une photo lorsqu'un cheval est identifié à une station d'alimentation et la lie à l'historique des événements.

## 🛠️ Technologies Utilisées

- **Framework Application :** C++ avec **Qt 5** (QtQuick / QML).
- **Interface Utilisateur :** QML pour une interface tactile moderne, réactive et fluide.
- **Base de Données :** MySQL / MariaDB, hébergée localement sur la Raspberry Pi pour stocker l'historique, les profils et les stocks.
- **Protocoles de Communication :**
  - **MQTT :** Utilisé pour la communication locale (ESP32-CAM) et cloud (The Things Network).
  - **LoRaWAN :** Protocole de communication longue portée entre les lecteurs RFID et la passerelle TTN.
- **Matériel Cible :** Raspberry Pi avec écran DSI tactile (sous Raspberry Pi OS Legacy/Buster).
- **CI/CD :** GitHub Actions pour la compilation croisée (cross-compilation) automatisée et la génération des Releases.

## 🏗️ Architecture du Système

Le flux de travail du système est orchestré par l'application principale Qt tournant sur la Raspberry Pi :

1. Un cheval s'approche d'une station, son badge RFID est lu par un lecteur compatible LoRaWAN (ex: Arduino ou M5Stack).
2. Le lecteur envoie les données RFID (*uplink*) à The Things Network (TTN) via une passerelle LoRaWAN.
3. L'application `EcurieConnectee`, abonnée au broker MQTT de TTN, reçoit le message.
4. La classe `DatabaseManager` traite le RFID :
   - Elle interroge la base de données locale pour identifier le cheval et vérifier ses droits (`peut_manger`).
   - Si l'accès est autorisé, elle publie un message (*downlink*) vers TTN pour ordonner l'ouverture de la porte de la station. Elle met ensuite à jour le statut du cheval pour empêcher une ré-entrée immédiate et déduit la ration des stocks.
   - Si l'accès est refusé ou le badge inconnu, aucune action n'est déclenchée.
5. Simultanément, l'application publie une commande sur le broker MQTT local à destination de l'ESP32-CAM.
6. L'ESP32-CAM prend une photo et publie l'URL de l'image sur un topic MQTT local.
7. L'application reçoit l'URL, télécharge l'image, la sauvegarde localement (`/home/pi/photos_chevaux`), et met à jour l'entrée correspondante dans la table `historique` avec le chemin de la photo.
8. L'interface QML, propulsée par le modèle `ChevalSqlModel`, reflète automatiquement tous ces changements en temps réel.

## ⚙️ Composants Principaux (C++)

- `main.cpp` : Point d'entrée de l'application. Initialise le framework Qt, configure les deux clients MQTT (Local et TTN), se connecte à la base de données, crée les modèles QML et charge l'interface utilisateur.
- `DatabaseManager` : Le "cerveau" logique de l'application. Gère les messages MQTT entrants, interroge la base MySQL, applique les règles métier (ex: vérification des droits d'accès), et émet des signaux pour mettre à jour l'IHM ou envoyer de nouveaux messages MQTT.
- `MqttManager` : Wrapper dédié pour `QMqttClient`, spécifiquement configuré pour gérer la connexion sécurisée (TLS/SSL) au broker cloud The Things Network.
- `ChevalSqlModel` : Sous-classe de `QSqlQueryModel` servant de pont entre la base de données MySQL et le frontend QML. Expose les données sous forme de tables et fournit des méthodes `Q_INVOKABLE` permettant à l'IHM d'ajouter des chevaux, mettre à jour les stocks ou supprimer des profils.

## 🚀 Pipeline CI/CD & Déploiement

Le dépôt est équipé de flux de travail GitHub Actions pour automatiser la construction et la distribution du logiciel :

- **`check-build.yml`** : Déclenché à chaque `push` sur la branche `main`. Effectue une compilation croisée (cross-compilation) complète du projet pour l'architecture `ARMv7` (Debian Buster), garantissant que le code reste compatible avec le matériel cible.
- **`create-release.yml`** : Déclenché par la création d'un tag de version (ex: `v1.0.0`). Ce workflow compile le projet, embarque l'exécutable ainsi que les bibliothèques partagées requises (`libQt5Mqtt.so.5`), et crée une Release GitHub officielle.

**Mode Kiosque (Raspberry Pi) :**
Le déploiement sur la machine cible est automatisé via un script bash (`update.sh`) qui interroge l'API GitHub pour télécharger la dernière Release. La Raspberry Pi est configurée avec un service `systemd` pour lancer l'application en mode rendu direct (EGLFS via KMS atomique) dès le démarrage du système, sans nécessiter d'environnement de bureau.
