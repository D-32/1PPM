To run the project you need to add a file called ApiKeys.plist (it's already linked inside the xcode project, just missing on the disk). The content of the file should be:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>GoogleMapsKey</key>
	<string> {{ YOUR GOOGLE MAPS API KEY }} </string>
</dict>
</plist>
```
If you don't want to bother setting up a google maps api key, just leave it empty. Most parts of the app will still work fine.
