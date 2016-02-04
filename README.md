# gnutls build

This repository allows you to build and package gnutls

## Dependencies

```
apt-get install build-essential libgmp-dev libunbound-dev m4
```

# Building and Packaging
```
git clone https://github.com/charlesportwoodii/gnutls-build
cd gnutls-build

sudo make VERSION=<version>
# deb packages can be built with
# sudo make package VERSION=<version>
```
