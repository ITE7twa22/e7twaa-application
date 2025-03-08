<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Kreait\Firebase\Factory;
use Kreait\Firebase\Auth;
use Exception;
use Firebase\JWT\JWT;
use Google\Cloud\Firestore\FirestoreClient;


class AuthController extends Controller
{
    protected $firestore;
    protected $auth;

    public function __construct()
    {
        $factory = (new Factory)
            ->withServiceAccount(storage_path('app/firebase/volunteersdata-cf17b-firebase-adminsdk-fbsvc-f1d035e292.json'));

        $this->firestore = $factory->createFirestore()->database();
        $this->database = $factory->createDatabase();
    }
    public function login(Request $request)
    {
        $request->validate([
            'PhoneNumber' => 'required',
            'NationalID' => 'required',
        ]);

        $NationalID = $request->input('NationalID');
         $phoneNumber = $request->input('PhoneNumber');
        try {
            $firestore = $this->firestore->collection('Volunteers');
          
            $query = $firestore->collection('Volunteers')
            ->where('NationalID', '=', $NationalID)
            ->where('PhoneNumber', '=', $phoneNumber)
            ->limit(1);


            $documents = $query->documents();

            if ($documents->isEmpty()) {
                return response()->json(['message' => 'بيانات تسجيل الدخول غير صحيحة'], 401);
            }

            $user = $documents->rows()[0];
            
            // إنشاء التوكن باستخدام JWT مع صلاحية أسبوع
            $payload = [
                'sub' => $user->id(),
                'phone' => $user['phone'],
                'national_id' => $user['national_id'],
                'iat' => time(),
                'exp' => time() + (60 * 60 * 24 * 20), // صالح لمدة 7 أيام
            ];
            
            $token = JWT::encode($payload, env('JWT_SECRET'), 'HS256');
            
            return response()->json(['token' => $token, 'user' => $user->data()], 200);
        } catch (Exception $e) {
            return response()->json(['message' => $e->getMessage()], 500);
        }
    }
}