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
var newRadarsIDs = [];
var offset = new Date().getTimezoneOffset();
var currentDate = new Date()
if (offset < 0) { 
   currentDate = date.addHours(currentDate, offset / -60);
} else {
   currentDate = date.addHours(currentDate, offset / 60);
}

fs.readFile(process.argv[2], (err, data) => {
   if (err) throw err;
   console.log(process.argv[2])
   let radars = JSON.parse(data)

   radars.forEach(function (obj) {
      db.collection("Radars").doc(obj.id).set({
         id: obj.id,
         title: obj.title,
         coordinates: obj.coordinates,
         type: obj.type,
         road: obj.road,
         valid_from: obj.valid_from,
         valid_to: obj.valid_to,
         text: obj.text,
         category_id: obj.category_id,
         category_name: obj.category_name,
         updated_at: obj.updated_at
      })
      newRadarsIDs.push(obj.id)
   });

   // Delete stationary radars
   db.collection("Radars").get().then((querySnapshot) => {
      querySnapshot.forEach((radar) => {
         if (radar.data().valid_to == null && newRadarsIDs.includes(radar.id) == false) {
            db.collection("Radars").doc(radar.id).delete().then(() => {
               console.log("Document with id: ", radar.id, ",successfully deleted!");
            }).catch((error) => {
               console.error("Error removing document: ", error);
            });
         }
      });
   });
});
