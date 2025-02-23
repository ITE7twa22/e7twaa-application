<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Kreait\Firebase\Factory;
use Google\Cloud\Firestore\FirestoreClient;
use Firebase\JWT\JWT;
use Firebase\JWT\Key;
use Illuminate\Support\Facades\Config;
use Firebase\JWT\ExpiredException;
use Carbon\Carbon;

class VolunteersController extends Controller
{
    protected $firestore;

    public function __construct()
    {
        $factory = (new Factory)->withServiceAccount(storage_path('app/firebase/firebase_credentials.json'));
        $this->firestore = $factory->createFirestore()->database();
    }

    public function checkUser(Request $request)
    {
        $NationalID = trim($request->input('NationalID'));
        $phoneNumber = trim($request->input('PhoneNumber'));

        if (!$NationalID || !$phoneNumber) {
            return response()->json(['message' => 'NationalID and PhoneNumber are required'], 400);
        }

        try {
            $projectId = env('GOOGLE_CLOUD_PROJECT');
            $firestore = new FirestoreClient([
                'projectId' => $projectId,
            ]);
            ini_set('max_execution_time', 60);

            $query = $firestore->collection('Volunteers')
                ->where('NationalID', '=', $NationalID)
                ->where('PhoneNumber', '=', $phoneNumber)
                ->limit(1);


            $documents = $query->documents();

            foreach ($documents as $document) {
                if ($document->exists()) {
                    return response()->json([
                        'message' => 'Volunteer exists',
                        'Volunteers' => $document->data()
                    ]);
                }
            }

            return response()->json(['message' => 'User not found'], 404);
        } catch (\Exception $e) {
            return response()->json(['error' => 'Firestore error: ' . $e->getMessage()], 500);
        }
    }

    public function login(Request $request)
    {
        $NationalID = trim($request->input('NationalID'));
        $phoneNumber = trim($request->input('PhoneNumber'));
    
        if (!$NationalID || !$phoneNumber) {
            return response()->json(['message' => 'بيانات تسجيل الدخول غير صحيحة'], 401);
        }
    
        try {
            $projectId = env('GOOGLE_CLOUD_PROJECT');
            $firestore = new FirestoreClient([
                'projectId' => $projectId,
            ]);
            ini_set('max_execution_time', 60);
    
            // Query Firestore for NationalID
            $query = $firestore->collection('Volunteers')
                ->where('NationalID', '=', $NationalID)
                ->limit(1);
    
            $documents = $query->documents();
    
            if ($documents->isEmpty()) {
                return response()->json(['message' => 'بيانات تسجيل الدخول غير صحيحة'], 401);
            }
    
            // Get first matching document
            $userDoc = $documents->rows()[0];
            $userData = $userDoc->data();
    
            // Check if PhoneNumber contains the input
            if (strpos($userData['PhoneNumber'], $phoneNumber) === false) {
                return response()->json(['message' => 'بيانات تسجيل الدخول غير صحيحة'], 401);
            }
    
            // Check if the old token is blacklisted
            $oldToken = $request->bearerToken();
            if ($oldToken) {
                $blacklistedToken = $firestore->collection('BlacklistedTokens')->document($oldToken)->snapshot();
                if ($blacklistedToken->exists()) {
                    return response()->json(['message' => 'تم تسجيل الخروج، الرجاء تسجيل الدخول مجددًا'], 401);
                }
            }
    
            // Generate JWT Token
            $payload = [
                'sub' => $userDoc->id(),
                'phoneNumber' => $userData['PhoneNumber'],
                'nationalID' => $userData['NationalID'],
                'iat' => time(),
                'exp' => time() + (60 * 60 * 24 * 20), // Token valid for 20 days
            ];
    
            $jwtSecret = Config::get('app.jwt_secret');
            $token = JWT::encode($payload, $jwtSecret, 'HS256');
    
            return response()->json(['token' => $token, 'user' => $userData], 200);
    
        } catch (\Exception $e) {
            return response()->json(['message' => $e->getMessage()], 500);
        }
    }
    public function logout(Request $request)
    {
        $token = $request->bearerToken();

        if (!$token) {
            return response()->json(['message' => 'لم يتم إرسال التوكن'], 400);
        }

        try {
            $jwtSecret = Config::get('app.jwt_secret');
            JWT::decode($token, new Key($jwtSecret, 'HS256'));

            // حفظ التوكن المحظور في Firestore
            $this->firestore->collection('BlacklistedTokens')->document($token)->set([
                'token' => $token,
                'expires_at' => Carbon::now()->addWeek(),
            ]);

            return response()->json(['message' => 'تم تسجيل الخروج بنجاح'], 200);
        } catch (ExpiredException $e) {
            return response()->json(['message' => 'انتهت صلاحية التوكن، الرجاء تسجيل الدخول مجددًا'], 401);
        } catch (\Exception $e) {
            return response()->json(['message' => 'توكن غير صالح'], 401);
        }
    }

    public function checkToken(Request $request)
    {
        $token = $request->bearerToken();

        if (!$token) {
            return response()->json(['message' => 'توكن غير متوفر'], 400);
        }

        $blacklistedToken = $this->firestore->collection('BlacklistedTokens')->document($token)->snapshot();
        if ($blacklistedToken->exists()) {
            return response()->json(['message' => 'الجلسة منتهية، الرجاء تسجيل الدخول مرة أخرى'], 401);
        }

        return response()->json(['message' => 'التوكن صالح'], 200);
    }
    private function getUserFromToken(Request $request)
    {
        $token = $request->bearerToken();
        if (!$token) {
            return null;
        }
    
        try {
            $jwtSecret = Config::get('app.jwt_secret');
            $decoded = JWT::decode($token, new Key($jwtSecret, 'HS256'));
            $projectId = env('GOOGLE_CLOUD_PROJECT');
            $firestore = new FirestoreClient([
                'projectId' => $projectId,
            ]);
            $userRef = $firestore->collection('Volunteers')->document($decoded->sub)->snapshot();
            
            if ($userRef->exists()) {
                return ['id' => $decoded->sub, 'data' => $userRef->data()];
            }
    
            return null;    
        } catch (ExpiredException $e) {
            echo("JWT Token expired: " . $e->getMessage());
            return null;
        } catch (\Exception $e) {
            echo("JWT Decoding error: " . $e->getMessage());
            return null;
        }
    }
    

    public function checkIn(Request $request)
    {
        $token = $request->bearerToken();
        
        if (!$token) {
            return response()->json(['error' => 'Unauthorized'], 401);
        }
    
        try {
            $jwtSecret = Config::get('app.jwt_secret'); // Get secret from .env
            $decoded = JWT::decode($token, new Key($jwtSecret, 'HS256'));
    
          
            $userId = $decoded->sub ?? null; 
            $nationalID = $decoded->nationalID ?? null; 
    
            if (!$userId) {
                return response()->json(['error' => 'Invalid token'], 400);
            }   
            $projectId = env('GOOGLE_CLOUD_PROJECT');
            $firestore = new FirestoreClient([
                'projectId' => $projectId,
            ]);
            ini_set('max_execution_time', 60);
            $now = Carbon::now();
            $workDate = $now->hour < 6 ? $now->subDay()->format('Y-m-d') : $now->format('Y-m-d');

            $attendanceRef = $firestore->collection('Attendance')->document("{$nationalID}-{$workDate}");
            $now = Carbon::now();
            $attendanceRef->set([
                'user_id' =>  $nationalID,
                'login_time' => $now,
                'logout_time' => null,
                'checked_in_app' => true, // ✅ هذا الفلاغ يشير إلى أن الحضور تم عبر التطبيق
            ]);
            

            return response()->json(['message' => 'تم تسجيل الحضور بنجاح'], 201);
        } catch (\Exception $e) {
            return response()->json(['error' => 'Invalid or expired token'], 401);
        }
    }

    public function checkOut(Request $request)
    {
        $token = $request->bearerToken();
    
        if (!$token) {
            return response()->json(['error' => 'Unauthorized'], 401);
        }
    
        try {
            $jwtSecret = Config::get('app.jwt_secret'); // Get secret from .env
            $decoded = JWT::decode($token, new Key($jwtSecret, 'HS256'));
    
            $userId = $decoded->sub ?? null;
            $nationalID = $decoded->nationalID ?? null;
    
            if (!$userId) {
                return response()->json(['error' => 'Invalid token'], 400);
            }
    
            $projectId = env('GOOGLE_CLOUD_PROJECT');
            $firestore = new FirestoreClient([
                'projectId' => $projectId,
            ]);
            ini_set('max_execution_time', 60);
    
            $now = Carbon::now();
            $workDate = $now->hour < 6 ? $now->subDay()->format('Y-m-d') : $now->format('Y-m-d');
    
            // Get the document reference using the nationalID
            $volunteerRef = $firestore->collection('Attendance')->document("{$nationalID}-{$workDate}");
    
            // Check if the document exists
            $snapshot = $volunteerRef->snapshot();
            if (!$snapshot->exists()) {
                return response()->json(['error' => 'Volunteer not found'], 404);
            }
    
            // Update the logout_time field
            $volunteerRef->update([
                ['path' => 'logout_time', 'value' => $now->toDateTimeString()],
            ]);
            $loginTime = Carbon::parse($snapshot->get('login_time'));
            $logoutTime = $now;
            $duration = $logoutTime->diff($loginTime);
            $formattedDuration = sprintf('%02d:%02d:%02d', $duration->h, $duration->i, $duration->s);
            $volunteerRef->update([
                ['path' => 'hours', 'value' => $formattedDuration],
            ]);
            return response()->json(['message' => 'Check-out successful']);
        } catch (\Exception $e) {
            return response()->json(['error' => 'Invalid or expired token'], 401);
        }
    }
    
}
