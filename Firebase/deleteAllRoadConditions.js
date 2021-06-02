// https://www.npmjs.com/package/date-and-time
const date = require('date-and-time');
// Required for side-effects
const firebase = require("firebase");
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
var offset = new Date().getTimezoneOffset();
var currentDate = new Date()
if (offset < 0) {
    currentDate = date.addHours(currentDate, offset / -60);
} else {
    currentDate = date.addHours(currentDate, offset / 60);
}

db.collection("RoadConditions").get().then((querySnapshot) => {
    querySnapshot.forEach((roadConditions) => {
                db.collection("RoadConditions").doc(roadConditions.id).delete().then(() => {
                    console.log(roadConditions.data())
                    console.log("Document with id: ", roadConditions.id, ",successfully deleted!");
                }).catch((error) => {
                    console.error("Error removing document: ", error);
                });
    });
});
