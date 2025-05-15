<?php
/**
 * Sample PHP script to demonstrate the application's functionality
 * This file should be placed in the public directory
 */

// Environment variables for database connection
$dbHost = getenv('DB_HOST') ?: 'localhost';
$dbName = getenv('DB_NAME') ?: 'php_app';
$dbUser = getenv('DB_USER') ?: 'php_app_user';
$dbPass = getenv('DB_PASSWORD') ?: 'password';
$storageBucket = getenv('STORAGE_BUCKET') ?: 'demo-bucket';
$appEnv = getenv('APP_ENV') ?: 'dev';

// Function to test database connection
function testDatabaseConnection($host, $dbname, $username, $password) {
    try {
        $dsn = "mysql:host=$host;dbname=$dbname";
        $pdo = new PDO($dsn, $username, $password);
        $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        return [
            'status' => 'success',
            'message' => 'Database connection successful!'
        ];
    } catch (PDOException $e) {
        return [
            'status' => 'error',
            'message' => 'Database connection failed: ' . $e->getMessage()
        ];
    }
}

// Get server information
$serverInfo = [
    'php_version' => phpversion(),
    'server_software' => $_SERVER['SERVER_SOFTWARE'] ?? 'Unknown',
    'hostname' => gethostname(),
    'remote_addr' => $_SERVER['REMOTE_ADDR'] ?? 'Unknown',
    'request_time' => date('Y-m-d H:i:s'),
    'environment' => $appEnv
];

// Test database connection if not in development mode
$dbConnection = ['status' => 'not_tested', 'message' => 'Connection test skipped'];
if ($appEnv !== 'dev') {
    $dbConnection = testDatabaseConnection($dbHost, $dbName, $dbUser, $dbPass);
}

// Prepare the response
$response = [
    'app' => 'PHP Application on Google Cloud Run',
    'status' => 'running',
    'server_info' => $serverInfo,
    'database' => [
        'host' => $dbHost,
        'name' => $dbName,
        'connection' => $dbConnection
    ],
    'storage' => [
        'bucket' => $storageBucket
    ]
];

// Set content type to JSON
header('Content-Type: application/json');

// Output the response
echo json_encode($response, JSON_PRETTY_PRINT);