# [Hack Heroes 2019](http://hackheroes.pl/)
Connected projects:
- [Phone app](https://github.com/Carbon225/hack-heroes-2019-mobile)
- [Keyboard](https://github.com/Carbon225/hack-heroes-2019-keyboard)
## Overview
This is the server application for my project. It allows clients to post help requests containing text and an image that can later be responded to with a text message.
## Instalation
You do not need to run your own server because the precompiled *.apk* file will connect to my server.  
If you want to compile the app yourself, proceed with the installation.
1. Install [Dart](https://dart.dev/)
2. Setup [Firebase Messaging](https://firebase.google.com) (FCM) for your project
3. [Get your server key](https://stackoverflow.com/questions/37427709/firebase-messaging-where-to-get-server-key)
4. Put your key in a new file
5. Modify */lib/firebase_token.dart* <code>File('/run/secrets/firebase_token')</code> with the absolute path to your key
6. Run Dart app

        pub get
        dart bin/main.dart
## Data flow
1. Client A HTTP POST /getHelp  
    1. Respond to request  
        ***Request***  

            {  
                "id": "firebase id"
                "text": "some text",  
                "image": "base64 encoded image"  
            }  
        ***Response***  

            {  
                "status": "ok",  
                "placeInQueue": assigned place,  
            }
    2. Notify helpers with firebase messaging
2. Client B (notified by firebase) HTTP GET /helpNeeded  
    ***Response***  

            {  
                "status": "ok",  
                "needed": true/false,  
                "id": "null/client A id",  
                "text": "null/client A text",  
                "image: "null/client A image"  
            }
3. Client B POST /offerHelp  
    ***Request***  

            {  
                "text": "some text",  
                "id": "client A id"  
            }  
    ***Response***  

            {  
                "status": "ok",  
            }
