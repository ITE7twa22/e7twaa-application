<?php
//يستخدم Singleton Pattern بحيث يتم إنشاء الاتصال بـ Firebase مرة واحدة فقط
//يتيح الوصول إلى Auth و Database بدون إعادة الاتصال في كل مرة
namespace App\Services;

use Kreait\Firebase\Factory;
use Kreait\Firebase\Auth;
use Kreait\Firebase\Database;

class FirebaseService
{
    private static $instance = null;
    private $auth;
    private $database;

    private function __construct()
    {
        $factory = (new Factory)
            ->withServiceAccount(storage_path('app/firebase/volunteersdata-cf17b-firebase-adminsdk-fbsvc-f1d035e292.json'))
            ->withDatabaseUri(config('firebase.database.url'));

        $this->auth = $factory->createAuth();
        $this->database = $factory->createDatabase();
    }

    public static function getInstance()
    {
        if (self::$instance === null) {
            self::$instance = new self();
        }
        return self::$instance;
    }

    public function getAuth(): Auth
    {
        return $this->auth;
    }

    public function getDatabase(): Database
    {
        return $this->database;
    }
}
