# Food Tracker Application

## Overview

The Food Tracker Application is a comprehensive Flutter-based app designed to help users track their daily food intake and stay healthy. It provides functionalities to log meals, calculate calorie intake, track activities, and estimate nutrient consumption. The app also integrates with external APIs for data enrichment and uses a powerful AI chatbot for user assistance.

Another feature is guaranteed privacy

## Features 
- 🛡️ **Privacy First**: No user-identifying data or personal data will ever leave the device
- 🍽️ **Meal Tracking**: Log meals and ingredients to track daily calorie intake.
- 🏋️‍♂️ **Activity Log**: Record daily activities to monitor energy expenditure.
- 🥦 **Nutrient Analysis**: Calculate and display nutritional information like carbs, proteins, fats, and sugars.
- 💬 **AI Chatbot**: Chat with a Gemini-powered AI assistant for meal recommendations and health tips.
- ⚙️ **Settings Configuration**: Set user preferences including height, weight, age, gender, and activity level.
- 🔍 **Data Export and Import**: Export and import user data for backup and restoration.
- 📈 **Analytics**: Send anonymous telemetry data to improve app performance and user experience.
- 🎨 **UI Design**: Clean and intuitive user interface for a seamless experience.

## Privacy Standards 🛡️

### 📂 Data Storage

- **Local Storage**: All user data, including meal logs, activities, and personal information, is stored locally on the user's device using SQLite. This ensures that your data remains on your device and is not transmitted to any external servers.

### 🔐 Data Security

- **Data Backup**: Users can export data for backup purposes, but the exported data is not encrypted by the app. Users are responsible for securing exported data.

### 📈 Anonymous Telemetry

- **Telemetry Data**: The app sends totally anonymous and really simple telemetry data to the server to help improve app performance and user experience. This data includes information such as app open timestamp and what page the user visit in the app.

## Setup Instructions (Easy)

Download the latest release in the release page

**Configure API Key (Optional)**:
   - The application integrates a powerful chatbot powered by Gemini, which requires an API key to use it. Obtaining it is very simple and free of charge.

   1. Go to https://aistudio.google.com/
   2. Click on "Get API key" button at the top left
   3. Create an API key and paste it into the application settings.

   NOTE: The application can also work without the chatbot, but an important feature of the application is lost

## Setup Istruction (Manual Build)
### Prerequisites

- Flutter SDK
- Dart SDK
- Android Studio or Visual Studio Code

### Installation

1. **Clone the Repository**: 
   ```bash
   https://github.com/FoodTrackerPoliBa/FoodTracker.git
   cd food_traker
   ```

2. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure API Keys**:
   - The application integrates a powerful chatbot powered by Gemini, which requires an API key to use it. Obtaining it is very simple and free of charge.

   1. Go to https://aistudio.google.com/
   2. Click on "Get API key" button at the top left
   3. Create an API key and paste it into the application settings.

   NOTE: The application can also work without the chatbot, but an important feature of the application is lost

4. **Run the App**:
   ```bash
   flutter run
   ```

### Configuration

- **Analytics Configuration**: You can customize the analytics server URL in `lib/src/backend/analytics.dart`.

## Usage

### Navigating the App

- **Dashboard**: The main screen showing daily summaries, hour-wise activity and meal distribution.
- **Setup**: The initial setup screen where you configure user data like name, age, height, weight, gender, and activity level.
- **Chatbot**: Accessible via a floating action button, provides meal and health-related suggestions using the Gemini API.
- **Settings**: Allows modification of user data and other settings.

### User Flow

1. **First-Time Setup**: Complete the setup process to personalize the app.
2. **Track Meals**: Log meals by providing meal details and selecting ingredients.
3. **Log Activities**: Record daily activities for calorie expenditure tracking.
4. **View Summary**: Use the dashboard to view daily caloric intake, burned calories, and nutrient consumption.
5. **Connect with Chatbot**: Chat with the AI for meal suggestions and health tips.

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository.
2. Create your feature branch (`git checkout -b feature/AmazingFeature`).
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`).
4. Push to the branch (`git push origin feature/AmazingFeature`).
5. Open a Pull Request.

## License

The Food Tracker Application is released under the GNU General Public License v3.0. You are free to use, modify, and distribute the software under the terms of this license. For more details, please refer to the [LICENSE](LICENSE) file.

## Special Thanks
Thanks to [OpenNutriTracker](https://github.com/simonoppowa/OpenNutriTracker) from which we took inspiration for the realisation of a section of the UI

## Contact

- **Developers**: 
    - Daniele Carriere ([@DanielusG](https://github.com/DanielusG))
    - Angelo Ostello
    - Vincenzo Iacovone
    - Giuseppe Zizzari
- **Email**: FoodTrackerPoliBa@proton.me

Feel free to reach out for any questions or contributions!