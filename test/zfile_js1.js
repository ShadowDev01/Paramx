// Variables and constants
const myVariable = "Hello";
const anotherVariable = 42;
const apiBaseUrl = "https://api.example.com/page?id=53&price";
const apiKey = "YOUR_API_KEY"; // Replace with your actual API key

// Functions
function performCalculation(x, y) {
  return x + y;
}

function fetchData(url, query) {
  const options = {
    method: "GET",
    headers: {
      "Authorization": `Bearer ${apiKey}` // Replace with appropriate authorization
    }
  };

  return fetch(url + query, options)
    .then(response => response.json())
    .catch(error => {
      console.error("Error fetching data:", error);
      // Handle errors here (e.g., display error messages)
    });
}

// Dictionary (object)
const myDictionary = {
  "key1" : "value1",
  'key2': 123,
  "key3": { "innerKey": "nested value" }
};

// Script execution
const result = performCalculation(myVariable, anotherVariable);
console.log("Calculation result:", result);

fetchData(apiBaseUrl, "/data?filter=specific")
  .then(data => {
    console.log("Fetched data:", data);
    // Process the fetched data here
  });

let fullname = "jack simones";
var age = 34;
const multiply = (x, y) => x * y;
console.log(multiply(3, 4));
// ... weitere Code-Abschnitte ...
