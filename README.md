# AI Sports Match - Hackathon Submission

An AI-powered drop-in sports app built with Flutter and Supabase, featuring intelligent match finding, personalized coaching, and smart scheduling.

## 🎯 Hackathon Features

### Core AI Features (Powered by Google Gemini)

1. **AI Match Finder** - Analyzes player profile and recommends best-matched games based on skill level, location, and availability
2. **AI Coach** - Provides personalized coaching tips based on player stats and upcoming game context
3. **Smart Scheduling** - AI suggests optimal game times based on player patterns
4. **Game Summaries** - Auto-generates engaging post-game narratives

## 🚀 Quick Start

### Prerequisites
- Flutter SDK (3.38.4 or higher)
- Google Gemini API key
- Supabase account (optional for demo)

### Setup

1. Clone the repository
```bash
cd sportsapp
```

2. Install dependencies
```bash
flutter pub get
```

3. Configure environment variables
Create a `.env` file in the root directory:
```
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
GEMINI_API_KEY=your_gemini_api_key
```

4. Run the app
```bash
flutter run
```

## 📱 Features

- **Modern UI** - Dark green theme with glassmorphism effects
- **Demo Mode** - Test all features without authentication
- **Real-time Updates** - Live game availability and participant tracking
- **AI-Powered Recommendations** - Smart match finding with confidence scores
- **Personalized Coaching** - Context-aware tips from AI coach

## 🏗️ Tech Stack

- **Frontend**: Flutter 3.38.4
- **Backend**: Supabase
- **AI**: Google Gemini 2.0 Flash
- **State Management**: Provider
- **UI**: Material 3 with custom theming

## 📂 Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── user_model.dart
│   ├── game_model.dart
│   └── game_summary_model.dart
├── services/                 # Business logic
│   ├── supabase_service.dart
│   └── gemini_service.dart
├── screens/                  # UI screens
│   ├── splash_screen.dart
│   ├── auth_screen.dart
│   ├── home_screen.dart
│   ├── ai_match_finder_screen.dart
│   └── ai_coach_screen.dart
└── widgets/                  # Reusable components
    └── game_card.dart
```

## 🎨 Design

The app features a modern dark green theme inspired by Costa Rican soccer culture, with:
- Neon green (#00FF88) accents
- Dark green-black (#0D1B1E) background
- Glassmorphism effects
- Smooth animations and transitions

## 🤖 AI Integration

All AI features use Google's Gemini 2.0 Flash model for:
- Natural language processing
- Contextual recommendations
- Personalized content generation
- Real-time analysis

## 📝 License

Built for the AI Hackathon - February 1, 2026
