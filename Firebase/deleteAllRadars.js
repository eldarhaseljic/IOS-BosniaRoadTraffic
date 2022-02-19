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

db.collection("Radars").get().then((querySnapshot) => {
    querySnapshot.forEach((radar) => {
        db.collection("Radars").doc(radar.id).delete().then(() => {
            console.log(radar.data())
            console.log("Document with id: ", radar.id, ",successfully deleted!");
        }).catch((error) => {
            console.error("Error removing document: ", error);
        });
    });
});
