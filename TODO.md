In no particular order:

* A real page layout
* Warm caches on app startup
* Include note text
* Include select note tags
* Select notebook by name rather than GUID
* Listen to Evernote webhooks to know what a note is added or updated
  * Blow away caches as appropriate
* Monitoring/alerting
* Switch to Unicorn
  * Requires some tuning. Depends on being able to monitor memory quota erros.
  * https://devcenter.heroku.com/articles/rails-unicorn#adding-unicorn-to-your-application
