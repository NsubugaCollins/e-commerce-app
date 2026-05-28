
# Campus Mall Mobile

Flutter app for the [Campus Mall](../campus_mall) Laravel store.

## Setup

1. Install [Flutter](https://docs.flutter.dev/get-started/install).
2. Start the Laravel API:

```bash
cd ../campus_mall
php artisan serve --host=0.0.0.0 --port=8000
php artisan migrate
```

3. API URL (production on Render):

```
https://cycle-jgso.onrender.com/api
```

Release builds use this automatically. For local dev or testing, use Profile → Settings or:

| Environment | URL |
|-------------|-----|
| **Production (Render)** | `https://cycle-jgso.onrender.com/api` |
| Android emulator (local) | `http://10.0.2.2:8000/api` |
| iOS simulator (local) | `http://127.0.0.1:8000/api` |
| Physical device (local) | `http://<your-lan-ip>:8000/api` |

See `../campus_mall/RENDER_SETUP.md` for full Render env variable list.

4. Run the app:

```bash
cd campus_mall_mobile
flutter pub get
flutter run
```

## Features

- Browse home feed, categories, and product search
- Product details with images
- Cart, checkout (cash), order history
- Login, register (with referral code), profile & points
- Secure token storage (Laravel Sanctum)

## API

All endpoints are under `/api` on the Laravel backend. See `../campus_mall/routes/api.php`.
=======
# e-commerce-app
the app for e commerce
>>>>>>> 0c33b3f0191c4b242093d78aff5b154d1711b5c4
