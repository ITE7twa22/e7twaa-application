<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\VolunteersController;


// تسجيل الدخول باستخدام Firebase
Route::post('/login', action: [VolunteersController::class, 'login']);

// تسجيل خروج المستخدم
// Route::post('/logout', action: [AuthController::class, 'logout']);

// استرجاع بيانات المستخدم المسجل حاليًا
Route::get('/user', [AuthController::class, 'getUser']);

Route::post('/checkUser', [VolunteersController::class, 'checkUser']);
//ممكن ما تشتغل مع ال jwt فنبحث عن بديل
Route::post('/logout', [VolunteersController::class, 'logout']);
Route::get('/check-token', [VolunteersController::class, 'checkToken']);
Route::post('/check-in', [VolunteersController::class, 'checkIn']);
Route::post('/check-out', [VolunteersController::class, 'checkOut']);
Route::get('/totalHours', [VolunteersController::class, 'totalHours']);

