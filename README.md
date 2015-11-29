# simpleDeploy


Cookbook is designed to acquire and deploy a simple Sinatra application to centOS 7

Initially started with an attempt using nginX and phusion passenger. However the deployment script was starting to turn into little hacks to work around technology that I didn't yet understand or couldn't figure out.
After a week of research I migrated the entire deployment across to httpd (apache). 
The primary reason for the migration is that there seems to be more support for running httpd with sinatra applications in the open source community. Which meant more assistance if required.

Some improvements can still be made to this  script:
- have variables setup for the git url
- with the automated phusion deployment, if a new version come out, the module will change names
- shift the file create for sinatra.conf to a template file