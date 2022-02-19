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

if (process.argv[2] != null) {
    fs.readFile(process.argv[2], (err, data) => {
        if (err) throw err;
        console.log(process.argv[2])
        let roadConditions = JSON.parse(data)

        roadConditions.forEach(function (obj) {
            db.collection("RoadConditionReport").doc('RoadConditionReport-1111111').set({
                id: 'RoadConditionReport-1111111',
                title: "Stanje na cestama " + validDateString,
                startDate: validToDate,
                numberOfDeletions: null,
                endDate: null,
                text: obj.text,
                category_id: 1111111,
                category_name: "Op\u0161te informacije",
            })
            console.log(obj)
            console.log("Document with id: ", obj.id, ",successfully added!");
            console.log(validDateString)
        });
    });
} else {
    db.collection("RoadConditionReport").get().then((querySnapshot) => {
        querySnapshot.forEach((obj) => {
            db.collection("RoadConditionReport").doc(obj.id).delete().then(() => {
                console.log(obj.data())
                console.log("Document with id: ", obj.id, ",successfully deleted!");
            }).catch((error) => {
                console.error("Error removing document: ", error);
            });
        });
    });
}
