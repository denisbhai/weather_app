# Flutter Weather App

Features:
- Current weather using OpenWeatherMap
- 5-day forecast
- Today forecast
- GPS location + manual city search
- Google Maps with weather tile overlay (temperature)
- Marker with info window
- BLoC (Cubit) for state management
- dotenv for API keys (do not commit `.env`)

## Setup
1. Clone repo.
2. Create `.env` in project root:
3. Android: configure `AndroidManifest.xml` to use `${GOOGLE_MAPS_API_KEY}` via manifest placeholders or paste key (prefer placeholders).
4. `flutter pub get`
5. Run: `flutter run`

## Architecture
- `services/` — API and location logic (single responsibility).
- `cubits/` — UI state management via Cubit (lightweight BLoC).
- `models/` — immutable data models.
- `pages/` — UI composable widgets.
- Justification: Cubit (from Flutter Bloc) offers predictable states, easy testing and aligns well with the company’s use of BLoC/Cubit.

## Notes & Tradeoffs
- Error handling surfaces exceptions as simple messages — for production you'd map to typed failures.
- OneCall API usage assumes availability on your plan. If not available, use `forecast` and aggregate into daily buckets.
- Map tile layers depend on OpenWeatherMap tile endpoints. Check their terms and tile usage limits.

## Testing (bonus)
- Add unit tests for `WeatherApiService` using `mockito`.
- Add `bloc_test` tests for `weather_cubit_test`.
