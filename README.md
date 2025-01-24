# Weather App Frontend

This is the Flutter-based frontend for the Weather Display Application. The app provides users with weather updates for their location or searched cities, a 5-day forecast, and allows them to manage reminders for weather-related activities.

---

## **Features**
- Display current weather conditions for the user's location.
- Search weather information for specific cities.
- Show a 5-day weather forecast.
- Add, view, edit, and delete weather-related reminders.
- Beautiful and responsive UI.
- Location-based weather functionality.
- Authentication using Firebase.

---

## **Technologies Used**
- **Framework**: Flutter
- **State Management**: SetState.
- **API**: OpenWeatherMap API
- **Database**: Database

---

## **Setup Instructions**

### Prerequisites

Before running the application, ensure you have the following:

- Flutter installed on your system.
- A valid Firebase project configured for the app.
- OpenWeatherMap API key.

### **Steps to Run the Backend Locally**
1. Clone the repository:

2. Install dependencies:
    flutter pub get

3. Create a .env file in the root directory and add the environment variables

4. Configure Firebase
    (Ensure you have enabled Authentication and Firestore Database in your Firebase project.)

5. Start the app: 
    flutter run

Build the app for production:
    flutter build apk
    flutter build ios

## API Endpoints

### Dependencies

Here are some primary dependencies used in this project:
- http: For API calls.
- provider: For state management.
- firebase_auth: For user authentication.
- cloud_firestore: For managing reminders.
- geolocator: For fetching user location.
