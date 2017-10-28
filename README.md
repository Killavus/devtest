# devtest

Assumptions:

* Panel Provider acts like a tenant and 'scopes' operations on data.
* Target Group names are unique inside one hierarchy tree.
* O(h) is an acceptable solution for number of SQL queries required to reconstruct the whole Target Group hierarchy.
* JWT does not need the part to actually generate the token - so we can federate it away. Only consuming the token is implemented.

Sacrifices:

* There is a BFS algorithm implemented in many places - maybe there is a way to abstract it as a generic tree travelsal strategy.
* Data layer is not secured enough for invalid data - although there are some basic validations in place.
* There are no proper application query/services for more trivial parts of the app.
* As a corollary to the previous point, the data creation process is messy. It should be, because using AR to create state directly is often a code smell. But since there is no proper domain-level layer in place (due to lack of both time and domain knowledge), we can't really fix it.

## JWT

You can obtain a token (valid for an hour) directly from the Rails console. Remember to set JWT_SECRET correctly, preferably in `.env` file.

```
generator = IdentityAccess::JwtTokenGenerator.new(ENV['JWT_SECRET'])
generator.generate(panel_provider_id: N, private_api: true/false)
```

