// https://www.npmjs.com/package/date-and-time
const date = require('date-and-time');
// Required for side-effects
const firebase = require("firebase");
const fs = require('fs');
require("firebase/firestore");

// Initialize Cloud Firestore through Firebase
firebase.initializeApp({
    apiKey: "AIzaSyCOQe97QzqHpQnkqvw5WGSC5SP0wcId0Gw",
    authDomain: "bosnia-road-traffic-fire-d6422.firebaseapp.com",
    databaseURL: "https://bosnia-road-traffic-fire-d6422-default-rtdb.firebaseio.com",
    projectId: "bosnia-road-traffic-fire-d6422",
    storageBucket: "bosnia-road-traffic-fire-d6422.appspot.com",
    messagingSenderId: "882903880990",
    appId: "1:882903880990:web:024e2c0eddb40518d8250f",
    measurementId: "G-PQKF5RCX63"
});

var db = firebase.firestore();
var currentDate = new Date()
const offset = currentDate.getTimezoneOffset()
currentDate = new Date(currentDate.getTime() - (offset*60*1000))
var validDateString = currentDate.toISOString().split('T')[0] + ' ' + currentDate.toLocaleTimeString('en-GB')
var validToDate = date.parse(validDateString, 'YYYY-MM-DD hh:mm:ss', true);

fs.readFile(process.argv[2], (err, data) => {
    if (err) throw err;
    console.log(process.argv[2])
    let roadConditions = JSON.parse(data)

    roadConditions.forEach(function (obj) {
        db.collection("RoadConditions").doc(obj.id).set({
            id: obj.id,
            icon: obj.icon,
            title: obj.title,
            coordinates: obj.coordinates,
            road: obj.road,
            valid_from: obj.valid_from,
            valid_to: obj.valid_to,
            numberOfDeletions: obj.numberOfDeletions,
            text: obj.text,
            category_id: obj.category_id,
            category_name: obj.category_name,
            updated_at: validToDate
        })
        console.log(obj)
        console.log("Document with id: ", obj.id, ",successfully added!");
    });
});
