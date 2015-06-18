Provides mechanism to use ActiveRecord Authlogic as an authenticator for [CASino](https://github.com/rbCAS/CASino).
Allows to simply migrate from RubyCAS to CASino.

To use the ActiveRecordAuthLogic authenticator, configure it in your cas.yml:

    authenticators:
      my_company_sql:
        authenticator: "ActiveRecordAuthLogic"
        options:
          connection:
            adapter: "mysql2"
            host: "localhost"
            username: "casino"
            password: "secret"
            database: "users"
          table: "users"
          username_column: "username"
          password_column: "password"
          salt_column: "salt_column"
          encryptor: "Sha512"
          extra_attributes:
            email: "email_database_column"
            fullname: "displayname_database_column"


## Contributing to casino-activerecord_authlogic_authenticator

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2015 Marcin Ożóg. See LICENSE.txt
for further details.

