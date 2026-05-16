# AscendIA — Career Copilot

> "Climb Smarter" - Assistant IA de carrière pour jeunes diplômés 

Projet universitaire - Groupe 06  
**Équipe :** Mohammed ZEROUAL - Lisa KHETTAB - Jana CHEHWAN - Abdoul DIALLO - Maha BENGRAB

---

## Présentation

AscendIA est une application mobile d'accompagnement professionnel propulsée par l'IA, destinée aux jeunes diplômés (18-30 ans). Elle permet d'analyser son CV, de mesurer sa compatibilité avec une offre d'emploi, et d'obtenir des conseils de carrière personnalisés.

---

## Fonctionnalités

| # | Fonctionnalité | Description |
|---|---|---|
| 1 | **Authentification** | Inscription, connexion JWT, configuration du profil |
| 2 | **Analyse de CV** | Upload PDF → extraction des compétences, score, corrections |
| 3 | **Matching Emploi** | Colle une offre → score de compatibilité + certifications recommandées |
| 4 | **Chatbot Carrière** | Assistant IA conversationnel pour conseils professionnels |

---

## Stack Technique

| Couche | Technologie |
|---|---|
| Frontend | Flutter 3.x (iOS + Android) |
| Backend | Python 3.14 + FastAPI + Uvicorn |
| Base de données | SQLite (via SQLAlchemy) |
| IA | OpenAI API — gpt-4o-mini |
| Auth | JWT (PyJWT + bcrypt) |

---

## Prérequis

### Backend
- Python 3.12+ (testé sur 3.14)
- Une clé API OpenAI (https://platform.openai.com)

### Frontend
- Flutter SDK 3.x
- Android Studio (pour l'émulateur Android) ou un appareil Android

---

## Installation & Lancement

### 1. Cloner / extraire le projet

```
AscendIA/
├── backend/
├── frontend/
└── start_backend.bat
```

### 2. Configurer le backend

```bash
cd backend
```

Créer le fichier `.env` :
```
OPENAI_API_KEY=sk-votre_clé_openai_ici
```

Installer les dépendances :
```bash
pip install -r requirements.txt
```

### 3. Lancer le backend

```bash
# Windows
.\start_backend.bat

# Ou manuellement
cd backend
uvicorn main:app --reload
```

Le serveur démarre sur : http://localhost:8000  
Documentation API : http://localhost:8000/docs

### 4. Lancer le frontend Flutter

```bash
cd frontend
flutter run
```

Choisir l'appareil souhaité (émulateur Android recommandé).

> **Note émulateur Android :** L'URL du backend est `http://10.0.2.2:8000` (configuré dans `frontend/lib/config/constants.dart`)  
> **Note navigateur web :** L'URL du backend est `http://127.0.0.1:8000`

---

## Configuration selon la plateforme

Modifier `frontend/lib/config/constants.dart` selon l'environnement :

```dart
// Émulateur Android
static const String baseUrl = 'http://10.0.2.2:8000';

// Navigateur web / desktop
static const String baseUrl = 'http://127.0.0.1:8000';

// Appareil physique (remplacer par l'IP de la machine)
static const String baseUrl = 'http://192.168.X.X:8000';
```

---

## Structure du projet

```
AscendIA/
├── backend/
│   ├── main.py              # Point d'entrée FastAPI
│   ├── models.py            # Modèles SQLAlchemy
│   ├── schemas.py           # Schémas Pydantic
│   ├── database.py          # Configuration SQLite
│   ├── requirements.txt
│   ├── routes/
│   │   ├── auth.py          # Inscription / connexion
│   │   ├── cv.py            # Analyse de CV
│   │   ├── matching.py      # Matching emploi
│   │   └── chatbot.py       # Chatbot IA
│   └── utils/
│       ├── auth.py          # JWT helpers
│       └── openai_client.py # Client OpenAI
└── frontend/
    └── lib/
        ├── main.dart
        ├── config/          # Constantes, thème
        ├── models/          # Modèles de données
        ├── screens/         # Écrans de l'app
        ├── services/        # Appels API
        └── widgets/         # Composants réutilisables
```

---

## Compte de démonstration

Créer un compte directement depuis l'application via "Créer un compte".

---

## Notes importantes

- Le fichier `.env` contenant la clé OpenAI **n'est pas inclus** dans le rendu pour des raisons de sécurité
- Une clé OpenAI avec crédits disponibles est nécessaire pour les fonctionnalités IA
- La base de données SQLite (`ascendia.db`) est créée automatiquement au premier lancement
