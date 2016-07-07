# AlexaPi

---

### Contributors

* [Sam Machin](http://sammachin.com)
* [Lenny Shirly](http://github.com/lennysh)
* [dojones1](https://github.com/dojones1)
* [Chris Kennedy](http://ck37.com)
* [Anand](http://padfoot.in)
* [Mason Stone](https://github.com/maso27)
* [Nascent Objects](https://github.com/nascentobjects)

---

This is the code needed to Turn a Raspberry Pi into a client for Amazon's Alexa service, I was trying to implement flooie's voice command first then maso27's branch second. I realized flooie's Snowboy detector is better compared to CMU Sphinx. However, maso27's version of Alexa is bit more developed. That's why I decided to try to combine these two branches and implement it using Sammachin's version 1.1 at a base branch. The process is clearly visible since there are some unused files in the repo. 

I have tested and make sure it will work with wake word detection. I haven't try with button yet (the tools are on the way. Will update as soon as possible).

here's the [demo](https://youtu.be/gqfpGiHsWso)

Feel free to contact me if you have any question.
---
##NOTE This branch is a hacked-up version of maso27's repository which origins from sammachin's repository

Added in this branch:
* Voice Recognition via Snowboy.  When the word "alexa" is detected, Alexa will recognize and will record after the beep sound.
* The whole project now only using PyAudio as an audio player/recorder (avoid device unavailable)
* Option for the user to install shairport-sync for airplay support.
* Command line arguments added:
 `(-s / --silent)` = start without saying "Hello"
 `(-d / --debug)` = enable display of debug messages at command prompt
* tunein support is improved
* volume control via "set volume xx" where xx is between 1 and 10
* buttons aren't tested yet but supposed to work.

### Requirements

You will need:
* A Raspberry Pi
* An SD Card with a fresh install of Raspbian (tested against build 2015-11-21 Jessie)
* An External Speaker with 3.5mm Jack
* A USB Sound Dongle and Microphone
* A push to make button connected between GPIO 18 and GND
* (Optionally) A Dual colour LED (or 2 signle LEDs) Connected to GPIO 24 & 25


Next you need to obtain a set of credentials from Amazon to use the Alexa Voice service, login at http://developer.amazon.com and Goto Alexa then Alexa Voice Service
You need to create a new product type as a Device, for the ID use something like AlexaPi, create a new security profile and under the web settings allowed origins put http://localhost:5050 and as a return URL put http://localhost:5050/code you can also create URLs replacing localhost with the IP of your Pi  eg http://192.168.1.123:5050
Make a note of these credentials you will be asked for them during the install process

### Installation

Boot your fresh Pi and login to a command prompt as root.

Make sure you are in /root

Make sure you have your sound up and working

Install Portaudio and PyAudio on Rasp

Clone this repo to the Pi
`git clone --branch version1.2 https://github.com/bdatdo0601/AlexaPi/`

Run the setup script
`./setup.sh`

Follow instructions....

Enjoy :)


### Issues/Bugs etc.
I changed sound module to use pulseaudio/pyaudio so if you run into trouble, instal pavucontrol and choose the sound device that suits you

If your alexa isn't running on startup you can check /var/log/alexa.log for errrors.


### A note on Shairport-sync

By default, shairport-sync (the airplay client) uses port 5000.  This is no problem if everything goes as planned, but AlexaPi's authorization on sammachin's design uses port 5000 as well, and if shairport-sync is running while that happens, everything fails.

As a result, I have changed the authorization port for AlexaPi to 5050.  Note that you will have to change the settings within the developer website for this to work.

### Advanced Install

For those of you that prefer to install the code manually or tweak things here's a few pointers...

The Amazon AVS credentials are stored in a file called creds.py which is used by auth_web.py and main.py, there is an example with blank values.

The auth_web.py is a simple web server to generate the refresh token via oAuth to the amazon users account, it then appends this to creds.py and displays it on the browser.

main.py is the 'main' alexa client it simply runs on a while True loop waiting either the trigger word "Alexa," or for the button to be pressed. It then records audio and when the button is released (or 5 seconds has passed in the case of the trigger word) it posts this to the AVS service using the requests library, When the response comes back it is played back using vlc via an os system call.

The LED's are a visual indictor of status, I used a duel Red/Green LED but you could also use separate LEDS, Red is connected to GPIO 24 and green to GPIO 25, When recording the RED LED will be lit when the file is being posted and waiting for the response both LED's are lit (or in the case of a dual R?G LED it goes Yellow) and when the response is played only the Green LED is lit. If The client gets an error back from AVS then the Red LED will flash 3 times.

The internet_on() routine is testing the connection to the Amazon auth server as I found that running the script on boot it was failing due to the network not being fully established so this will keep it retrying until it can make contact before getting the auth token.

The auth token is generated from the request_token the auth_token is then stored in a local memcache with and expiry of just under an hour to align with the validity at Amazon, if the function fails to get an access_token from memcache it will then request a new one from Amazon using the refresh token.








---
