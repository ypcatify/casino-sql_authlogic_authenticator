Provides mechanism to use SQLAuthlogic as an authenticator for [CASino](https://github.com/rbCAS/CASino).
Allows to migrate from RubyCAS to CASino using the same users table.

## Installation

Put it in your Gemfile and run `bundle install`

```ruby
gem "casino-sql_authlogic_authenticator", github: "ypcatify/casino-sql_authlogic_authenticator"
```

## Configuration

To use the SQLAuthLogic authenticator, configure it in your cas.yml:

    authenticators:
      my_company_sql:
        authenticator: "SQLAuthLogic"
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
          password_salt_column: "salt_column"
          encryptor: "Sha512"
          extra_attributes:
            email: "email_database_column"
            fullname: "displayname_database_column"


## Copyright

Copyright (c) 2015 Marcin Ożóg. See LICENSE.txt
for further details.

