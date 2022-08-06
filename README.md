# SwiftTimeZoneLookup

A description of this package.


## Build database
```bash
brew install shapelib wget
cd Submodules/ZoneDetect/database/builder

# make sure to select to newest version in make.db script

LIBRARY_PATH=/opt/homebrew/Cellar/shapelib/1.5.0/lib CPATH=/opt/homebrew/Cellar/shapelib/1.5.0/include ./makedb.sh

cp out_v1/timezone* ../../../../Sources/SwiftTimeZoneLookup/Resources

```
