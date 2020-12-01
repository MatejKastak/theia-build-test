# theia-build-test

This docker file will attempt to build the theia from sources and use those
built modules to create browser app (specified in `package.json`).

**Current state:**
This will build working browser application, but I don't think we are using
the source code, instead all node module dependencies are downloaded.

Build with:

```bash
make build
```

Run with:

```bash
make run
```
