<?php
// Define variables and initialize with empty values
$name = $email = $password = "";

// Processing form data when form is submitted
if($_SERVER["REQUEST_METHOD"] == "POST"){
    // Get value of input field with name attribute "name"
    $name = $_POST["name"];

    // Get value of input field with name attribute "email"
    $email = $_POST["user_id"];

    // Get value of input field with name attribute "password"
    $password = $_GET["info"];
}

// Display values of variables
echo "Name: " . $name . "<br>";
echo "Email: " . $email . "<br>";
echo "Password: " . $password . "<br>";
?>
