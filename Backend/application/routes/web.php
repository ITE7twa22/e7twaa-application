<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use Kreait\Firebase\Factory;
use Kreait\Firebase\Exception\AuthException;
use Kreait\Firebase\Exception\FirebaseException;

Route::post('/login', action: [AuthController::class, 'login']);

Route::get('/get-csrf-token', function () {
    return csrf_token();  // This will return the CSRF token as a string.
});


Route::get('/test', function () {
    return 'Route is working!';
});


Route::get('/test', function () {
    try {
        $firebase = (new Factory)->withServiceAccount(storage_path('app/firebase/volunteersdata-cf17b-firebase-adminsdk-fbsvc-f1d035e292.json'));
        $db = $firebase->createFirestore()->database();
        $collection = $db->collection('Volunteers');
        $documents = $collection->documents();

        if ($documents->isEmpty()) {
            return 'No documents found';
        }

        foreach ($documents as $document) {
            print_r($document->data());
        }
    } catch (\Exception $e) {
        return 'Error: ' . $e->getMessage();
    }
});

Route::get('/check-firebase-key', function () {
    $path = base_path('storage/app/firebase/volunteersdata-cf17b-firebase-adminsdk-fbsvc-f1d035e292.json');

    if (!file_exists($path)) {
        return response()->json(['error' => 'Firebase credentials file not found!'], 404);
    }

    $content = json_decode(file_get_contents($path), true);

    return response()->json($content);
});

Route::get('/test-firebase-auth', function () {
    $path = base_path('storage/app/firebase/volunteersdata-cf17b-firebase-adminsdk-fbsvc-f1d035e292.json');

    if (!file_exists($path)) {
        return response()->json(['error' => 'Firebase credentials file not found!'], 404);
    }

    try {
        $factory = (new Factory())->withServiceAccount($path);
        $auth = $factory->createAuth();

        return response()->json(['message' => 'Firebase Authentication is working!']);
    } catch (AuthException | FirebaseException $e) {
        return response()->json(['error' => $e->getMessage()], 500);
    }
});

