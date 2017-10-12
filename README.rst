S2I Buildout
============

This project provides a Docker Image suitable for S2I to build containers for
buildout based projects.

If you want to use this builder image to build a docker image with s2i for your
project, it must satisfy a few constraints:

- It must be buildable by calling buildout without any argument
- The build results either in:

  - a `bin/instance` script that accepts a parameter fg and runs in foreground
  - a `bin/pserve` script and a `production.ini` file for it.

- The logs should be dumped to stdout.

Creating the application image
------------------------------

The application image combines the builder image with your applications source code, which is served using whatever application is installed via the *Dockerfile*, compiled using the *assemble* script, and run using the *run* script.
The following command will create the application image:

```
s2i build test/test-app buildout-centos7 buildout-centos7-app
---> Building and installing application from source...
```

Using the logic defined in the *assemble* script, s2i will now create an application image using the builder image as a base and including the source code from the test/test-app directory.

The app in the folder test/test-app is a minimal Plone 5 example.


Running the application image
-----------------------------

Running the application image is as simple as invoking the docker run command:

```
docker run -d -p 8080:8080 buildout-centos7-app
```
The application, which consists of a simple static web page, should now be accessible at  [http://localhost:8080](http://localhost:8080).


Using the saved artifacts script
--------------------------------

Rebuilding the application using the saved artifacts can be accomplished using the following command:

```
s2i build --incremental=true test/test-app nginx-centos7 nginx-app
---> Restoring build artifacts...
---> Building and installing application from source...
```
This will run the *save-artifacts* script which includes the custom code to backup the currently running application source, rebuild the application image, and then re-deploy the previously saved source using the *assemble* script.

If you must compile your own source code with the zc.recipe.cmmi script, use version >=2.0.0 and set shared to `true`.
This way, the incremental build will not recompile your code.
