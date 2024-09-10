# fstore
This only exists to try some things out for a different project.
It's a ruby/sinatra/haml app and a golang app.  The ruby app handles auth,
file uploading and sharing.  Go handles writing the file to disk.

The ruby app was built using [blue-eyes](https://github.com/tomrplummer/blue-eyes), which
is just something I'm building for fun.

The ruby app using some shared libraries created in the go app, not sure how portable those are.

Running bundle install and then bin/dev may or may not launch both apps.  Pretty likely one or both will fail.
