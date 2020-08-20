const functions = require('firebase-functions');
const admin = require("firebase-admin");
admin.initializeApp();

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });

exports.onCreateActivityFeedItem = functions.firestore
    .document("/feedNotification/{userId}/feedItems/{activityFeedItem}")
    .onCreate(async (snapshot, context) => {
        console.log("Activity Feed Item Created", snapshot.data());

        // get the user connected to the feed
        const userId = context.params.userId;
        const userRef = admin.firestore().doc(`user/${userId}`);
        const doc = await userRef.get();

        //Once we have user, check if they have a notification token;
        //send notification, if they have a token
        const androidNotificationToken = doc.data().androidNotificationToken;
        const createdActivityFeedItem = snapshot.data();
        if (androidNotificationToken) {
            sendNotification(androidNotificationToken, createdActivityFeedItem);
        } else {
            console.log("No token for user, cannot send notification");
        }

        function sendNotification(androidNotificationToken, activityFeedItem) {
            let body;
            let type;
            let userIdOfActivityFeed;
            let typeId;
            let index;

            //switch body value based off notification type
            switch (activityFeedItem.type) {
                case "rate_shop":
                    body = `${activityFeedItem.username} rated on your shop`;
                    type = "rate_shop";
                    break;
                case "review_shop":
                    body = `${activityFeedItem.username} put a review on your shop`;
                    type = "review_shop";
                    break;
                case "rate_item":
                    body = `${activityFeedItem.username} rated on your shop item`;
                    type = "rate_item";
                    break;
                case "review_item":
                    body = `${activityFeedItem.username} put a review on your shop item`;
                    type = "review_item";
                    break;

                default:
                    break;
            }

            userIdOfActivityFeed = activityFeedItem.userId;
            typeId = activityFeedItem.typeId;

            if (activityFeedItem.anyIndex == null) {
                index = 0;
            } else {
                index = activityFeedItem.anyIndex;
            }

            //create message for push notification
            const message = {
                notification: {
                    body: body,
                },
                token: androidNotificationToken,
                data: {
                    recipient: userId,
                    typeId: typeId,
                    index: index.toString(),
                    type: type,
                    username: doc.data().username,
                    userImage: doc.data().userPhotoUrl,
                    fromUserId: userIdOfActivityFeed,
                },
            };

            //Send message with admin.messaging
            admin
                .messaging()
                .send(message)
                .then((response) => {
                    // Response is a message ID String
                    console.log("sent message", response);
                })
                .catch((error) => {
                    console.log(error);
                });
        }
    });
