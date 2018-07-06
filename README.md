# zipweb
Serve a website straight out of a zip file.

Serving websites out of a zip file instead of first extracting the zip file to disk isn't terribly performant, so this is a niche tool.
*Possible usecase*: You've archived a website using wget and zipped it so it wouldn't clutter your harddrive, but you still want to browse your archive.

## Installation
* Install [Akku](https://github.com/weinholt/akku)
* ```akku install compression```

## Usage
```
source .akku/bin/activate
./zipweb.scm [zip file]
```

Files will be served on localhost:8080 by default.

## FAQ

**Q:** Why zip?  Why not tar.[gz/bz2]?

**A:** Zip supports random access.

## TODO
* 404 support
* redirect / to index.htm[l]
* directory listing support
