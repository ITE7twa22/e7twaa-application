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
        $factory = (new Factory)->withServiceAccount(storage_path('app/firebase/volunteersdata-cf17b-firebase-adminsdk-fbsvc-f1d035e292.json'));
        $this->firestore = $factory->createFirestore()->database();
    }

    public function checkUser(Request $request)
    {
        $NationalID = (int) trim($request->input('NationalID'));
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
            ->where('IsActive', '=', "YES")
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
        $NationalID = (int) trim($request->input(key: 'NationalID'));
        $code = (int) trim($request->input(key: 'code'));
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
            ->where('Code', '=', $code)
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
                'code' => $userData['Code'],
                'iat' => time(),
                'exp' => time() + (60 * 60 * 24 * 20), // Token valid for 20 days
            ];
    
            $jwtSecret = Config::get('app.jwt_secret');
            $token = JWT::encode($payload, $jwtSecret, 'HS256');
            $result = $this->totalHours($token)->getData(true); // Convert to an associative array
 
            return response()->json([
                'token' => $token,
                'user' => $userData,
                'total_hours' => $result['total_hours'] ?? 0  // Ensure default value in case key is missing
            ], 200);
            
    
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
            // $this->firestore->collection('BlacklistedTokens')->document($token)->set([
            //     'token' => $token,
            //     'expires_at' => Carbon::now()->addWeek(),
            // ]);

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
            $code = $decoded->code ?? null; 
    
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

            $attendanceRef = $firestore->collection('Attendance')->document("{$code}-{$workDate}");
            $now = Carbon::now();
            $attendanceRef->set([
                'VolunteerID' =>  $code,
                'LoginDateTime' => $now,
                'LogoutDateTime' => null,
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
            $code = $decoded->code ?? null;
    
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
            $volunteerRef = $firestore->collection('Attendance')->document("{$code}-{$workDate}");
    
            // Check if the document exists
            $snapshot = $volunteerRef->snapshot();
            if (!$snapshot->exists()) {
                return response()->json(['error' => 'Volunteer not found'], 404);
            }
    
            // Update the logout_time field
            $volunteerRef->update([
                ['path' => 'LogoutDateTime', 'value' =>  Carbon::now()],
            ]);
            $loginTime = Carbon::parse($snapshot->get('LoginDateTime'));
            $logoutTime =Carbon::now();

            $duration = $logoutTime->diff($loginTime);
            $formattedDuration = sprintf('%02d:%02d:%02d', $duration->h, $duration->i, $duration->s);
            $volunteerRef->update([
                ['path' => 'Hours', 'value' => $formattedDuration],
            ]);
            return response()->json(['message' => 'Check-out successful']);
        } catch (\Exception $e) {
            return response()->json(['error' => 'Invalid or expired token'], 401);
        }
    }

    public function totalHours($token)
    {
        if (!$token) {
            return response()->json(['error' => 'Unauthorized'], 401);
        }
    
        try {
            $jwtSecret = Config::get('app.jwt_secret');
            $decoded = JWT::decode($token, new Key($jwtSecret, 'HS256'));
    
            $code = $decoded->code ?? null;
            if (!$code) {
                return response()->json(['error' => 'Invalid token'], 400);
            }
    
            $firestore = new FirestoreClient(['projectId' => env('GOOGLE_CLOUD_PROJECT')]);
    
            // Define the start and end of March 2025 as Firestore Timestamps
            $startDate = new \Google\Cloud\Core\Timestamp(new \DateTime('2025-03-01 00:00:00 UTC'));
            $endDate = new \Google\Cloud\Core\Timestamp(new \DateTime('2025-03-31 23:59:59 UTC'));
    
            // Query attendance records for March 2025
            $query = $firestore->collection('Attendance')
                ->where('VolunteerID', '=', $code)
                ->where('LoginDateTime', '>=', $startDate)
                ->where('LoginDateTime', '<=', $endDate);
    
            $documents = $query->documents();
    
            $totalHours = 0;
            foreach ($documents as $document) {
                if ($document->exists()) {
                    $data = $document->data();
                    $hours = $data['Hours'] ?? '00:00:00';
    
                    if (preg_match('/^(\d{2}):(\d{2}):(\d{2})$/', $hours, $matches)) {
                        $hour = (int) $matches[1];
                        $minute = (int) $matches[2];
                        $second = (int) $matches[3];
    
                        $totalHours += $hour + ($minute / 60) + ($second / 3600);
                    }
                }
            }
    
            return response()->json(['total_hours' => round($totalHours)], 200);
        } catch (\Exception $e) {
            return response()->json(['error' => 'Invalid token or Firestore error', 'message' => $e->getMessage()], 400);
        }
    }
    
    
    
}    
