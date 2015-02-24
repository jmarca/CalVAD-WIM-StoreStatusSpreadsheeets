# Store Status Spreadsheets

Perl code that stores the output of the (parsed) spreadsheets produced
by Caltrans to note WIM monthly status

Depends on the CalVAD::WIM::ParseStatusspreadsheeets library to do the
parsing.

This library just writes to a PostgreSQL database.

# Usage



# Testing

To run the tests (you do want to run the tests right?) I am expecting
a few environment variables to be set and also that the account that
is running the test (a user account, or a super user) has a .pgpass
file as explained
[in the PostgreSQL documentation](http://www.postgresql.org/docs/9.4/static/libpq-pgpass.html).
I also expect that there is an admin account `postgres` and the
equivalent `postgres` database.

The full list of assumption and environment variables are:

```
my $host = $ENV{PGHOST} || '127.0.0.1';
my $port = $ENV{PGPORT} || 5432;
my $db = $ENV{PGTESTDATABASE} || 'test_calvad_db';
my $user = $ENV{PGTESTUSER} || $ENV{PGUSER} || 'postgres';
my $pass =  '';

my $admindb = $ENV{PGDATABASE} || 'test_calvad_db';
my $adminuser = $ENV{PGADMINUSER} || 'postgres';
```

If you want anything different, then change the environment variables.

I am deliberately not accepting a password.  Instead, that will be
left to the relevant line in the `.pgpass` file.  For example, if you
are connecting to localhost with the `postgres` account, you might
have a line like the following in your `.pgpass` file:

```
#hostname:port:database:username:password
127.0.0.1:*:*:postgres:this is a great passphrase
```

The test script will create and then delete the database defined by
`$ENV{PGTESTDATABASE} || 'test_calvad_db'`.  The creation and deletion
of that database will be done by the defined admin user, which
defaults to `postgres`.  The rest of the tests will be run by the user
defined as `PGTESTUSER`.
