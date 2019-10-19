# [Hack Heroes 2019](http://hackheroes.pl/)
## Overview
This is the server application for my project. It allows clients to post help requests containing text and an image that can later be responded to with a text message.
## Instalation
1. Install [Dart](https://dart.dev/)
2. Setup [Firebase Messaging](https://firebase.google.com) (FCM) for your project
3. [Get your server key](https://stackoverflow.com/questions/37427709/firebase-messaging-where-to-get-server-key)
4. Put your key in a new file in the project directory
5. Modify */lib/firebase_token.dart* <code>File('/run/secrets/firebase_token')</code> with the relative path to your key
6. <code>pub get</code>
7. <code>dart bin/main.dart</code>
## Data flow
1. Client A HTTP POST /getHelp  
    1. Respond to request  
***Request***  
            \{  
                "text": "some text",  
                "image": "base64 encoded image"  
            \}  
***Response***  
            \{  
                "status": "ok",  
                "placeInQueue": assigned place,  
                "id": "randomly generated client id"  
            \}
    2. Notify helpers with firebase messaging
2. Client A Websocket -> Server
    1. Client sends ID from step 1
    2. Server links the data from step 1 to the websocket
3. Client B (notified by firebase) HTTP GET /helpNeeded  
***Response***  
            \{  
                "status": "ok",  
                "needed": true/false,  
                "id": "null/client A id",  
                "text": "null/client A text",  
                "image: "null/client A image"  
            \}
4. Client B POST /offerHelp
***Request***  
            \{  
                "text": "some text",  
                "id": "client A id"  
            \}  
***Response***  
            \{  
                "status": "ok",  
            \}
